//
//  GlobalData.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 31.08.21.
//  Copyright © 2021 Benedikt. All rights reserved.
//

import UIKit
import MapboxMaps


class MapStyle {
    
    var mapStyleUrl: String {
        get {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return StyleURI.dark.rawValue
            } else {
                return StyleURI.light.rawValue
            }
        }
    }
    
    private init() {}
    
    static let shared = MapStyle()
    
    
}
