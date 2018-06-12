//
//  DicionarioTableViewCell.swift
//  Solicitacao156
//
//  Created by Leonardo Geus on 12/06/2018.
//  Copyright © 2018 Leonardo Geus. All rights reserved.
//

import UIKit

class DicionarioTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
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
