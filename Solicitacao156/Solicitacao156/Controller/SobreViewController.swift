//
//  SobreViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 06/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class SobreNavigationTableViewController : UINavigationController {
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "SobreController") as? SobreViewController
        self.pushViewController(firstViewController!, animated: true)
    }
}

class SobreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sobre"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
