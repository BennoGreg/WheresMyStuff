//
//  PickerValueTableViewCell.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 09.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class PickerValueTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "PickerValueTableViewCellIdentifier"
    }
    
    // Nib name
    class func nibName() -> String {
        return "PickerValueTableViewCell"
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 44.0
    }
    
    func updateText(title: String, value: String) {
        titleLabel.font = UIFont(name: "AppleColorEmoji", size: 13)
        valueLabel.font = UIFont(name: "AppleColorEmoji", size: 13)
           titleLabel.text = title
           valueLabel.text = value
       }
    
    
}
