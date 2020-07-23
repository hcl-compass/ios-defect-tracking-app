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

class DataLoadingVC: UIViewController {

    var containerView: UIView!
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        
        if #available(iOS 13.0, *) {
            containerView.backgroundColor = .systemGroupedBackground
        } else {
            containerView.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
        }
        containerView.alpha = 1
        
        let activityIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) { } else {
            activityIndicator.color = .gray
        }
        containerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            guard let containerView = self.containerView else { return }
            containerView.removeFromSuperview()
        }
    }
    
    func showLoadingViewIn(footerViewOf tableView: UITableView) {
        let activityIndicator = UIActivityIndicatorView()
        if #available(iOS 13.0, *) { } else {
            activityIndicator.color = .gray
        }
        
        tableView.tableFooterView = activityIndicator
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingViewFrom(footerViewOf tableView: UITableView) {
        DispatchQueue.main.async {
            guard let activityIndicator = tableView.tableFooterView else { return }
            activityIndicator.removeFromSuperview()
        }
    }

}
