//
//  SuitcaseHeaderView.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 15.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class SuitcaseHeaderView: UICollectionReusableView {
        
    
    @IBOutlet weak var headerLabel: UILabel!
    
    func setHeaderLabel(title: String){
        headerLabel.text = title
        headerLabel.font = UIFont(name: "AppleColorEmoji", size: 15)
    }
}
