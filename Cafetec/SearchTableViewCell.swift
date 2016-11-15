//
//  SearchTableViewCell.swift
//  Cafetec
//
//  Created by Luis Eduardo Barajas Perez on 14/11/16.
//  Copyright © 2016 Techeando. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet var placeName: UILabel!
    @IBOutlet var foodImage: UIImageView!
    @IBOutlet var foodPrice: UILabel!
    @IBOutlet var foodDescription: UILabel!
    @IBOutlet var foodName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
