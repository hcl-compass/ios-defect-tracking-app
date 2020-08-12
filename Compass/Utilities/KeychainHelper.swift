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

class KeychainHelper {
    
    static func addTokenToKeychain(_ authToken: AuthToken) {
        let status = KeychainHelper.addStringToKeychain(key: "token", value: authToken.token)
        if status != noErr {
            fatalError()
        }
    }
    
    static func getTokenFromKeychain() -> String? {
        guard let data = KeychainHelper.getStringFromKeychain(key: "token") else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func removeTokenFromKeychain() {
        guard let token = getTokenFromKeychain() else { return }
        let status = KeychainHelper.removeStringFromKeychain(key: "token", value: token)
        if status != noErr {
            fatalError()
        }
    }
    
    private static func addStringToKeychain(key: String, value: String) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: Data(value.utf8)
        ] as [String: Any]
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)

        return status
    }
    
    private static func getStringFromKeychain(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject? = nil
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    private static func removeStringFromKeychain(key: String, value: String) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: Data(value.utf8)
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        return status
    }
}
