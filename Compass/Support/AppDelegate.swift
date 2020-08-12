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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 13.0, *) {} else {
            window = UIWindow(frame: UIScreen.main.bounds)
            
            setLoginVC()
            if let lastLogin = UserDefaults.standard.object(forKey: "last_login") as? Date {
                if let diff = Calendar.current.dateComponents([.hour], from: lastLogin, to: Date()).hour, diff <= 23 {
                    window?.rootViewController?.present(MainTabBarController(), animated: true)
                }
            }
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            UNUserNotificationCenter.current().delegate = self
                        
            // Set background fetch to every 5 minutes
            application.setMinimumBackgroundFetchInterval(5*60)
            // Set foreground timer to every 5 minutes
            Timer.scheduledTimer(timeInterval: 5*60, target: NotificationsManager.shared, selector: #selector(NotificationsManager.shared.fireTimer), userInfo: nil, repeats: true)
        }
        return true
    }
    
    private func setLoginVC() {
        window?.rootViewController = UINavigationController(rootViewController: LoginVC())
        window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completionHandler(.newData)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Update notification badge number
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Update notification badge number
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
}

