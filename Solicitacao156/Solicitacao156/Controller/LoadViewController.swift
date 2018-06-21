//
//  LoadViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 08/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAuth
import SystemConfiguration

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}

class LoadViewController: UIViewController {
    fileprivate(set) var auth:Auth?
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork(){
            wakeUpServer()
            getToken { (bool) in
                self.updateData { (bool) in
                    if bool {
                        let mainController = MainTabBarController()
                        self.present(mainController, animated: true) {
                            
                        }
                    }
                }
            }
        } else {
            Util.createMessageAlertController(title: "Atenção", message: "Parece que seu celular não esta conectado na internet, conecte para abrir o aplicativo.", okMessage: "Ok", viewController: self)
        }
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getToken(completion: @escaping (_ token: Bool?) -> Void) {
        let token = getActualToken()
        
        if let _ = token {
            self.auth = Auth.auth()
            let user = self.auth?.currentUser
            if let user = user {
                Singleton.shared.user = user
                user.getIDToken(completion: { (token, error) in
                    
                    if let _ = error {
                        print(error!.localizedDescription)
                        Util.createMessageAlertController(title: "Atenção", message: "Tivemos problemas ao conectar aos nossos servidores", okMessage: "Ok", viewController: self)
                    } else {
                        self.updateUser()
                        self.createOrUpdateKeyChainAccount(token!, completion: { (token) in
                            completion(true)
                        })
                    }
                })
                
                
                
            } else {
                completion(false)
            }
        } else {
            do {
                try auth?.signOut()
            } catch {
                print("Não possivel em deslogar")
            }
            completion(false)
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
    
    func wakeUpServer() {
        let network = NetworkSetup()
        var re = Requisition()
        re.numberId = 1
        network.getRequisition(requisition: re) { (_) in
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
    
    func updateData(completion: @escaping (_ result: Bool) -> Void) {
        let remoteConfig = RemoteConfig.remoteConfig()
        let appDefaults: [String: Any?] = [
            "color" : "169.197.79"
        ]
        remoteConfig.setDefaults(appDefaults as? [String: NSObject])
        
        var expirationDuration = 43200;
        
        if (remoteConfig.configSettings.isDeveloperModeEnabled)
        {
            expirationDuration = 0
        }
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration), completionHandler: { (status, error) in
            if status == .success {
                print("Config fetched!")
                remoteConfig.activateFetched()
                self.retrieveFunction(remoteConfig: remoteConfig)
                self.activateColor()
                completion(true)
            }
            else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
                completion(false)
            }
            
        })
    }

    func retrieveFunction(remoteConfig:RemoteConfig) {
        let colorString = remoteConfig.configValue(forKey: "color").stringValue
        
        if let colorString = colorString {
            let array = colorString.components(separatedBy: ".")
            if array.count == 3 {
                let color = UIColor(red: CGFloat((array[0] as NSString).doubleValue)/CGFloat(255.0), green: CGFloat((array[1] as NSString).doubleValue)/CGFloat(255.0), blue: CGFloat((array[2] as NSString).doubleValue)/CGFloat(255.0), alpha: 1)
                Constants.color = color
                print(color)
            }
        }
        
    }
    
    func activateColor() {
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().barTintColor = Constants.color
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        UITabBar.appearance().barTintColor = Constants.color
        UITabBar.appearance().tintColor = UIColor.white
    }

}
