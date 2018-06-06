//
//  NetworkSetup.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 20/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class NetworkSetup: NSObject {
    
    var serverLink = "http://solicitacao156.herokuapp.com/"
    
    func getRequisition(requisition:Requisition,completion: @escaping (_ entries: [Entry]?) -> Void) {
        
        let url = URL(string: "\(serverLink)solicitacao/\(requisition.numberId)")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    var entries = [Entry]()
                    if let results = json["result"] as? [NSArray] {
                        for result in results {
                            let date = result[0] as! String
                            let hour = result[1] as! String
                            let newStringDate = "\(hour) \(date)"
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
                            let newDate = dateFormatter.date(from: newStringDate)
                            
                            let description = result[2] as! String
                            let entry = Entry(date:newDate,description:description)
                            entries.append(entry)
                        }
                        entries = entries.sorted(by: {$0.date < $1.date})
                    }
                    completion(entries)
                    
                }
            } catch let error {
                print(error.localizedDescription)
                completion(nil)
            }
            
        }
        
        task.resume()
    }
}
