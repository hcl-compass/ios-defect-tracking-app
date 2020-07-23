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

class RepoSelectionDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: RepoSelectionVC?
    var selectedRepo: String?
    
    var repos = [Repo]()
    
    func fetchRepos() {
        TRXNetworkManager.shared.getRepos {
            [weak self] (result) in
            guard let self = self else { return }
            guard let delegateTableView = self.delegate?.tableView else { return }
            DispatchQueue.main.async {
                self.delegate?.dismissLoadingViewFrom(footerViewOf: delegateTableView)
                
                switch result {
                case .success(let data):
                    guard let retrievedRepos = data?.decode(to: [Repo].self) else { return }
                    self.repos = retrievedRepos
                    self.delegate?.didFinishLoadingRepos()
                case .failure(let error):
                    self.delegate?.didFinishLoadingRepos()
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath)
        let repo = repos[indexPath.row]
        
        cell.textLabel?.text = repo.name

        if repo.name == selectedRepo {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Repos"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        selectedRepo = repos[indexPath.row].name
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.didSelectRepo()
    }
}
