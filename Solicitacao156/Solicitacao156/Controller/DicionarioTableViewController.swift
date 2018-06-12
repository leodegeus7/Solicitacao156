//
//  DicionarioTableViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 06/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class DicionarioNavigationTableViewController : UINavigationController {
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "DicionarioController") as? DicionarioTableViewController
        self.pushViewController(firstViewController!, animated: true)
    }
}

class DicionarioTableViewController: UITableViewController {

    var entries = [EntryDic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Dicionário de Dados"
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension

        if let data = getData() {
            entries = data
            self.tableView.reloadData()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() -> [EntryDic]? {
        if let path = Bundle.main.path(forResource: "Dic", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, [Any]>, let dataPoints = jsonResult["data"] as? [Dictionary<String,String>] {
                    var entrys = [EntryDic]()
                    for point in dataPoints {
                        let entry = EntryDic(name: point["name"]!, value: point["description"]!)
                        entrys.append(entry)
                    }
                    return entrys
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = entries[indexPath.row]
        UIPasteboard.general.string = "\(entry.name) - \(entry.value)"
        Util.createMessageAlertController(title: "O conteúdo apresentado foi copiado", message:  "\(entry.name) - \(entry.value)", okMessage: "Ok", viewController: self)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //let key = Array(contacts.keys)[section]
        return entries.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DicionarioCell", for: indexPath) as! DicionarioTableViewCell
        
        cell.selectionStyle = .none
        cell.nameLabel.text = entries[indexPath.row].name
        cell.descriptionLabel.text = entries[indexPath.row].value
        
        return cell
    }


}
