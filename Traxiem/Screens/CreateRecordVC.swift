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

class CreateRecordVC: DataLoadingVC {

    var tableView: UITableView!
    
    weak var delegate: RecordListVC!
    var dataSource = CreateRecordDataSource()
    
    var createdRecordId: String!
    var selectedCell = RecordFieldCell()
    
    var modifiedFields = [String: String?]()
    var requiredFields = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        configureViewController()
        showLoadingView()
        dataSource.createRecord()
    }

    @objc func doneTapped() {
        view.endEditing(true)
        let modifiedFieldsBody = TRXNetworkManager.shared.getModifiedFieldsBody(from: modifiedFields)
        dataSource.modifyRecord(createdRecordId, "Commit", body: modifiedFieldsBody, actionName: nil)
        self.dismiss(animated: true)
    }

    @objc func cancelTapped() {
        view.endEditing(true)
        presentUnsavedChangesAlertController() {
            [weak self] result in
            guard let self = self else { return }
            self.dataSource.modifyRecord(self.createdRecordId, "Revert", body: [:], actionName: nil)
        }
    }

    private func configureViewController() {
        tableView = UITableView.setTableViewStyle()
        tableView.frame = view.bounds
        configureDismissKeyboardTapGesture()
        
        view.addSubview(tableView)
        
        navigationItem.largeTitleDisplayMode = .never
        dataSource.delegate = self

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.register(RecordFieldCell.self, forCellReuseIdentifier: RecordFieldCell.reuseIdentifier)

        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped)), animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped)), animated: true)
    }

    func didFinishLoadingCreatedRecord(_ record: Record? = nil) {
        if let record = record {
            createdRecordId = record.fields[7].value
            title = createdRecordId
            getRequiredFields(from: record)
            updateDoneButton()
            tableView.reloadData()
        }
    }
    func didFinishCreatingRecord() { dismiss(animated: true) }

    func showFieldSelectionVC(with cell: RecordFieldCell) {
        let fieldSelectionVC = FieldSelectionVC(selectedChoice: cell.fieldValueTextField.text ?? "", selectedFieldName: cell.fieldNameLabel.text, recordId: createdRecordId)
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
    
    func updateDataSourceRecord(with value: String) {
        var selectedRecordFields = dataSource.createdRecord.fields
        
        modifiedFields[selectedCell.fieldNameLabel.text!] = value
        for i in 0..<selectedRecordFields.count {
            if selectedRecordFields[i].name == selectedCell.fieldNameLabel.text! {
                selectedRecordFields[i].value = value
            }
        }
        dataSource.createdRecord.fields = selectedRecordFields
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

extension CreateRecordVC: FieldSelectionVCDelegate {
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

extension CreateRecordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        modifiedFields["Headline"] = textField.text
        guard let headlineText = textField.text else { return }
        dataSource.createdRecord.fields[5].value = headlineText
    }
}
