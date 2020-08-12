/*
 
 Copyright 2020 HCL Technologies Ltd.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
*/

import UIKit

class RecordDetailVC: DataLoadingVC {
    
    var tableView: UITableView!
    
    weak var delegate: RecordListVC!
    var dataSource = RecordDetailDataSource()
    
    var selectedRow: RecordDetailRow!
    var selectedCell: RecordFieldCell!
    
    var record: Record!
    var recordId: String!
    
    var modifiedFields = [String: String?]()
    var requiredFields = [String: String]()
    
    init(recordId: String) {
        super.init(nibName: nil, bundle: nil)
        self.recordId = recordId
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        showLoadingView()
        dataSource.getRecord(recordId)
    }
    
    @objc func editTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Modify", style: .default) {
            [weak self] (_) in
            guard let self = self else { return }
            self.dataSource.modifyRecord(self.recordId, "Edit", body: [:], actionName: "Modify")
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped)), animated: true)
            self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTapped)), animated: true)
        })
        actionSheet.addAction(UIAlertAction(title: "Change State", style: .default) {
            [weak self] (_) in
            guard let self = self else { return }
            self.showStateSelectionVC()
        })
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive) {
            [weak self] result in
            guard let self = self else { return }
            self.presentDeleteAlertController() {result in
                self.dataSource.deleteRecord(self.recordId)
                self.navigationController?.popViewController(animated: true)
            }
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    @objc func doneTapped() {
        view.endEditing(true)
        let modifiedFieldsBody = TRXNetworkManager.shared.getModifiedFieldsBody(from: modifiedFields)
        dataSource.modifyRecord(recordId, "Commit", body: modifiedFieldsBody, actionName: nil)
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(editTapped)), animated: true)
        navigationItem.setLeftBarButton(.none, animated: true)
    }
    
    @objc func cancelTapped() {
        view.endEditing(true)
        presentUnsavedChangesAlertController() {
            [weak self] result in
            guard let self = self else { return }
            self.dataSource.modifyRecord(self.recordId, "Revert", body: [:], actionName: nil)
            self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.editTapped)), animated: true)
            self.navigationItem.setLeftBarButton(.none, animated: true)
        }
    }
    
    private func configureViewController() {
        tableView = UITableView.setTableViewStyle()
        tableView.frame = view.bounds
        configureDismissKeyboardTapGesture()
        
        view.addSubview(tableView)
        
        navigationItem.largeTitleDisplayMode = .never
        title = recordId
        dataSource.delegate = self
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.register(RecordFieldCell.self, forCellReuseIdentifier: RecordFieldCell.reuseIdentifier)

        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(editTapped)), animated: true)
    }
    
    func finishedLoadingRecordDetails(_ record: Record? = nil) {
        if let record = record {
            self.record = record
            getRequiredFields(from: record)
            updateDoneButton()
            tableView.reloadData()
        }
    }
    
    func showFieldSelectionVC(with cell: RecordFieldCell) {
        let fieldSelectionVC = FieldSelectionVC(selectedChoice: cell.fieldValueTextField.text ?? "", selectedFieldName: cell.fieldNameLabel.text, recordId: recordId)
        fieldSelectionVC.delegate = self
        self.selectedCell = cell
        present(UINavigationController(rootViewController: fieldSelectionVC), animated: true)
    }
    
    func showDescriptionVC(with cell: RecordFieldCell) {
        let descriptionVC = DescriptionVC(selectedChoice: cell.fieldValueTextField.text)
        descriptionVC.delegate = self
        self.selectedCell = cell
        present(UINavigationController(rootViewController: descriptionVC), animated: true)
    }
    
    func showStateSelectionVC() {
        let stateSelectionVC = StateSelectionVC()
        stateSelectionVC.delegate = self
        stateSelectionVC.selectedChoice = record.fields[24].value
        present(UINavigationController(rootViewController: stateSelectionVC), animated: true)
    }
    
    func updateDataSourceRecord(with value: String) {
        var selectedRecordFields = dataSource.selectedRecord.fields
        
        modifiedFields[selectedCell.fieldNameLabel.text!] = value
        for i in 0..<selectedRecordFields.count {
            if selectedRecordFields[i].name == selectedCell.fieldNameLabel.text! {
                selectedRecordFields[i].value = value
            }
        }
        dataSource.selectedRecord.fields = selectedRecordFields
    }
    
    func updateDoneButton() {
        var allValuesSet = true
        for value in requiredFields.values {
            if value.isEmpty {
                allValuesSet = false
                break
            }
        }
        
        if requiredFields.isEmpty || allValuesSet { self.navigationItem.rightBarButtonItem?.isEnabled = true }
        else { self.navigationItem.rightBarButtonItem?.isEnabled = false }
    }
    
    func getRequiredFields(from record: Record) {
        requiredFields = [String: String]()
        
        for field in record.fields { if field.requiredness == "MANDATORY" { requiredFields[field.name] = field.value } }
    }
    
    @objc func headlineEditingChanged(_ sender: UITextField) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! RecordFieldCell
        if let text = sender.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
            cell.fieldNameLabel.textColor = UILabel.getPrimaryTextColor()
            requiredFields.removeValue(forKey: "Headline")
        } else {
            cell.fieldNameLabel.textColor = .systemRed
            requiredFields["Headline"] = ""
        }
        updateDoneButton()
    }
}

extension RecordDetailVC: FieldSelectionVCDelegate {
    func didFinishSelectingChoice(with choice: String) {
        let fieldName = selectedCell.fieldNameLabel.text!
        self.selectedCell.fieldValueTextField.text = choice
        
        //Required field
        if requiredFields[fieldName] != nil {
            if choice.isEmpty && requiredFields[selectedCell.fieldNameLabel.text!] != nil {
                self.selectedCell.fieldNameLabel.textColor = .systemRed
            }
            else {
                self.selectedCell.fieldNameLabel.textColor = UILabel.getPrimaryTextColor()
            }
            requiredFields.updateValue(choice, forKey: selectedCell.fieldNameLabel.text!)
        }
        
        updateDataSourceRecord(with: choice)
        updateDoneButton()
    }
}

extension RecordDetailVC: StateSelectionVCDelegate {
    func didFinishSelectingState(with state: String?) {
        dataSource.modifyRecord(recordId, "Edit", body: [:], actionName: state)
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTapped)), animated: true)
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped)), animated: true)
    }
}

extension RecordDetailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        modifiedFields["Headline"] = textField.text
        guard let headlineText = textField.text else { return }
        dataSource.selectedRecord.fields[5].value = headlineText
    }
}
