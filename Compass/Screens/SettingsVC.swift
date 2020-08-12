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

class SettingsVC: UIViewController {
    
    var tableView: UITableView!
    let urlCell = TextFieldCell(style: .default, reuseIdentifier: nil)
    let dbCell = TextFieldCell(style: .default, reuseIdentifier: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
    
    @objc func doneTapped() { self.dismiss(animated: true) }
    
    private func configureViewController() {
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        setBackgroundColor()
        configureDismissKeyboardTapGesture()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    }
    
    private func configureTableView() {
        tableView = UITableView.setTableViewStyle()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension SettingsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            urlCell.textField.delegate = self
            urlCell.textField.placeholder = "Server"
            
            if let preferredUrl = UserDefaults.standard.string(forKey: "preferredUrl") {
                urlCell.textField.text = preferredUrl
            }
            return urlCell
        } else {
            dbCell.textField.delegate = self
            dbCell.textField.placeholder = "Database"
            
            if let preferredDb = UserDefaults.standard.string(forKey: "preferredDb") {
                dbCell.textField.text = preferredDb
            }
            return dbCell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Preferred Server URL" }
        return "Preferred Database"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Enter the base URL of the preferred Compass server to connect to. If this is not set, a default base URL will be used."
        }
        return "Enter the name of a database to connect to. This database must exist in the repository chosen on the login screen."
    }
}

extension SettingsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let placeholder = textField.placeholder, placeholder == "Server" { urlCell.textField.resignFirstResponder() }
        else {
            dbCell.textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let placeholder = textField.placeholder, placeholder == "Server" { UserDefaults.standard.set(urlCell.textField.text, forKey: "preferredUrl") }
        else {
            UserDefaults.standard.set(dbCell.textField.text, forKey: "preferredDb")
        }
    }
}
