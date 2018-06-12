//
//  EntriesTableViewCell.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 19/05/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class EntriesTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
