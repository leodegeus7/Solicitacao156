//
//  RatingTableViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 13/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import Cosmos
import Crashlytics
import Firebase

class RatingTableViewController: UITableViewController {

    var strings = ["Informações","Navegação","Visual","Utilidade","Como você avalia o aplicativo?"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Avaliação"
        let enviarIcon = UIBarButtonItem(title: "Enviar", style: .done, target: self, action: #selector(RatingTableViewController.sendRating))
        self.navigationItem.rightBarButtonItem = enviarIcon
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
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
        return strings.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "COMO VOCÊ AVALIA:"
    }

    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as? RatingTableViewCell
        cell?.selectionStyle = .none
        cell?.titleLabel.text = strings[indexPath.row]
        if indexPath.row == strings.count - 1 {
            cell?.starsImage.settings.emptyBorderColor = UIColor(red: 70/255, green: 108/255, blue: 178/255, alpha: 1)
            cell?.starsImage.settings.filledBorderColor = UIColor(red: 70/255, green: 108/255, blue: 178/255, alpha: 1)
            cell?.starsImage.settings.filledColor = UIColor(red: 70/255, green: 108/255, blue: 178/255, alpha: 1)
        }
        if indexPath.section == 0 {
            cell?.tag = indexPath.row
        }
        return cell!
    }
    
    @objc func sendRating() {
        let cells = self.tableView.visibleCells
        let rating = Rating()
        var ratings = [Int]()
        for cell in cells {
            if let ratingCell = cell as? RatingTableViewCell {
                let stars = ratingCell.starsImage.rating
                if cell.tag == 0 {
                    rating.informacao = Int(stars)
                    
                }
                else if cell.tag == 1 {
                    rating.navegacao = Int(stars)
                }
                else if cell.tag == 2 {
                    rating.visual = Int(stars)
                }
                else if cell.tag == 3 {
                    rating.utilidade = Int(stars)
                }
                else if cell.tag == 4 {
                    rating.total = Int(stars)
                }
                ratings.append(Int(stars))
            }
        }
        
        var thereIsZero = false
        for ratingNumber in ratings {
            if ratingNumber == 0 {
                thereIsZero = true
            }
        }
        
        if thereIsZero {
            Util.createMessageAlertController(title: "Atenção", message: "Preencha todos os campos para enviar sua avaliação", okMessage: "Ok", viewController: self)
        } else {
            if let user = Singleton.shared.user {
                let ref = Database.database().reference()
                let ratings = ref.child("ratings")
                let userNode = ratings.child("\(user.uid)")
                let dic = rating.getDic()
                userNode.setValue(dic)
            } else {
                if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                    let ref = Database.database().reference()
                    let ratings = ref.child("ratings")
                    let userNode = ratings.child("Anonimo-DeviceId:\(uuid)")
                    let dic = rating.getDic()
                    userNode.setValue(dic)
                } else {
                    Util.createMessageAlertController(title: "Erro", message: "Erro ao mandar a avaliação, contate um administrador", okMessage: "Ok", viewController: self)
                }
                
            }
            self.navigationController?.popViewController(animated: true)
            
        }
    }

}
