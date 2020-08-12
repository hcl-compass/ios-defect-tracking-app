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

protocol StateSelectionVCDelegate: class {
    func didFinishSelectingState(with state: String?)
}

class StateSelectionVC: ChoiceSelectionVC {
    
    weak var delegate: StateSelectionVCDelegate!
    let dataSource = StateDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        dataSource.getRecordType()
    }
    
    @objc func didSelectState() { navigationItem.rightBarButtonItem?.isEnabled = true }
    
    @objc func didFinishSelectingState() {
        delegate.didFinishSelectingState(with: dataSource.currentState ?? nil)
        self.dismiss(animated: true)
    }
    
    private func configureViewController() {
        title = "Change State"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didFinishSelectingState))
        navigationItem.rightBarButtonItem?.isEnabled = false
        dataSource.delegate = self
        dataSource.currentState = selectedChoice
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
}
