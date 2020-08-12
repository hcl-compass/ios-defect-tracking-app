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

class ChoiceSelectionVC: UIViewController {
    
    var tableView: UITableView!
    var spinner: UIActivityIndicatorView?
    var selectedChoice: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseViewController()
        configureTableView()
        configureSpinnerView()
    }
    
    private func configureTableView() {
        tableView = UITableView.setTableViewStyle()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChoiceCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true)
    }
    
    func didFinishLoadingField() {
        spinner?.stopAnimating()
        tableView.reloadData()
    }
    
    private func configureBaseViewController() {
        setBackgroundColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }
    
    private func configureSpinnerView() {
        spinner = UIActivityIndicatorView()
        spinner?.startAnimating()
        guard #available(iOS 13.0, *) else {
            spinner?.color = .gray
            tableView.tableFooterView = spinner
            return
        }
        tableView.tableFooterView = spinner
    }
}
