//
//  CartItemTableViewCell.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 12/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit

class CartItemTableViewCell: UITableViewCell {

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
