//
//  StuffCollectionViewCell.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 04.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class StuffCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
   
    
    @IBOutlet weak var visualEffectsView: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    
    func updateContent(image: UIImage?, name: String){
        self.clipsToBounds = true
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5.0
        itemImageView.image = image
        itemLabel.text = name
        itemLabel.font = UIFont(name: "AppleColorEmoji", size: 13)
        visualEffectsView.layer.masksToBounds = true
        visualEffectsView.layer.cornerRadius = 5
        
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        
//
//        let greyView = UIView(frame: bounds)
//        greyView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        self.selectedBackgroundView = greyView
//    }
}
