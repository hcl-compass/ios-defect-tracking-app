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

class RecordListVC: DataLoadingVC {
    
    var tableView: UITableView!
    var dataSource = RecordListDataSource()
    
    var folders: [Folder]!
    var queryDbId: String!
    var resultSetId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) { refreshVC() }
    
    @objc func refreshVC() { getFolders() }
    
    func getFolders() {
        TRXNetworkManager.shared.getFolders() {
            [weak self] (result) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let rootFolders = data?.decode(to: [Folder].self) else { return }
                    self.folders = rootFolders
                    if(self.queryDoesExist(named: self.title!)) {
                        self.createResultSet(for: self.queryDbId)
                    } else {
                        guard let personalFolder = self.locatePersonalFolder() else { return }
                        self.createQuery(in: personalFolder.dbId, with: self.title!)
                    }
                case .failure(let error):
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }

    func createQuery(in parentFolderDbId: String, with name: String) {
        TRXNetworkManager.shared.createQuery(in: parentFolderDbId, named: name) {
            [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let queryDef = data?.decode(to: QueryDef.self) else { return }
                    self.queryDbId = queryDef.dbId
                    self.createResultSet(for: self.queryDbId)
                case .failure(let error):
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func createResultSet(for queryDbId: String) {
        TRXNetworkManager.shared.createResultSet(for: queryDbId) {
            [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let resultSet = data?.decode(to: ResultSet.self) else { return }
                    self.resultSetId = resultSet.resultSetId
                    self.dataSource.getResultSet(of: self.resultSetId, for: self.queryDbId)
                case .failure(let error):
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func queryDoesExist(named name: String) -> Bool {
        guard let personalFolder = locatePersonalFolder() else { fatalError() }
        for item in personalFolder.children {
            if item.name == name {
                queryDbId = item.dbId
                return true
            }
        }
        return false
    }
    
    func locatePersonalFolder() -> Folder? {
        for folder in folders {
            if folder.name == "Personal Queries" { return folder }
        }
        return nil
    }
    
    func didFinishLoadingResults() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    func showRecordDetails(selectedRecord: ResultSetRow) {
        let recordDetailsVC = RecordDetailVC(recordId: selectedRecord.values[0])
        recordDetailsVC.delegate = self
        navigationController?.pushViewController(recordDetailsVC, animated: true)
    }
    
    @objc func profileTapped() {
        navigationController?.pushViewController(UserProfileVC(), animated: true)
//        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Log out", style: .destructive) { (_) in self.logout() })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showCreateRecordVC() {
        let createRecordVC = CreateRecordVC()
        createRecordVC.delegate = self
        let navController = UINavigationController(rootViewController: createRecordVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func configureViewController() {
        dataSource.delegate = self
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.register(RecordListCell.self, forCellReuseIdentifier: RecordListCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshVC), for: .valueChanged)
        
        if #available(iOS 13.0, *) {
            navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: self, action: #selector(profileTapped)), animated: true)
        } else {
            navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(named: "person.circle"), style: .plain, target: self, action: #selector(profileTapped)), animated: true)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCreateRecordVC))
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
