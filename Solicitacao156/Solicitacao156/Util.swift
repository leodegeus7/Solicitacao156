//
//  Util.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 20/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class Util: NSObject {
    static func createMessageAlertController(title:String,message:String?,okMessage:String,viewController:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: okMessage, style: .default, handler: { action in

        }))
        
        viewController.present(alert, animated: true)
    }
}
