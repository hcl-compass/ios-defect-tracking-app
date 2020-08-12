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

class FieldSelectionDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: FieldSelectionVC?
    
    var selectedChoice: String?
    var choiceList = [String]()
    
    func getField(_ recordId: String, _ fieldName: String) {
        TRXNetworkManager.shared.getField(of: recordId, with: fieldName) {
            [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let retrievedField = data?.decode(to: Field.self) else { return }
                    self?.choiceList = retrievedField.fieldChoiceList!
                    self?.delegate?.didFinishLoadingField()
                case .failure(let error):
                    self?.delegate?.didFinishLoadingField()
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choiceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell", for: indexPath)
        let choice = choiceList[indexPath.row]
        
        cell.textLabel?.text = choice

        if choice == selectedChoice {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        selectedChoice = choiceList[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
