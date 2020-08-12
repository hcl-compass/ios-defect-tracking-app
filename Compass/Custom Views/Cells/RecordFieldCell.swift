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

class RecordFieldCell: UITableViewCell {
    
    static let reuseIdentifier = "RecordFieldCell"
    let fieldNameLabel: UILabel = UILabel()
    let fieldValueTextField: UITextField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        isUserInteractionEnabled = false
        configureFieldNameLabel()
        configurefieldValueTextField()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func configureFieldNameLabel() {
        contentView.addSubview(fieldNameLabel)
        fieldNameLabel.numberOfLines = 0
        fieldNameLabel.font = UIFont.preferredFont(forTextStyle: .headline)

        fieldNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fieldNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            fieldNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            fieldNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        ])
    }
    
    
    private func configurefieldValueTextField() {
        contentView.addSubview(fieldValueTextField)
        fieldValueTextField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        fieldValueTextField.sizeToFit()
        fieldValueTextField.isUserInteractionEnabled = false
        fieldValueTextField.font = UIFont.preferredFont(forTextStyle: .body)
        fieldValueTextField.translatesAutoresizingMaskIntoConstraints = false


        NSLayoutConstraint.activate([
            fieldValueTextField.topAnchor.constraint(equalTo: fieldNameLabel.bottomAnchor, constant: 5),
            fieldValueTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            fieldValueTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            fieldValueTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        ])
    }

    func setValues(with field: Field) {
        fieldNameLabel.text = field.name
        fieldValueTextField.text = field.value
        
        if field.requiredness == "OPTIONAL" || field.requiredness == "MANDATORY" {
            isUserInteractionEnabled = true
            if field.name == "Headline" { fieldValueTextField.isUserInteractionEnabled = true }
        } else { isUserInteractionEnabled = false }
        
        if field.requiredness == "MANDATORY" {
            if fieldValueTextField.text!.isEmpty { fieldNameLabel.textColor = .red }
        } else { fieldNameLabel.textColor = UILabel.getPrimaryTextColor() }
    }

    func configure(with name: String, using selectedRecord: Record) {
        let fieldName = name
        for field in selectedRecord.fields {
            if field.name == fieldName {
                setValues(with: field)
                break
            }
        }
    }
}
