//
//  DashboardHeaderView.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 21.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class DashboardHeaderView: UICollectionReusableView {
        
    
    @IBOutlet weak var headerLabel: UILabel!
    
    func updateLabel(title: String){
        
        headerLabel.font = UIFont(name: "AppleColorEmoji", size: 15)
        headerLabel.text = title
    }
    
}
