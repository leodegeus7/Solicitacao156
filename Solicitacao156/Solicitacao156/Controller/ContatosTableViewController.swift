//
//  ContatosTableViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 06/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class ContatosNavigationTableViewController : UINavigationController {
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "ContatosTableView") as? ContatosTableViewController
        self.pushViewController(firstViewController!, animated: true)
    }
}

class ContatosTableViewController: UITableViewController {

    var contacts = [(key:String,value:[Contact])]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Contatos Úteis"
        if let data = getData() {
            let dic = Dictionary(grouping: data, by: {item in item.category }).sorted(by: { $0.key < $1.key })
            
            contacts = dic
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getData() -> [Contact]? {
        if let path = Bundle.main.path(forResource: "Fones", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, [Any]>, let dataPoints = jsonResult["data"] as? [Dictionary<String,String>] {
                    var contacts = [Contact]()
                    for point in dataPoints {
                        let contact = Contact(name: point["name"]!, category: point["category"]!, address: point["address"]!, fone: point["fone"]!)
                        contacts.append(contact)
                    }
                    return contacts
                } else {
                    return nil
                }

            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)! as! ContatosTableViewCell
        selectedCell.contentView.backgroundColor = Constants.color.withAlphaComponent(0.1)
        let contact = contacts[indexPath.section].value[indexPath.row]
        
        showDetailView(contact: contact)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for cell in tableView.visibleCells {
                cell.contentView.backgroundColor = UIColor.white
            }
        }
        

    }
    
    var detailView:CardView!
    
    func showDetailView(contact:Contact) {
        let myClassNib = UINib(nibName: "CardView", bundle: nil)
        let myView =  myClassNib.instantiate(withOwner: nil, options: nil)[0] as! CardView
        myView.contatosSuper = self
        myView.contact = contact
        let window = UIApplication.shared.keyWindow!
        
        myView.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)

        myView.clipsToBounds = true
        myView.center = window.center
        myView.backgroundColor = Constants.color.withAlphaComponent(0.5)
        window.addSubview(myView)
        detailView = myView
    }
    
    func dismissDetailView() {
        self.detailView.removeFromSuperview()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //let key = Array(contacts.keys)[section]
        return contacts[section].value.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContatosIdentifier", for: indexPath) as! ContatosTableViewCell

        var category = contacts[indexPath.section]
        cell.selectionStyle = .none
        cell.nameLabel.text = category.value[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contacts[section].key
    }



}
