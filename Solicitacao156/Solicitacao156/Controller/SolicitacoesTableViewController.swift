//
//  SolicitacoesTableViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 11/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet
import SwiftyAttributes
import Crashlytics

class SolicitacoesNavigationTableViewController : UINavigationController {
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "SolicitacaoController") as? SolicitacoesTableViewController
        self.pushViewController(firstViewController!, animated: true)
        
        self.navigationBar.barTintColor = Constants.color
    }
}

class SolicitacoesTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var requisitions = [Requisition]()
    var selectedRow:Requisition!
    
    
    var showOkMessage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Solicitações"
        
        let addIcon = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(SolicitacoesTableViewController.addNewRequisition))
        self.navigationItem.rightBarButtonItem = addIcon
        
        let userIcon = UIBarButtonItem(image: UIImage(named: "user-icon.png"), style: .done, target: self, action: #selector(SolicitacoesTableViewController.openProfile))
        self.navigationItem.leftBarButtonItem = userIcon
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        if let _ = Singleton.shared.user {
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
                                if snapshotDate.key == "firstDate" {
                                    requisition.startDate = snapshotDate.value as! String
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
        
        let questions = getQuestions()
        if let _ = questions {
            if questions!.count > 0 {
                let integer = Int(arc4random_uniform(UInt32(questions!.count)))
        
                showDetailView(question: Question(question: (questions?[integer].question)!, answer: (questions?[integer].answer)!))
            }
        }
    }
    
    func getQuestions() -> [Question]? {
        if let path = Bundle.main.path(forResource: "Questions", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, [Any]>, let dataPoints = jsonResult["array"] as? [Dictionary<String,String>] {
                    var entrys = [Question]()
                    for point in dataPoints {
                        let entry = Question(question: point["question"]!, answer: point["answer"]!)
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
    
    @objc func addNewRequisition() {
        createAlert()
    }
    
    @objc func openProfile() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginController") as? LoginViewController
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if showOkMessage {
            showOkMessage = false
            Util.createMessageAlertController(title: "Solicitação", message: "O número de protocolo foi adicionado a sua conta", okMessage: "Ok", viewController: self)
            
        }
        self.tableView.reloadData()
    }
    
    var detailView:CardViewQuestions!
    
    func showDetailView(question:Question) {
        let myClassNib = UINib(nibName: "CardViewQuestions", bundle: nil)
        let myView =  myClassNib.instantiate(withOwner: nil, options: nil)[0] as! CardViewQuestions
        myView.solicitacaoSuper = self
        myView.question = question
        let window = UIApplication.shared.keyWindow!
        
        myView.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
        
        
        myView.clipsToBounds = true
        myView.center = window.center
        myView.backgroundColor = Constants.color.withAlphaComponent(0.5)
        window.addSubview(myView)
        detailView = myView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82.0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let requisition = requisitions[indexPath.row]
            let databaseHelper = DatabaseHelper()
            _ = databaseHelper.removeRequisition(requisition: requisition)
        }
    }
    
    func createAlert() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AdicionarController") as? AdicionarViewController
        controller?.mainPage = self
        
        self.navigationController?.pushViewController(controller!, animated: true)
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
        
        let selectedCell = tableView.cellForRow(at: indexPath)! as! SolicitacoesCellTableViewCell
        selectedCell.contentView.backgroundColor = Constants.color.withAlphaComponent(0.1)
        
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
        if let _ = Singleton.shared.user {
            return requisitions.count
        } else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSolicitacao", for: indexPath) as? SolicitacoesCellTableViewCell
        cell?.numberLabel.text = "\(requisitions[indexPath.row].numberId)"
        cell?.dataLabel.text = requisitions[indexPath.row].startDate
        return cell!
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if let _ = Singleton.shared.user {
            return "Sem solicitações".withAttributes([
                .font(UIFont.systemFont(ofSize: 25)),
                .strokeColor(.orange)
                ]).withTextColor(.gray)
        } else {
            return "Sem acesso".withAttributes([
                .font(UIFont.systemFont(ofSize: 25)),
                .strokeColor(.orange)
                ]).withTextColor(.gray)
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if let _ = Singleton.shared.user {
            return "Clique no + a cima para adicionar".withAttributes([
                .font(UIFont.systemFont(ofSize: 15)),
                .strokeColor(.orange)
                ]).withTextColor(.lightGray)
        } else {
            return "Para adicionar você precisar estar logado, clique aqui para cadastrar!".withAttributes([
                .font(UIFont.systemFont(ofSize: 15)),
                .strokeColor(.orange)
                ]).withTextColor(.lightGray)
        }
    }
    
 
    
    func emptyDataSetDidTap(_ scrollView: UIScrollView!) {
        if let _ = Singleton.shared.user {
            addNewRequisition()
        } else {
            openProfile()
        }
    }
    
    
    
}
