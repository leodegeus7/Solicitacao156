//
//  CardViewQuestions.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 12/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

//
//  CardView.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 10/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class CardViewQuestions: UIView {
    
    @IBOutlet weak var cardSubView: UIView!
    
    var question:Question!
    var solicitacaoSuper:SolicitacoesTableViewController!
    
    @IBOutlet weak var cancelLabel: UIButton!
    
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var questionString: UILabel!
    @IBOutlet weak var answearLabel: UILabel!
    
    
    override func draw(_ rect: CGRect) {
        self.showButton.isHidden = false
        self.answearLabel.isHidden = true
        cancelLabel.setTitleColor(Constants.color, for: .normal)
        showButton.setTitleColor(UIColor.white, for: .normal)
        showButton.backgroundColor = Constants.color
        showButton.layer.cornerRadius = showButton.frame.height / 2
        questionString.text = question.question
        answearLabel.text = question.answer
        cardSubView.layer.cornerRadius = 10
    }
    
    @IBAction func buttonOffClicked(_ sender: Any) {
        dismiss()
    }
    @IBAction func buttonXClicked(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func showAnswear(_ sender: Any) {
        self.showButton.isHidden = true
        self.answearLabel.isHidden = false
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            Analytics.logEvent("user_clicked_question", parameters: ["deviceId":uuid])
        } else {
            Analytics.logEvent("user_clicked_question", parameters: ["deviceId":"unknown"])
        }
    }
    
    func dismiss() {
        removeFromSuperview()
    }
    
}
