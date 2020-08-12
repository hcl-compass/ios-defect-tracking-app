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

struct QueryDef: Model {
    var name: String
    var dbId: String
    var dbIdParent: String
    var primaryEntityDefName: String
    var queryFieldDefs: [QueryFieldDef]
    var filterNode: FilterNode
}

extension QueryDef: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case dbId
        case dbIdParent
        case primaryEntityDefName
        case queryFieldDefs
        case filterNode
    }
    
    static func getQueryFileName(for name: String) -> String {
        let newTitle = name.replacingOccurrences(of: " ", with: "")
        return newTitle.lowercased()
    }
    
    static func getQueryDefFromJson(named name: String) -> QueryDef {
        let fileName = getQueryFileName(for: name)
        
        let path = Bundle.main.path(forResource: fileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let jsonDecoder = JSONDecoder()
        let queryDef = try! jsonDecoder.decode(QueryDef.self, from: data)
        
        return queryDef
    }
}
