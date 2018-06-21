//
//  Rating.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 13/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class Rating {
    var informacao = 0
    var navegacao = 0
    var visual = 0
    var utilidade = 0
    var total = 0
    
    func getDic() -> NSDictionary {
        return ["informacao":informacao,"navegacao":navegacao,"visual":visual,"utilidade":utilidade,"total":total]
    }
}
