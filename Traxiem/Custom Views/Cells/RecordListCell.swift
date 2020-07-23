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

class RecordListCell: UITableViewCell {

    static let reuseIdentifier = "RecordListCell"
    
    let selectionBackgroundView = UIView()
    let recordNameLabel: UILabel = UILabel()
    let recordIdLabel: UILabel = UILabel()
    let recordTimeLabel: UILabel = UILabel()
    let recordCreatorLabel: UILabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        configureSubviews()
        configureRecordHeadlineLabel()
        configureRecordId()
        configureRecordTimeStamp()
        configureRecordCreator()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func configureSubviews() {
        contentView.addSubview(recordNameLabel)
        contentView.addSubview(recordTimeLabel)
        contentView.addSubview(recordCreatorLabel)
        contentView.addSubview(recordIdLabel)
    }
    
    private func configureRecordHeadlineLabel() {
        recordNameLabel.textColor = UILabel.getPrimaryTextColor()
        recordNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        recordNameLabel.textAlignment = .left
        
        recordNameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            recordNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            recordNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    private func configureRecordId() {
        recordIdLabel.textColor = UILabel.getPrimaryTextColor()
        recordIdLabel.font = UIFont.systemFont(ofSize: 14)
        recordIdLabel.textAlignment = .left
        
        recordIdLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            recordIdLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            recordIdLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recordIdLabel.widthAnchor.constraint(equalToConstant: 120),
            recordIdLabel.bottomAnchor.constraint(equalTo: recordNameLabel.topAnchor, constant: -5)
        ])
    }
    
    private func configureRecordTimeStamp() {
        recordTimeLabel.textColor = UILabel.getSecondaryTextColor()
        recordTimeLabel.font = UIFont.systemFont(ofSize: 14)
        recordTimeLabel.textAlignment = .right
        recordTimeLabel.adjustsFontSizeToFitWidth = true
        
        recordTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            recordTimeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            recordTimeLabel.leadingAnchor.constraint(equalTo: recordIdLabel.trailingAnchor, constant: 10),
            recordTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            recordTimeLabel.bottomAnchor.constraint(equalTo: recordNameLabel.topAnchor, constant: -5)
        ])
    }
    
    private func configureRecordCreator() {
        recordCreatorLabel.textColor = UILabel.getPrimaryTextColor()
        recordCreatorLabel.font = UIFont.systemFont(ofSize: 14)
        recordCreatorLabel.textAlignment = .left
        
        recordCreatorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            recordCreatorLabel.widthAnchor.constraint(equalToConstant: 325),
            recordCreatorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recordCreatorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            recordCreatorLabel.topAnchor.constraint(equalTo: recordNameLabel.bottomAnchor, constant: 5)
        ])
    }

    func configure(with record: ResultSetRow) {
        recordNameLabel.text = record.values[1]
        recordIdLabel.text = record.values[0]
        recordTimeLabel.text = record.values[4]

        if record.values.count == 7 {
            recordCreatorLabel.text = "Creator: " + record.values[6]
        } else {
            recordCreatorLabel.text = "State: " + record.values[5]
        }
    }
}
