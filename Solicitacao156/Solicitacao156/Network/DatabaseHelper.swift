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
    
    func update(cpf:String) -> Bool {
        return updateFieldOfUser(dictionary: ["cpf":cpf])
    }
    
    func update(name:String) -> Bool {
        return updateFieldOfUser(dictionary: ["name":name])
    }

    func update(photo:String) -> Bool {
        return updateFieldOfUser(dictionary: ["photo":photo])
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
    
    func addRequisiton(requisition:Requisition) -> Bool {
        if let _ = Singleton.shared.user {
            let ref = Database.database()
            let usersRef = ref.reference(withPath: "users")
            let myUser = usersRef.child("\(Singleton.shared.user.uid)")
            let requisitonArray = myUser.child("requisiton")
            let array = ["date":Date().timeIntervalSince1970]
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
