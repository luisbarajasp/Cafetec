//
//  FoodTableViewCell.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 10/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {

    @IBOutlet var foodPrice: UILabel!
    @IBOutlet var foodDescription: UILabel!
    @IBOutlet var foodName: UILabel!
    @IBOutlet var foodImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
