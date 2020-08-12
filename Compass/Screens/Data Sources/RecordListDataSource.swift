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

class RecordListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: RecordListVC?
    var queryDbId: String!
    var records = [ResultSetRow]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecordListCell.reuseIdentifier, for: indexPath) as? RecordListCell else { fatalError() }
        
        let record = records[indexPath.row]
        cell.configure(with: record)

        return cell
    }
    
    func getResultSet(of resultSetId: String, for queryDbId: String) {
        TRXNetworkManager.shared.getResultSet(of: resultSetId, for: queryDbId) {
            [weak self] (result) in
            self?.delegate?.tableView.refreshControl?.endRefreshing()
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let resultSetPage = data?.decode(to: ResultSetPage.self) else { return }
                    self?.records = resultSetPage.rows
                    self?.delegate?.didFinishLoadingResults()
                case .failure(let error):
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
                    self?.delegate?.didFinishLoadingResults()
                case .failure(let error):
                    self?.delegate?.didFinishLoadingResults()
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow: ResultSetRow = records[indexPath.row]
        delegate?.showRecordDetails(selectedRecord: selectedRow)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedRow = records[indexPath.row]
            delegate?.presentDeleteAlertController() {result in
                self.deleteRecord(selectedRow.values[0])
                self.records.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
