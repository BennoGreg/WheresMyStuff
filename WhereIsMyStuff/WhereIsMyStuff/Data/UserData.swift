//
//  UserData.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 08.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import Foundation

final class UserData: ObservableObject{
    
    @Published var itemLocation = ItemLocationClass.instance.allItemLocations
}
