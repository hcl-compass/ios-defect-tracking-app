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

class TRXTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(placeholder: String) {
        super.init(frame: .zero)
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.systemGray
        ])
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        leftViewMode = .always
        
        if #available(iOS 13.0, *) { textColor = .label } else { textColor = .black }
        layer.cornerRadius = 5
        textAlignment = .left
        font = UIFont.preferredFont(forTextStyle: .body)
        minimumFontSize = 12
        
        autocorrectionType = .no
        autocapitalizationType = .none
        clearButtonMode = .whileEditing
    }
}
