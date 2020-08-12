//
//  PickerCell.swift
//  Traxiem
//
//  Created by Rosalba Monterrosas on 2/28/20.
//  Copyright © 2020 Brett Markowitz. All rights reserved.
//

import UIKit

class RecordFieldPickerCell: RecordFieldCell {
    
    static let reuseIdentifier = "PickerCell"
    var pickerView = UIPickerView()
    var dataSource = PickerDataSource()
    
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       super.init(style: style, reuseIdentifier: reuseIdentifier)
       configureDropDownPickerView()
   }
   
   required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func configureDropDownPickerView() {
        dataSource.delegate = self
//        fieldValueTextView.addSubview(pickerView)
        pickerView.showsSelectionIndicator = true
        fieldValueTextView.inputView = pickerView
        pickerView.dataSource = dataSource
        pickerView.delegate = dataSource

        

//        pickerView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            pickerView.trailingAnchor.constraint(equalTo: fieldValueTextView.trailingAnchor),
//            pickerView.leadingAnchor.constraint(equalTo: fieldValueTextView.leadingAnchor),
//            pickerView.topAnchor.constraint(equalTo: fieldValueTextView.topAnchor),
//            pickerView.bottomAnchor.constraint(equalTo: fieldValueTextView.bottomAnchor)
//        ])
    }

}

