//
//  CompleteInfoViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 10/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase


class CompleteInfoViewController: UIViewController {

    @IBOutlet weak var cpfField: UITextField!
    @IBOutlet weak var foneField: UITextField!
    @IBOutlet weak var cepField: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func closeApp() {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func buttonCompleteTap(_ sender: Any) {
        validateField(field: cpfField) { (arg0) in
            
            let (bool, string) = arg0
            if bool {
                self.validateField(field: self.foneField) { (arg0) in
                    
                    let (bool, string) = arg0
                    if bool {
                        self.validateField(field: cepField) { (arg0) in
                            
                            let (bool, string) = arg0
                            if bool {
                                self.continueUpdate()
                            } else {
                                print(string!)
                            }
                        }
                    } else {
                        print(string!)
                    }
                }
            } else {
                print(string!)
            }
        }
    }
    
    func continueUpdate() {
        let dataBaseHelper = DatabaseHelper()
        let p1 = dataBaseHelper.update(cep: cepField.text!)
        let p2 = dataBaseHelper.update(cpf: cpfField.text!)
        let p3 = dataBaseHelper.update(fone: foneField.text!)
        if p1 && p2 && p3 {
            print("deu")
            closeApp()
        } else {
            print("Error to save")
        }
    }
    
    func validateField(field:UITextField,completion: (_ result: (Bool,String?)) -> Void) {
        if field.text != "" {
            completion((true,nil))
        } else {
            if field == cpfField {
                completion((false,"Cpf Field is not complete"))
            }
            else if field == foneField {
                completion((false,"Fone Field is not complete"))
            }
            else if field == cepField {
                completion((false,"Cpf Field is not complete"))
            }
            else {
                completion((false,"Didn't find field"))
            }
        }
    }
}
