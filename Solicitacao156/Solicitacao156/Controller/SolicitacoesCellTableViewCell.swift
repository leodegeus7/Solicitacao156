//
//  SolicitacoesCellTableViewCell.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 19/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class SolicitacoesCellTableViewCell: UITableViewCell {


    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
