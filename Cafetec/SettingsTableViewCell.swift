//
//  SettingsTableViewCell.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 11/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var icon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
