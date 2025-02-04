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

struct QueryFieldDef: Model {
    var fieldPathName: String
    var isShown: Bool
    var sortType: String?
}

extension QueryFieldDef: Codable {
    enum CodingKeys: String, CodingKey {
        case fieldPathName
        case isShown
        case sortType
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy:
          CodingKeys.self)
        self.fieldPathName = try valueContainer.decode(String.self, forKey:
          CodingKeys.fieldPathName)
        self.isShown = try valueContainer.decode(Bool.self,
          forKey: CodingKeys.isShown)
        self.sortType = try valueContainer.decode(String.self,
        forKey: CodingKeys.sortType)
    }
}
