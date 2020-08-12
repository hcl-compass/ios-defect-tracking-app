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

class UserProfileVC: DataLoadingVC {
    
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureTableView()
    }
    
    private func configureViewController() {
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .never
        setBackgroundColor()
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        
        view.addSubview(tableView)
    }
    
    func logout() {
        TRXNetworkManager.shared.logoff {
            [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.didFinishLoggingOut()
                    self?.dismiss(animated: true)
                case .failure(let error):
                    self?.didFinishLoggingOut()
                    self?.dismiss(animated: true)
                    
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    private func didFinishLoggingOut() {
        KeychainHelper.removeTokenFromKeychain()
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "repo")
        UserDefaults.standard.removeObject(forKey: "last_login")
    }
}

extension UserProfileVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Username" }
        if section == 1 { return "Repo" }
        if section == 2 { return "Database" }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        
        if  indexPath.section == 0 {
            guard let username = UserDefaults.standard.string(forKey: "username") else { return cell }
            cell.textLabel?.text = "\(username)"
            cell.isUserInteractionEnabled = false
        } else if indexPath.section == 1 {
            guard let repo = UserDefaults.standard.string(forKey: "repo") else { return cell }
            cell.textLabel?.text = "\(repo)"
            cell.isUserInteractionEnabled = false
        } else if indexPath.section == 2 {
            guard let db = UserDefaults.standard.string(forKey: "preferredDb") else { return cell }
            cell.textLabel?.text = "\(db)"
            cell.isUserInteractionEnabled = false
        } else {
            cell.textLabel?.text = "Log out"
            cell.textLabel?.textColor = .systemRed
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            tableView.deselectRow(at: indexPath, animated: true)
            let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Log out", style: .destructive) { (_) in self.logout() })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
