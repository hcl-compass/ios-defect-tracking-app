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

enum RecordDetailSection: Int, CaseIterable {
    case first
    case second
    case third
    case fourth
    
    var rows: [RecordDetailRow] {
        switch self {
        case .first:
            return [.headline, .description, .state, .project]
        case .second:
            return [.owner, .submitter, .submitDate]
        case .third:
            return [.priority, .severity]
        case .fourth:
            return [.resolution]
        }
    }
}

enum RecordDetailRow: String {
    case headline = "Headline"
    case description = "Description"
    case state = "State"
    case project = "Project"
    case owner = "Owner"
    case submitter = "Submitter"
    case submitDate = "Submit_Date"
    case priority = "Priority"
    case severity = "Severity"
    case resolution = "Resolution"
}
