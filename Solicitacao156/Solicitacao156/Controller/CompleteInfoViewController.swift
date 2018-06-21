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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Enviar", style: .done, target: self, action: #selector(CompleteInfoViewController.buttonCompleteTap))

        
        
        if let _ = Singleton.shared.user {

            var ref: DatabaseReference!
            
            ref = Database.database().reference()
            ref.child("users").child("\(Singleton.shared.user.uid)").observeSingleEvent(of: .value, with: { (snapshot) in

                let value = snapshot.value as? NSDictionary
                let cep = value?["cep"] as? String ?? ""
                let cpf = value?["cpf"] as? String ?? ""
                let fone = value?["fone"] as? String ?? ""
                
                
                DispatchQueue.main.async {
                    self.cpfField.text = cpf
                    self.cepField.text = cep
                    self.foneField.text = fone
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func closeApp() {
        navigationController?.popViewController(animated: true)
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
                                Util.createMessageAlertController(title: "Atenção", message: string!, okMessage: "Ok", viewController: self)
                            }
                        }
                    } else {
                        Util.createMessageAlertController(title: "Atenção", message: string!, okMessage: "Ok", viewController: self)
                    }
                }
            } else {
                Util.createMessageAlertController(title: "Atenção", message: string!, okMessage: "Ok", viewController: self)
            }
        }
    }
    
    func continueUpdate() {
        let dataBaseHelper = DatabaseHelper()
        let p1 = dataBaseHelper.update(cep: cepField.text!)
        let p2 = dataBaseHelper.update(cpf: cpfField.text!)
        let p3 = dataBaseHelper.update(fone: foneField.text!)
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            dataBaseHelper.add(device: uuid)
        }
        if p1 && p2 && p3 {
            print("deu")
            closeApp()
        } else {
            print("Error to save")
        }
    }
    
    
    
    func validateField(field:UITextField,completion: (_ result: (Bool,String?)) -> Void) {
        if field.text != "" {
            let text = field.text
            if field == cpfField {
                if !text!.isValidCPF {
                    completion((false,"O CPF digita está invalido"))
                } else {
                    completion((true,nil))
                }
            }
            else if field == foneField {
                let onlyDigits = text!.filter({ (char) -> Bool in
                    if Int("\(char)") != nil {
                        return true
                    }
                    else {
                        return false
                    }
                })
                
                if onlyDigits.count < 9 || onlyDigits.count > 13 {
                    completion((false,"O telefone digito está invalido"))
                } else {
                    completion((true,nil))
                }
            }
            else if field == cepField {
                let onlyDigits = text!.filter({ (char) -> Bool in
                    if Int("\(char)") != nil {
                        return true
                    }
                    else {
                        return false
                    }
                })
               
                if onlyDigits.count < 7 || onlyDigits.count > 10 {
                    completion((false,"O CEP digitado está invalido"))
                } else {
                    completion((true,nil))
                }
                
                
            } else {
                completion((true,nil))
            }
        } else {
            if field == cpfField {
                completion((false,"Por favor, complete o campo de CPF"))
            }
            else if field == foneField {
                completion((false,"Por favor, complete o campo de telefone"))
            }
            else if field == cepField {
                completion((false,"Por favor, complete o campo de CEP"))
            }
            else {
                completion((false,"Didn't find field"))
            }
        }
    }
    

}

extension String {
    var isValidCPF: Bool {
        let numbers = characters.flatMap({Int(String($0))})
        guard numbers.count == 11 && Set(numbers).count != 1 else { return false }
        let soma1 = 11 - ( numbers[0] * 10 +
            numbers[1] * 9 +
            numbers[2] * 8 +
            numbers[3] * 7 +
            numbers[4] * 6 +
            numbers[5] * 5 +
            numbers[6] * 4 +
            numbers[7] * 3 +
            numbers[8] * 2 ) % 11
        let dv1 = soma1 > 9 ? 0 : soma1
        let soma2 = 11 - ( numbers[0] * 11 +
            numbers[1] * 10 +
            numbers[2] * 9 +
            numbers[3] * 8 +
            numbers[4] * 7 +
            numbers[5] * 6 +
            numbers[6] * 5 +
            numbers[7] * 4 +
            numbers[8] * 3 +
            numbers[9] * 2 ) % 11
        let dv2 = soma2 > 9 ? 0 : soma2
        return dv1 == numbers[9] && dv2 == numbers[10]
    }
}
