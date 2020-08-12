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

protocol FieldSelectionVCDelegate: class {
    func didFinishSelectingChoice(with choice: String)
}

class FieldSelectionVC: ChoiceSelectionVC {

    weak var delegate: FieldSelectionVCDelegate!
    var dataSource = FieldSelectionDataSource()
    
    var selectedFieldName: String?
    var recordId: String?
    
    init(selectedChoice: String, selectedFieldName: String?, recordId: String?) {
        super.init(nibName: nil, bundle: nil)
        self.selectedChoice = selectedChoice
        self.selectedFieldName = selectedFieldName
        self.recordId = recordId
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        guard let recordId = recordId, let selectedFieldName = selectedFieldName else { return }
        dataSource.getField(recordId, selectedFieldName)
    }
    
    @objc func didFinishSelectingChoice() {
        delegate.didFinishSelectingChoice(with: dataSource.selectedChoice ?? "")
        self.dismiss(animated: true)
    }
    
    private func configureViewController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didFinishSelectingChoice))
        title = selectedFieldName
        
        dataSource.delegate = self
        dataSource.selectedChoice = selectedChoice
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
}
