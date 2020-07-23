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

extension UIViewController {
    @objc func dismissVc() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setBackgroundColor() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
        } else {
            view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1)
        }
    }
    
    func presentAlertController(with title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true)
    }
    
    func presentUnsavedChangesAlertController(completion: @escaping (UIAlertAction?) -> Void) {
        let alertVC = UIAlertController(title: "You have unsaved changes.", message: "Do you want to discard them?", preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Discard", style: .destructive) {
            result in
            completion(result)
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default) {
            [weak alertVC] (_) in
            alertVC?.dismiss(animated: true)
        })
        
        present(alertVC, animated: true)
    }
    
    func presentDeleteAlertController(completion: @escaping (UIAlertAction?) -> Void) {
        let alertVC = UIAlertController(title: nil, message: "Are you sure you want to delete this record?", preferredStyle: .actionSheet)
        
        alertVC.addAction(UIAlertAction(title: "Delete", style: .destructive) { result in
            completion(result)
        })
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
            [weak alertVC] (_) in
            alertVC?.dismiss(animated: true)
        })
        present(alertVC, animated: true)
    }
    
    func configureDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
