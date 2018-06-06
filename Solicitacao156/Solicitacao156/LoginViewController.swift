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

class LoginViewController: UIViewController,FUIAuthDelegate {
    
    fileprivate(set) var auth:Auth?
    fileprivate(set) var authUI: FUIAuth?
    fileprivate(set) var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.auth = Auth.auth()
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIFacebookAuth()
        ]
        self.authUI?.providers = providers
        
        testUserAndPass()
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
            Singleton.shared.user = user
            updateUser()
            user.getIDToken { (token, error) in
                print(token!)
                self.createOrUpdateKeyChainAccount(user.refreshToken!, completion: { (token) in
                })
            }
        }
        
        guard let authError = error else { return }
        
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
    
    func testUserAndPass() {
        let token = getActualToken()
        
        if let _ = token {
            let user = self.auth?.currentUser
            if let user = user {
                Singleton.shared.user = user
                self.performSegue(withIdentifier: "segueDetail", sender: self)
                user.getIDToken(completion: { (token, error) in
                    self.updateUser()
                    self.createOrUpdateKeyChainAccount(token!, completion: { (token) in
                        
                    })
                    
                })
                
                
                
            }
        } else {
            let authViewController = authUI!.authViewController()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(authViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func signOutTap(_ sender: Any) {
        signOut { (bool) in
            if bool {
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

