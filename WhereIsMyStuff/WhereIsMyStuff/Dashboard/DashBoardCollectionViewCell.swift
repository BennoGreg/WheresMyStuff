//
//  DashBoardCollectionViewCell.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 04.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class DashBoardCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var dashBoardImageView: UIImageView!
    
    @IBOutlet weak var journeyLabel: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    func updateCell(title: String){
        journeyLabel.font = UIFont(name: "AppleColorEmoji", size: 13)
        journeyLabel.text = title
        self.clipsToBounds = true
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5.0
        
        dashBoardImageView.image = UIImage(named: "route")
        visualEffectView.layer.cornerRadius = 5
        visualEffectView.layer.masksToBounds = true
    }
}
