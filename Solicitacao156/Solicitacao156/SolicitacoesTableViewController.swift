//
//  SolicitacoesTableViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 11/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import Firebase

class SolicitacoesTableViewController: UITableViewController {

    var requisitions = [Requisition]()
    var selectedRow:Requisition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Solicitações"
        
        let addIcon = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(SolicitacoesTableViewController.addNewRequisition))
        self.navigationItem.rightBarButtonItem = addIcon
        
        let reference = Database.database()
        let usersRef = reference.reference(withPath: "users")
        let myUser = usersRef.child("\(Singleton.shared.user.uid)")
        let ref = myUser.child("requisiton")
        
        
        ref.observe(DataEventType.value, with: { (snapshot) in
            self.requisitions = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    var requisition = Requisition()
                    requisition.numberId = Int(snapshot.key)!
                    for child in snapshot.children {
                        if let snapshotDate = child as? DataSnapshot {
                            if snapshotDate.key == "date" {
                                requisition.date = Date(timeIntervalSince1970: Double(truncating: snapshotDate.value as! NSNumber))
                            }
                        }
                        
                    }
                    
                    self.requisitions.append(requisition)
                }
            }
            self.requisitions = self.requisitions.sorted(by: {$0.date > $1.date})
            self.tableView.reloadData()
        })

    }
    
    @objc func addNewRequisition() {
        createAlert()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let requisition = requisitions[indexPath.row]
            let databaseHelper = DatabaseHelper()
            databaseHelper.removeRequisition(requisition: requisition)
        }
    }
    
    func createAlert() {
        let alert = UIAlertController(title: "Add", message: "Add solicitacao", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            textField.placeholder = "Digite a solicitacao"
        }
 
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if let num = self.validateIdRequisition(string: (textField?.text!)!) {
                DispatchQueue.main.async {
                    var requisiton = Requisition()
                    requisiton.numberId = num
                    self.testIfRequisitionExist(requisition: requisiton, completion: { (bool) in
                        if bool {
                            let database = DatabaseHelper()
                            _ = database.addRequisiton(requisition:requisiton)
                        } else {
                            Util.createMessageAlertController(title: "Atenção", message: "Não há registros desta requisição em nossos servidores, tente digitar outro ID", okMessage: "Ok", viewController: self)
                        }
                    })
                }
            } else {
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (alert) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func testIfRequisitionExist(requisition:Requisition,completion: @escaping (_ result: Bool) -> Void) {
        let network = NetworkSetup()
        network.getRequisition(requisition: requisition) { (entries) in
            if (entries?.count)! > 0 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let controller = segue.destination as? EntriesTableViewController
            controller?.requisition = self.selectedRow
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = requisitions[indexPath.row]
        performSegue(withIdentifier: "showDetails", sender: self)
    }
    
    func validateIdRequisition(string:String) -> Int? {
        let num = Int(string)
        if num != nil {
            return num
        }
        else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requisitions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSolicitacao", for: indexPath) as? SolicitacoesCellTableViewCell
        cell?.numberLabel.text = "\(requisitions[indexPath.row].numberId)"

        return cell!
    }


}
