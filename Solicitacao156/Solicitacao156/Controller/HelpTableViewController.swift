//
//  HelpTableViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 12/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class HelpTableViewController: UITableViewController {

    var questions = [Help]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Ajuda"
        if let help = getHelp() {
            questions = help
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
        return questions.count
    }


    
    func getHelp() -> [Help]? {
        if let path = Bundle.main.path(forResource: "Help", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, [Any]>, let dataPoints = jsonResult["array"] as? [Dictionary<String,String>] {
                    var entrys = [Help]()
                    for point in dataPoints {
                        let entry = Help(question: point["question"]!, answer: point["answer"]!)
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell", for: indexPath) as? HelpTableViewCell
        cell?.selectionStyle = .none
        cell?.answerLabel.text = questions[indexPath.row].answer
        cell?.questionLabel.text = questions[indexPath.row].question

        return cell!
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
