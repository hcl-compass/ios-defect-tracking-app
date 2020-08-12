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
import UIKit

enum HttpMethod: String {
    case get
    case post
    case put
    case patch = "PATCH"
    case delete
}

class NetworkManager {
    static let shared = NetworkManager()
    static let session = URLSession(configuration: .default, delegate: ApiSessionDelegate(), delegateQueue: .main)
    
    private init() {}
    
    func execute(request: URLRequest, withCompletion completion: @escaping(Result<Data?, ApiError>) -> Void) {
        var request = request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        NetworkManager.session.dataTask(with: request) {
            (data, urlResponse, error) in
            
            if let error = error {
                // Present an alert message if the API send request times out
                if error._code == NSURLErrorTimedOut {
                    self.presentAlertController(with: "Error", message: "The request timed out")
                }
                completion(.failure(.error(nil)))
            }
            guard let responseCode = urlResponse?.statusCode() else { return }

            switch responseCode {
            case 200...201:
                completion(.success(data))
            case 204:
                completion(.success(nil))
            case 400...499:
                completion(.failure(.error(data)))
            default:
                completion(.failure(.error(data)))
            }
        }.resume()
    }
    
    func presentAlertController(with title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Find the top ViewController on the navigation stack 
        let topController = UIApplication.topViewController()
        topController?.present(alertVC, animated: true)
    }
}
