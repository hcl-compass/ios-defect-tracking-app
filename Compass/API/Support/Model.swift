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

import Foundation

protocol Model: Codable {
}

extension Model {
    func toDictionary() -> [String: Any]? {
        let jsonEncoder = JSONEncoder()
        let jsonString = String(data: try! jsonEncoder.encode(self), encoding: .utf8)
        let requestBody = try! JSONSerialization.jsonObject(with: jsonString!.data(using: .utf8)!, options: []) as! [String: Any]
        
        return requestBody
    }
}
