//
//  ItemLocationTableViewCell.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 08.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class ItemLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var titleCell: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        qtyLabel.font = UIFont(name: "AppleColorEmoji", size: 14)
        titleCell.font = UIFont(name: "AppleColorEmoji", size: 14)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
