//
//  NewLocationModel.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 19.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import Combine
import CoreLocation


class NewLocationModel: ObservableObject {
    
    let subject = PassthroughSubject<CLLocationCoordinate2D,Never>()
    
    
}
