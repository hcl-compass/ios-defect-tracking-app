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

extension UILabel {
    static func getPrimaryTextColor() -> UIColor {
        if #available (iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }
    
    static func getSecondaryTextColor() -> UIColor {
        if #available (iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor(red: 0.60, green: 0.60, blue: 0.67, alpha: 0.85)
        }
    }
}

