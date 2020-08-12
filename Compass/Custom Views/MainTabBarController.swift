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

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [UINavigationController(rootViewController: createAssignedToMeVC()), UINavigationController(rootViewController: createOpenedByMeVC())]
        modalPresentationStyle = .fullScreen
        setBackgroundColor()
    }
    
    private func createAssignedToMeVC() -> RecordListVC {
        let assignedToMeVC = RecordListVC()
        assignedToMeVC.title = "Assigned To Me"
        
        if #available(iOS 13.0, *) {
            assignedToMeVC.tabBarItem = UITabBarItem(title: "Assigned To Me", image: UIImage(systemName: "person.fill"), tag: 0)
        } else {
            assignedToMeVC.tabBarItem = UITabBarItem(title: "Assigned To Me", image: UIImage(named: "assignedPerson"), tag: 0)
        }
        
        return assignedToMeVC
    }
    
    private func createOpenedByMeVC() -> RecordListVC {
        let openedByMeVC = RecordListVC()
        openedByMeVC.title = "Reported By Me"
        
        if #available(iOS 13.0, *) {
            openedByMeVC.tabBarItem = UITabBarItem(title: "Reported By Me", image: UIImage(systemName: "person.badge.plus.fill"), tag: 1)
        } else {
            openedByMeVC.tabBarItem = UITabBarItem(title: "Reported By Me", image: UIImage(named: "openedPerson"), tag: 1)
        }
        
        return openedByMeVC
    }
}
