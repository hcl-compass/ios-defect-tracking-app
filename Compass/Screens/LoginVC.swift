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

class LoginVC: UIViewController {
    
    var logoImageView = UIImageView()
    var loginTableVC = LoginTableVC()
    var loginButton = TRXButton(backgroundColor: .systemBlue, title: "Log in")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureLogoImageView()
        configureLoginTableView()
        configureLoginButton()
        configureDismissKeyboardTapGesture()
    }
    
    @objc func settingsTapped() {
        present(UINavigationController(rootViewController: SettingsVC()), animated: true)
    }

    @objc func login(_ usernameText: String, _ passwordText: String) {
        TRXNetworkManager.shared.login(with: usernameText, password: passwordText, repo: loginTableVC.getRepo()) {
            [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let token = data?.decode(to: AuthToken.self) else { return }
                    KeychainHelper.addTokenToKeychain(token)
                    self?.didFinishAuthenticating()
                case .failure(let error):
                    guard let error = error.data()?.decode(to: ErrorResponse.self) else { return }
                    self?.loginButton.isEnabled = true
                    self?.presentAlertController(with: "Error", message: error.message)
                }
            }
        }
    }
    
    @objc func loginButtonTapped() {
        guard let usernameText = loginTableVC.getUsername() else { return }
        guard let passwordText = loginTableVC.getPassword() else { return }
        
        loginButton.isEnabled = false
        login(usernameText, passwordText)
    }
    
    func didFinishAuthenticating() {
        UserDefaults.standard.set(loginTableVC.getUsername(), forKey: "username")
        UserDefaults.standard.set(loginTableVC.selectedRepo, forKey: "repo")
        UserDefaults.standard.set(Date(), forKey: "last_login")
        
        present(MainTabBarController(), animated: true) {
            [weak self] in
            self?.loginTableVC.resetLogin()
            self?.loginButton.isEnabled = false
        }
    }
    
    private func configureViewController() {
        setBackgroundColor()
        navigationController?.setTransparentNavigationBar()
        if #available(iOS 13.0, *) {
            navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsTapped)), animated: true)
        } else {
            navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: self, action: #selector(settingsTapped)), animated: true)
        }
    }
    
    private func configureLogoImageView() {
        view.addSubview(logoImageView)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "logo")
        logoImageView.sizeToFit()
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func configureLoginTableView() {
        loginTableVC.delegate = self
        view.addSubview(loginTableVC.view)
        
        NSLayoutConstraint.activate([
            loginTableVC.view.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            loginTableVC.view.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            loginTableVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
    
    private func configureLoginButton() {
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: loginTableVC.view.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            loginButton.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension LoginVC: LoginTableVCDelegate {
    func loginButtonStateShouldChange(to enabled: Bool) {
        if enabled { loginButton.isEnabled = true }
        else { loginButton.isEnabled = false }
    }
    
    func didTapRepoCell() {
        let repoSelectionVC = RepoSelectionVC(selectedRepo: loginTableVC.getRepo())
        repoSelectionVC.delegate = self.loginTableVC
        present(UINavigationController(rootViewController: repoSelectionVC), animated: true)
    }
    
    func didTapDatabaseCell() {
        presentAlertController(with: "Coming soon", message: "This doesn't do anything yet.")
    }
}
