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

class StateDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: StateSelectionVC?
    var currentState: String?
    var allActions = [State]()
    var possibleStates = [String]()

    func getRecordType() {
        TRXNetworkManager.shared.getRecordType {
            [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let retrievedRecordType = data?.decode(to: RecordType.self) else { return }
                    self?.allActions = retrievedRecordType.actions
                    self?.getPossibleStates()
                    self?.delegate?.didFinishLoadingField()
                case .failure(let error):
                    self?.delegate?.didFinishLoadingField()
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return possibleStates.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell", for: indexPath)
        let choice = possibleStates[indexPath.row]
        cell.textLabel?.text = choice
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        currentState = possibleStates[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.didSelectState()
    }
    
    private func getPossibleStates() {
        for action in allActions {
            for state in action.actionSourceStateNames {
                if currentState == state && action.actionType == "_CHANGE_STATE" {
                    possibleStates.append(action.name)
                    break
                }
            }
        }
    }
}
