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

protocol RepoSelectionVCDelegate: class {
    func didFinishSelectingRepo(with repo: String?)
}

class RepoSelectionVC: DataLoadingVC {
    
    var tableView: UITableView!
    
    weak var delegate: RepoSelectionVCDelegate!
    var dataSource = RepoSelectionDataSource()
    var selectedRepo: String!
    
    init(selectedRepo: String?) {
        super.init(nibName: nil, bundle: nil)
        self.selectedRepo = selectedRepo
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureViewController()
        showLoadingViewIn(footerViewOf: tableView)
        dataSource.fetchRepos()
    }
    
    func didSelectRepo() {
        selectedRepo = dataSource.selectedRepo
        if selectedRepo.isEmpty { navigationItem.rightBarButtonItem?.isEnabled = false }
        else { navigationItem.rightBarButtonItem?.isEnabled = true }
    }
    
    @objc func didFinishSelectingRepo() {
        selectedRepo = dataSource.selectedRepo
        delegate.didFinishSelectingRepo(with: selectedRepo ?? "")
        self.dismiss(animated: true)
    }
    
    @objc func cancelTapped() {
        NetworkManager.session.getAllTasks {
            (tasks) in
            for task in tasks { task.cancel() }
        }
        dismissVc()
    }
    
    func didFinishLoadingRepos() { tableView.reloadData() }
    
    private func configureTableView() {
        tableView = UITableView.setTableViewStyle()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        dataSource.delegate = self
        dataSource.selectedRepo = selectedRepo
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RepoCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureViewController() {
        setBackgroundColor()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didFinishSelectingRepo))
        if selectedRepo.isEmpty { navigationItem.rightBarButtonItem?.isEnabled = false }
        else { navigationItem.rightBarButtonItem?.isEnabled = true }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        title = "Repos"
    }
}
