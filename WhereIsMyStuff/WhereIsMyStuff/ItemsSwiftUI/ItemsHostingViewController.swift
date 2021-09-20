//
//  ItemsHostingController.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 20.09.21.
//  Copyright © 2021 Benedikt. All rights reserved.
//

import UIKit
import SwiftUI


class ItemsHostingViewController: UIHostingController<ItemsView>{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ItemsView())
    }
}
