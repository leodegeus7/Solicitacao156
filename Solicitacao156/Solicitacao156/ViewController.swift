//
//  ViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 09/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseFacebookAuthUI

class ViewController: UIViewController,FUIAuthDelegate {

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
        
        let token = getActualToken()
        if let _ = token {
            print(token!)
        } else {
            let authViewController = authUI!.authViewController()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(authViewController, animated: true, completion: nil)
            }
        }


    }

    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        if let user = user {
            print(user)
            user.getIDToken { (token, error) in
                print(token!)
                self.createOrUpdateKeyChainAccount(token!, completion: { (token) in
                    print(token)
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

