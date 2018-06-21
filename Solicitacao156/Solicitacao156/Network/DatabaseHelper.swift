//
//  DatabaseHelper.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 11/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import Firebase

class DatabaseHelper: NSObject {
    
    func update(cep:String) -> Bool {
        return updateFieldOfUser(dictionary: ["cep":cep])
    }
    
    func update(mail:String) -> Bool {
        return updateFieldOfUser(dictionary: ["mail":mail])
    }
    
    func update(fone:String) -> Bool {
        return updateFieldOfUser(dictionary: ["fone":fone])
    }
    
    func add(device:String) -> Bool {
        return addDevice(device: device)
    }
    
    func update(cpf:String) -> Bool {
        return updateFieldOfUser(dictionary: ["cpf":cpf])
    }
    
    func update(name:String) -> Bool {
        return updateFieldOfUser(dictionary: ["name":name])
    }

    func update(photo:String) -> Bool {
        return updateFieldOfUser(dictionary: ["photo":photo])
    }

    private func addDevice(device:String) -> Bool {
        
        if let _ = Singleton.shared.user {
            var ref: DatabaseReference!
            
            ref = Database.database().reference()
            let user = ref.child("users/\(Singleton.shared.user.uid)")
            let devices = user.child("devices")
            devices.child(device).setValue("")
            return true
        } else {
            return false
        }
    }
    
    private func updateFieldOfUser(dictionary:Dictionary<String,String>) -> Bool {
        
        if let _ = Singleton.shared.user {
            var ref: DatabaseReference!
            
            ref = Database.database().reference()
            
            for (key,value) in dictionary {
                ref.child("users/\(Singleton.shared.user.uid)/\(key)").setValue(value)
            }
            return true
        } else {
            return false
        }
    }
    
    func addRequisiton(requisition:Requisition, firstDate:String) -> Bool {
        if let _ = Singleton.shared.user {
            let ref = Database.database()
            let usersRef = ref.reference(withPath: "users")
            let myUser = usersRef.child("\(Singleton.shared.user.uid)")
            let requisitonArray = myUser.child("requisiton")
            let array = ["date":Date().timeIntervalSince1970,"firstDate":firstDate] as [String : Any]
            requisitonArray.child("\(requisition.numberId)").setValue(array)
            return true
        } else {
            return false
        }
    }
    
    func removeRequisition(requisition:Requisition) -> Bool {
        if let _ = Singleton.shared.user {
            let ref = Database.database()
            let usersRef = ref.reference(withPath: "users")
            let myUser = usersRef.child("\(Singleton.shared.user.uid)")
            let requisitonId = myUser.child("requisiton/\(requisition.numberId)")
            requisitonId.removeValue()
            return true
        } else {
            return false
        }
    }
    
}
