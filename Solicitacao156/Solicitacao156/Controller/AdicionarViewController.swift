//
//  AdicionarViewController.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 07/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class AdicionarViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addTextField: UITextField!
    
    var mainPage :SolicitacoesTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.backgroundColor = Constants.color
        addButton.layer.cornerRadius = self.addTextField.layer.visibleRect.height / 2
        addButton.alpha = 0.9
        self.navigationItem.title = "Adicionar solicitação"
        self.addTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(AdicionarViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AdicionarViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let distanceBetweenTextfielAndKeyboard = self.view.frame.height - textFieldRealYPosition - keyboardSize.height
            if distanceBetweenTextfielAndKeyboard < 0 {
                UIView.animate(withDuration: 0.4) {
                    self.addButton.transform = CGAffineTransform(translationX: 0.0, y: distanceBetweenTextfielAndKeyboard)
                }
            }
        }
    }
    
    var textFieldRealYPosition: CGFloat = 0.0
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.4) {
            self.addButton.transform = .identity
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldRealYPosition = addButton.frame.origin.y + addButton.frame.height + 50
        //take in account all superviews from textfield and potential contentOffset if you are using tableview to calculate the real position
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonTap(_ sender: Any) {
        if let num = self.validateIdRequisition(string: (addTextField.text!)) {
            DispatchQueue.main.async {
                var requisiton = Requisition()
                requisiton.numberId = num
                self.testIfRequisitionExist(requisition: requisiton, completion: { (result) in
                    if result.0 {
                        DispatchQueue.main.async {
                        let database = DatabaseHelper()
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd/MM/yyyy"
                            let stringDate = dateFormatter.string(from: result.1!)
                            _ = database.addRequisiton(requisition:requisiton, firstDate: stringDate)
                        self.mainPage.showOkMessage = true
                        self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        Util.createMessageAlertController(title: "Atenção", message: "Não há registros desta requisição em nossos servidores, tente digitar outro ID", okMessage: "Ok", viewController: self)
                    }
                })
            }
        } else {
            Util.createMessageAlertController(title: "Atenção", message: "O número de protocolo deve conter comente números, com cerca de 7 dígitos", okMessage: "Ok", viewController: self)
        }
    }
    
    func testIfRequisitionExist(requisition:Requisition,completion: @escaping (_ result: (Bool,Date?)) -> Void) {
        let network = NetworkSetup()
        network.getRequisition(requisition: requisition) { (entries) in
            
            if (entries?.count)! > 0 {
                var firstDate = entries?.first!.date
                for entry in entries! {
                    if entry.date < firstDate! {
                        firstDate = entry.date
                    }
                }
                completion((true,firstDate))
            } else {
                completion((false,nil))
            }
        }
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

    
}
