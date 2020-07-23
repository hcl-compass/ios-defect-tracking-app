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

class DescriptionVC: UIViewController {
    
    var textView = UITextView()
    var descriptionText: String?
    
    weak var delegate: FieldSelectionVCDelegate!
    
    init(selectedChoice: String?) {
        super.init(nibName: nil, bundle: nil)
        self.descriptionText = selectedChoice
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextView()
        configureViewController()
    }
    
    @objc func didFinishSelectingChoice() {
        delegate.didFinishSelectingChoice(with: textView.text ?? "")
        self.dismiss(animated: true)
    }
    
    @objc func cancelTapped() { self.dismiss(animated: true) }
    
    private func configureTextView() {
        textView.text = descriptionText
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.becomeFirstResponder()
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.maximumNumberOfLines = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureViewController() {
        setBackgroundColor()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didFinishSelectingChoice))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        title = "Description"
    }
}
