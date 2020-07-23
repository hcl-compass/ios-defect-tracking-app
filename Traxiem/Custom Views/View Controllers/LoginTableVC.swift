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

protocol LoginTableVCDelegate: class {
    func loginButtonStateShouldChange(to enabled: Bool)
    func didTapRepoCell()
    func didTapDatabaseCell()
}

class LoginTableVC: UIViewController {
    
    var tableView: TRXResizingTableView!
    
    weak var delegate: LoginTableVCDelegate!
    var dataSource = LoginTableVCDataSource()
    
    var usernameCell = UsernameCell()
    var passwordCell = PasswordCell()
    var repoCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
    
    var selectedRepo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        configureTableView()
        configureRepoCell()
    }
    
    func getUsername() -> String? { return usernameCell.getText() }

    func getPassword() -> String? { return passwordCell.getText() }
    
    func getRepo() -> String { return repoCell.detailTextLabel?.text ?? "" }
    
    func showRepoSelection() { delegate.didTapRepoCell() }
    
    func showDatabaseSelection() { delegate.didTapDatabaseCell() }
    
    func resetLogin() {
        usernameCell.resetTextField()
        passwordCell.resetTextField()
        selectedRepo = ""
        repoCell.detailTextLabel?.text = ""
        tableView.reloadData()
    }
    
    @objc func editingChanged(_ sender: UITextField?) {
        if sender?.text?.count == 1 {
            if sender?.text?.first == " " {
                sender?.text = ""
                return
            }
        }
        guard let usernameText = getUsername(), !usernameText.isEmpty, !getRepo().isEmpty else {
            delegate.loginButtonStateShouldChange(to: false)
            return
        }
        delegate.loginButtonStateShouldChange(to: true)
    }

    func configureTableView() {
        tableView = TRXResizingTableView.setContentSizedTableView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        usernameCell.textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        passwordCell.textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        tableView.setContentCompressionResistancePriority(.required, for: .vertical)
        tableView.setContentHuggingPriority(.required, for: .vertical)
        
        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        tableView.tableHeaderView = UIView.emptyView()
        tableView.tableFooterView = UIView.emptyView()
        tableView.isScrollEnabled = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configureRepoCell() {
        repoCell.textLabel?.text = "Repo"
        repoCell.accessoryType = .disclosureIndicator
    }
}

extension LoginTableVC: RepoSelectionVCDelegate {
    func didFinishSelectingRepo(with repo: String?) {
        self.selectedRepo = repo
        repoCell.detailTextLabel?.text = repo
        editingChanged(nil)
        tableView.reloadData()
        tableView.invalidateIntrinsicContentSize()
    }
}
