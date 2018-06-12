//
//  EntriesTableViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 19/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import FirebasePerformance

class EntriesTableViewController: UITableViewController {

    var requisition:Requisition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Protocolo: \(requisition.numberId)"
        
        let network = NetworkSetup()
        let trace = Performance.startTrace(name: "test trace")
        activityIndicator(true)
        network.getRequisition(requisition:requisition, completion: { (result) in
            if let entries = result {
                trace?.incrementMetric("Requisition", by: 1)
                trace?.stop()
                self.requisition.entries = entries
                DispatchQueue.main.async {
                    self.activityIndicator(false)
                    self.tableView.reloadData()
                }
            } else {
                
            }
        })
    }
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    func activityIndicator(_ bool:Bool) {
        if bool {
            spinner.color = UIColor.black.withAlphaComponent(0.8)
            spinner.frame = self.view.frame
            spinner.startAnimating()
            self.view.addSubview(spinner)
        } else {
            spinner.removeFromSuperview()
        }
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
        dateFormatter.dateFormat = "dd/MM/yyyy - HH:mm"
        let string = dateFormatter.string(from: requisition.entries[indexPath.row].date)
        cell?.dateLabel.text = string
        cell?.descriptionLabel.text = requisition.entries[indexPath.row].description
        cell?.selectionStyle = .none

        return cell!
    }
 

}
