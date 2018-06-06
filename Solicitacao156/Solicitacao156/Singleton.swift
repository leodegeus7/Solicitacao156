//
//  Singleton.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 10/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import Firebase

class Singleton: NSObject {
    static let shared = Singleton()
    
    var user:User!
    
}
