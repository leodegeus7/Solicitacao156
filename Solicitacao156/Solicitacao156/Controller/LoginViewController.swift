//
//  ViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 09/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import Kingfisher

class LoginViewController: UIViewController,FUIAuthDelegate {
    
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    fileprivate(set) var auth:Auth?
    fileprivate(set) var authUI: FUIAuth?
    fileprivate(set) var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageUser.layer.cornerRadius = imageUser.frame.height/2
        imageUser.layer.masksToBounds = true
        imageUser.layer.borderColor = Constants.color.cgColor
        imageUser.layer.borderWidth = 2
        
        
        logoutButton.backgroundColor = Constants.color
        updateButton.backgroundColor = Constants.color
        
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
        updateButton.layer.cornerRadius = logoutButton.frame.height / 2
        
        logoutButton.setTitleColor(UIColor.white, for: .normal)
        updateButton.setTitleColor(UIColor.white, for: .normal)
        
        self.auth = Auth.auth()
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIFacebookAuth()
        ]
        self.authUI?.providers = providers
        backView.backgroundColor = Constants.color
        
        
        let navigationBar = navigationController!.navigationBar
        navigationBar.barTintColor = Constants.color
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
        activityIndicator(true)
        updateViewWithProfile()
        testUserAndPass()
        
        
        
    }
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    func activityIndicator(_ bool:Bool) {
        if bool {
            spinner.color = UIColor.black
            spinner.frame = self.view.frame
            spinner.startAnimating()
            self.view.addSubview(spinner)
        } else {
            spinner.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.authIsOpen {
            self.authIsOpen = false
            self.navigationController?.popViewController(animated: false)
            
        }
    }
    
    func updateViewWithProfile() {
        if let _ = Singleton.shared.user {
            
            var ref: DatabaseReference!
            
            ref = Database.database().reference()
            ref.child("users").child("\(Singleton.shared.user.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let name = value?["name"] as? String ?? ""
                let email = value?["mail"] as? String ?? ""
                let pic = value?["photo"] as? String ?? ""
                DispatchQueue.main.async {
                    self.activityIndicator(false)
                    self.nameLabel.text = name
                    self.emailLabel.text = email
                    if pic != "" {
                        let url = URL(string:pic + "?type=large&width=720&height=720")
                        if let url = url {
                            let resource = ImageResource(downloadURL: url)
                            let image = UIImage(named: "no-photo-user.png")
                            self.imageUser.kf.setImage(with: resource, placeholder: image, options: [], progressBlock: nil, completionHandler: nil)
                        }
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func updateUser() {
        if let user = Singleton.shared.user {
            let database = DatabaseHelper()
            if let _ = user.email {
                _ = database.update(mail: user.email!)
            }
            if let _ = user.displayName {
                _ = database.update(name: user.displayName!)
            }
            if let _ = user.phoneNumber {
                _ = database.update(fone: user.phoneNumber!)
            }
            if let _ = user.photoURL {
                _ = database.update(photo: (user.photoURL?.absoluteString)!)
            }
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            self.authIsOpen = false
            Singleton.shared.user = user
            updateUser()
            user.getIDToken { (token, error) in
                print(token!)
                self.createOrUpdateKeyChainAccount(user.refreshToken!, completion: { (token) in
                    self.updateViewWithProfile()
                })
            }
        }
        
        guard let authError = error else {
            return
        }
        
        let errorCode = UInt((authError as NSError).code)
        
        switch errorCode {
        case FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in");
            break
            
        default:
            let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
            print("Login error: \((detailedError as! NSError).localizedDescription)");
        }
    }
    
    func segueToMain() {
        let mainController = MainTabBarController()
        self.present(mainController, animated: true) {
            
        }
        
    }
    
    func testUserAndPass() {
        let token = getActualToken()
        
        if let _ = token {
            let user = self.auth?.currentUser
            if let user = user {
                Singleton.shared.user = user
                user.getIDToken(completion: { (token, error) in
                    self.updateUser()
                    self.createOrUpdateKeyChainAccount(token!, completion: { (token) in
                    })
                })
            }
        } else {
            let authViewController = authUI!.authViewController()
            self.authIsOpen = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(authViewController, animated: false, completion: nil)
            }
        }
    }
    
    var authIsOpen = false
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signOutTap(_ sender: Any) {
        signOut { (bool) in
            if bool {
                self.navigationController?.popViewController(animated: true)
                print("Signout")
            } else {
                print("Error in Signout")
            }
        }
    }
    
    
    public func signOut(completion: (_ result: Bool) -> Void) {
        clearKeyChain { (bool) in
            if bool {
                do {
                    try authUI?.signOut()
                    completion(bool)
                } catch {
                    completion(false)
                }
            } else {
                completion(bool)
            }
        }
    }
    
    ////////////////////////////////////
    // MARK: KeyChain Methods
    ////////////////////////////////////
    
    public func createOrUpdateKeyChainAccount(_ value: String, completion: (_ token: String?) -> Void) {
        do {
            let tokenItem = KeychainTokenItem(service: KeychainConfiguration.serviceName, account: Constants.appAccountName, accessGroup: KeychainConfiguration.accessGroup)
            try tokenItem.saveToken(value)
            completion(value)
        }
        catch {
            completion(nil)
        }
    }
    
    public func getActualToken() -> String? {
        do {
            let tokenItem = KeychainTokenItem(service: KeychainConfiguration.serviceName, account: Constants.appAccountName, accessGroup: KeychainConfiguration.accessGroup)
            let token = try tokenItem.readToken()
            return token
        }
        catch {
            return nil
        }
    }
    
    public func clearKeyChain(completion: (_ result: Bool) -> Void) {
        do {
            let tokenItem = KeychainTokenItem(service: KeychainConfiguration.serviceName, account: Constants.appAccountName, accessGroup: KeychainConfiguration.accessGroup)
            try tokenItem.deleteItem()
            completion(true)
        }
        catch {
            completion(false)
        }
    }
    
}

