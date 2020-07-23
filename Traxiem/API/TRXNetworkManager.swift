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

class TRXNetworkManager {
    
    static let shared = TRXNetworkManager()
    private let encoder = JSONEncoder()
    private init() {}
    
    // MARK: - Login API - /authenticate
    func login(with username: String, password: String, repo: String, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        let body: [String: String] = [ "username": username, "password": password, "repo": repo, "db": db ]
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
            var urlRequest = getUrlRequest(for: "/authenticate")
            urlRequest.httpBody = bodyData
            urlRequest.httpMethod = HttpMethod.post.rawValue
            NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
        } catch { return }
    }
    
    // MARK: - Logoff API - /authenticate/logoff
    func logoff(completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        var urlRequest = getUrlRequest(for: "/authenticate/logoff")
        urlRequest.httpMethod = HttpMethod.post.rawValue
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Repos API - /repos
    func getRepos(completion: @escaping(Result<Data?, ApiError>) -> Void) {
        var urlRequest = getUrlRequest(for: "/repos")
        urlRequest.httpMethod = HttpMethod.get.rawValue
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Folders API - /workspace/folders
    func getFolders(completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/workspace/folders")
        urlRequest.httpMethod = HttpMethod.get.rawValue
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Create Query API - /workspace/queryDefs
    func createQuery(in parentFolderDbId: String, named name: String, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        var queryDef = QueryDef.getQueryDefFromJson(named: name)
        queryDef.dbIdParent = parentFolderDbId
    
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/workspace/queryDefs")
        urlRequest.httpMethod = HttpMethod.post.rawValue
        urlRequest.httpBody = try! encoder.encode(queryDef)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Create Query Notifications API - /workspace/queryDefs
    func createQueryNotifications(in parentFolderDbId: String, named name: String, timeString: String, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        var queryDef = QueryDef.getQueryDefFromJson(named: name)
        queryDef.dbIdParent = parentFolderDbId
        
        // Set the timestamp for the query filter history.action_name
        queryDef.filterNode.fieldFilters[2].values = [timeString]
    
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/workspace/queryDefs")
        urlRequest.httpMethod = HttpMethod.post.rawValue
        urlRequest.httpBody = try! encoder.encode(queryDef)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Delete Query API - /workspace/queryDefs/{queryDbId}
    func deleteQuery(for queryDbId: String, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/workspace/queryDefs/\(queryDbId)")
        urlRequest.httpMethod = HttpMethod.delete.rawValue
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Create Result Set API - /workspace/queryDefs/{queryDbId}/resultsets
    func createResultSet(for queryDbId: String, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        let requestBody = ["pageSize": "999"]
        
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/workspace/queryDefs/\(queryDbId)/resultsets")
        urlRequest.httpMethod = HttpMethod.post.rawValue
        urlRequest.httpBody = try! encoder.encode(requestBody)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Get Result Set API - /workspace/queryDefs/{queryDbId}/resultsets/{result_set_id}
    func getResultSet(of resultSetId: String, for queryDbId: String, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/workspace/queryDefs/\(queryDbId)/resultsets/\(resultSetId)")
        urlRequest.httpMethod = HttpMethod.get.rawValue
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Get Record API - /records/defect/{recordId}
    func getRecord(with recordId: String, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/records/defect/\(recordId)")
        urlRequest.httpMethod = HttpMethod.get.rawValue
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Modify Record API - /records/defect/{recordId}?operation={operation}&actionName={actionName}
    func modifyRecord(with recordId: String, body: [String: [[String: String?]]], operation: String, actionName: String?, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        var parameters = [URLQueryItem(name: "operation", value: operation)]
        if let actionName = actionName { parameters.append(URLQueryItem(name: "actionName", value: actionName)) }
        
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/records/defect/\(recordId)", parameters: parameters)
        urlRequest.httpMethod = HttpMethod.patch.rawValue
        urlRequest.httpBody = try! encoder.encode(body)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Delete Record API - /records/defect/{recordId}?actionName={actionName}
    func deleteRecord(with recordId: String, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        let parameters = [URLQueryItem(name: "actionName", value: "Delete")]
        
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/records/defect/\(recordId)", parameters: parameters)
        urlRequest.httpMethod = HttpMethod.delete.rawValue
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Get Field API - /records/defect/{recordId}/fields{fieldName}
    func getField(of recordId: String, with fieldName: String, completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/records/defect/\(recordId)/fields/\(fieldName)")
        urlRequest.httpMethod = HttpMethod.get.rawValue
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Get Record Type API - /records/defect
    func getRecordType(completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/records/defect")
        urlRequest.httpMethod = HttpMethod.get.rawValue
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Create Record API - /records/defect?operation={operation}&actionName={actionName}
    func createRecord(completion: @escaping(Result<Data?, ApiError>) -> Void) {
        guard let token = KeychainHelper.getTokenFromKeychain() else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let repo = UserDefaults.standard.string(forKey: "repo") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        guard let db = UserDefaults.standard.string(forKey: "preferredDb") else {
            completion(.failure(.internalServerError("There was an error constructing the request.")))
            return
        }
        
        let parameters = [URLQueryItem(name: "operation", value: "Edit")]
        let body = [String: String]()
        
        var urlRequest = getUrlRequest(for: "/repos/\(repo)/databases/\(db)/records/defect/", parameters: parameters)
        urlRequest.httpMethod = HttpMethod.post.rawValue
        urlRequest.httpBody = try! encoder.encode(body)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        NetworkManager.shared.execute(request: urlRequest, withCompletion: completion)
    }
    
    // MARK: - Helper to create a URLRequest object w/ preferred URL + query params + endpoint path
    func getUrlRequest(for path: String, parameters: [URLQueryItem]? = nil) -> URLRequest {
        var baseUrlString = UserDefaults.standard.string(forKey: "preferredUrl") ?? "https://localhost:8190"
        baseUrlString = baseUrlString + "/ccmweb/rest" + path
        
        var components = URLComponents(string: baseUrlString)
        if let parameters = parameters { components?.queryItems = parameters }
        guard let url = components?.url else { fatalError() }
        
        return URLRequest(url: url)
    }
    
     // MARK: - Helper to create the proper response body structure for record modification
    func getModifiedFieldsBody(from fields: [String: String?]) -> [String: [[String: String?]]] {
        var modifiedFieldsBody = [String: [[String: String?]]]()
        modifiedFieldsBody["fields"] = [[String: String?]]()
        
        for field in fields {
            let field = ["name": field.key, "value": field.value]
            modifiedFieldsBody["fields"]?.append(field)
        }
        
        return modifiedFieldsBody
    }
}
