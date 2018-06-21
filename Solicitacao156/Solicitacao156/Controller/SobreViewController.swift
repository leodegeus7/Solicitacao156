//
//  SobreViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 06/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import MessageUI

class SobreNavigationTableViewController : UINavigationController {
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyboard.instantiateViewController(withIdentifier: "SobreController") as? SobreViewController
        self.pushViewController(firstViewController!, animated: true)
    }
}

class SobreViewController: UIViewController,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var letíciaLabel: UILabel!
    @IBOutlet weak var leonardoLabel: UILabel!
    @IBOutlet weak var fabianoLabel: UILabel!
    @IBOutlet weak var fabioLabel: UILabel!
    
    @IBOutlet weak var helpButton: UIButton!

    @IBOutlet weak var avalieButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helpButton.tintColor = UIColor.white
        helpButton.backgroundColor = Constants.color
        
        helpButton.layer.cornerRadius = helpButton.frame.height/2
        self.navigationItem.title = "Sobre"
        
        
        avalieButton.tintColor = UIColor.white
        avalieButton.backgroundColor = Constants.color
        
        avalieButton.layer.cornerRadius = avalieButton.frame.height/2
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(SobreViewController.openLeticiaMail))
        letíciaLabel.isUserInteractionEnabled = true
        letíciaLabel.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(SobreViewController.openLeoMail))
        
        
        leonardoLabel.isUserInteractionEnabled = true
        leonardoLabel.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(SobreViewController.openFabianoMail))
        fabianoLabel.isUserInteractionEnabled = true
        fabianoLabel.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(SobreViewController.openFabioMail))
        fabioLabel.isUserInteractionEnabled = true
        fabioLabel.addGestureRecognizer(tap4)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func helpButtonTap(_ sender: Any) {
        
        let bundle = UIStoryboard(name: "Main", bundle: nil)
        let helpController = bundle.instantiateViewController(withIdentifier: "HelpController") as? HelpTableViewController
        self.navigationController?.pushViewController(helpController!, animated: true)
        
    }
    
    func sendEmail(email:String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            
            present(mail, animated: true)
        } else {
            Util.createMessageAlertController(title: "Atenção", message: "Não foi possível abrir o aplicativo de e-mail do ios", okMessage: "Ok", viewController: self)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @objc func openLeoMail() {
        sendEmail(email: "leonardodegeus@gmail.com")
    }
    
    @objc func openLeticiaMail() {
        sendEmail(email: "leticiasolieri@gmail.com")
    }
    @objc func openFabianoMail() {
        sendEmail(email: "ffral.01@gmail.com")
    }
    
    @objc func openFabioMail() {
        sendEmail(email: "pacho80@gmail.com")
    }
}
