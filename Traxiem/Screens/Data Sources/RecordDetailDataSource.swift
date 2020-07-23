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

class RecordDetailDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: RecordDetailVC!
    var selectedRecord: Record!

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = RecordDetailSection(rawValue: indexPath.section)!
        let row = section.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RecordFieldCell.reuseIdentifier, for: indexPath) as! RecordFieldCell
        if row == .headline {
            cell.fieldValueTextField.delegate = delegate
            cell.fieldValueTextField.addTarget(delegate, action: #selector(delegate.headlineEditingChanged(_:)), for: .editingChanged)
        }
        
        cell.configure(with: row.rawValue, using: selectedRecord)
        return cell
    }
    
    func getRecord(_ recordId: String) {
        TRXNetworkManager.shared.getRecord(with: recordId) {
            [weak self] (result) in
            DispatchQueue.main.async {
                self?.delegate.dismissLoadingView()
                
                switch result {
                case .success(let data):
                    guard let record = data?.decode(to: Record.self) else { return }
                    self?.selectedRecord = record
                    self?.delegate?.finishedLoadingRecordDetails(record)
                case .failure(let error):
                    self?.delegate?.finishedLoadingRecordDetails()
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func modifyRecord(_ recordId: String, _ operation: String, body: [String: [[String: String?]]], actionName: String?) {
        TRXNetworkManager.shared.modifyRecord(with: recordId, body: body, operation: operation, actionName: actionName) {
            [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let record = data?.decode(to: Record.self) { self?.selectedRecord = record }
                    if operation == "Commit" {
                        self?.getRecord(recordId)
                    } else { self?.delegate?.finishedLoadingRecordDetails(self?.selectedRecord) }
                case .failure(let error):
                    self?.delegate?.finishedLoadingRecordDetails()
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func deleteRecord(_ recordId: String) {
        TRXNetworkManager.shared.deleteRecord(with: recordId) {
            [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.delegate?.finishedLoadingRecordDetails()
                case .failure(let error):
                    self?.delegate?.finishedLoadingRecordDetails()
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 4 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = selectedRecord else { return 0 }
        
        switch section {
            case 0: return 4
            case 1: return 3
            case 2: return 2
            case 3: return 1
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.view.endEditing(true)
        let cell = tableView.cellForRow(at: indexPath) as! RecordFieldCell
        let section = RecordDetailSection(rawValue: indexPath.section)!
        let row = section.rows[indexPath.row]
        delegate.selectedRow = row
        
        if cell.fieldNameLabel.text != "Headline" {
            if cell.fieldNameLabel.text == "State" { delegate.showStateSelectionVC() }
            else if cell.fieldNameLabel.text == "Description" { delegate.showDescriptionVC(with: cell) }
            else { delegate.showFieldSelectionVC(with: cell) }
        }
        UIView.transition(with: tableView, duration: 0.20, options: .transitionCrossDissolve, animations: {  });
    }
}
