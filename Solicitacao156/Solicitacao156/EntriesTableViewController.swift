//
//  EntriesTableViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 19/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class EntriesTableViewController: UITableViewController {

    var requisition:Requisition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let network = NetworkSetup()
        network.getRequisition(requisition:requisition, completion: { (result) in
            if let entries = result {
                self.requisition.entries = entries
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                
            }
        })
        
       
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requisition.entries.count
    }
    

    
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? EntriesTableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy - hh:mm"
        let string = dateFormatter.string(from: requisition.entries[indexPath.row].date)
        cell?.dateLabel.text = string
        cell?.descriptionLabel.text = requisition.entries[indexPath.row].description

        return cell!
    }
 

}
