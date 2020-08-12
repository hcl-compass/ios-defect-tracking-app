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

class NotificationsManager {
    
    static let shared = NotificationsManager()
    private init() {}
    
    var folders: [Folder]!
    var queryDbId: String!
    var resultSetId: String!
    var currentRecords = [ResultSetRow]()
    var date = Date()
    var timeString: String!
    
    @objc func fireTimer() {
        getFolders()
    }
    
    func getTimestamp(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        timeString = formatter.string(from: date) // Format timestamp of last time query was created
    }
    
    func createNotification(notificationTitle: String) {
        let content = UNMutableNotificationContent()
        content.body = notificationTitle
        content.sound = UNNotificationSound.default
         
        // Configure the trigger for time interval.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (1), repeats: false)
         
        // Create the request object.
        let request = UNNotificationRequest(identifier: notificationTitle, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func configureNotifications(currentRecords: [ResultSetRow]) {
        for record in currentRecords {
            let defectTitle = "\(record.values[0]) (\(record.values[1])) "
            if record.values[3] == "Modify" {
                self.createNotification(notificationTitle: defectTitle + "has been modified")
            } else {
                self.createNotification(notificationTitle: defectTitle + "has been assigned to you")
            }
        }
    }
    
    func getFolders() {
        TRXNetworkManager.shared.getFolders() {
            [weak self] (result) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let rootFolders = data?.decode(to: [Folder].self) else { return }
                    self.folders = rootFolders
                    guard let personalFolder = self.locatePersonalFolder() else { return }
                    // Convert the date to a formatted String
                    self.getTimestamp(date: self.date)
                    self.createQuery(in: personalFolder.dbId, with: "Modified Defect", timeString: self.timeString)
                case .failure(let error):
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func createQuery(in parentFolderDbId: String, with name: String, timeString: String) {
        TRXNetworkManager.shared.createQueryNotifications(in: parentFolderDbId, named: name, timeString: timeString) {
            [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                   guard let queryDef = data?.decode(to: QueryDef.self) else { return }
                   self.queryDbId = queryDef.dbId
                   self.createResultSet(for: self.queryDbId)
                   // Update the date
                   self.date = Date()
                case .failure(let error):
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func createResultSet(for queryDbId: String) {
        TRXNetworkManager.shared.createResultSet(for: queryDbId) {
            [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let resultSet = data?.decode(to: ResultSet.self) else { return }
                    self.resultSetId = resultSet.resultSetId
                    self.getResultSet(of: self.resultSetId, for: self.queryDbId)
                case .failure(let error):
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func getResultSet(of resultSetId: String, for queryDbId: String) {
        TRXNetworkManager.shared.getResultSet(of: resultSetId, for: queryDbId) {
            [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.deleteQuery(for: self.queryDbId)
                    guard let resultSetPage = data?.decode(to: ResultSetPage.self) else { return }
                    self.currentRecords = resultSetPage.rows
                    // Update notification badge number
                    UIApplication.shared.applicationIconBadgeNumber = self.currentRecords.count
                    // Configure notifications
                    self.configureNotifications(currentRecords: self.currentRecords)
                    print(self.currentRecords)
                case .failure(let error):
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func deleteQuery(for queryDbId: String) {
        TRXNetworkManager.shared.deleteQuery(for: queryDbId) {
            result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    // Query deleted successfully
                    break
                case .failure(let error):
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    print(error.status)
                }
            }
        }
    }
    
    func queryDoesExist(named name: String) -> Bool {
        guard let personalFolder = locatePersonalFolder() else { fatalError() }
        for item in personalFolder.children {
            if item.name == name {
                queryDbId = item.dbId
                return true
            }
        }
        return false
    }
    
    func locatePersonalFolder() -> Folder? {
        for folder in folders {
            if folder.name == "Personal Queries" { return folder }
        }
        return nil
    }
}
