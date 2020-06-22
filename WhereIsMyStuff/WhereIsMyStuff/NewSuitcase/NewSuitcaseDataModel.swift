//
//  NewSuitcaseDataModel.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 15.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreLocation
import MapboxGeocoder
import CoreData

protocol SuitcaseDataModelDelegate {
    func update()
    func setBool()
}

class NewSuitcaseDataModel {
    
    
    
    var itemsToPack: [[ItemLocation]]
    
    var itemLocationClassInstance = ItemLocationClass.instance
    var locationInstance = LocationClass.locations
    
    let geocoder = Geocoder.shared
    
    var delegate: SuitcaseDataModelDelegate?
    var context: NSManagedObjectContext? = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else{
            return nil
        }
        
        return delegate.persistentContainer.viewContext
    }()
    
    var currentLocationName: String?
    
    
    var currentLocation: CLLocation? {
        didSet{
            if oldValue == nil {
                setLocationItems()
            }
        }
    }
    
    init() {
        itemsToPack = [[ItemLocation]]()
        itemsToPack.append(itemLocationClassInstance.loadAllItemLocation())
        itemsToPack.append([ItemLocation]())
    }
    
    
    func setLocationItems(){
        
        var items: [ItemLocation]?
        let locations = locationInstance.getAll()
        locations.forEach { (locationObject) in
            let location = CLLocation(latitude: locationObject.latitude, longitude: locationObject.longitude)
            let distance = currentLocation?.distance(from: location)
            if let distance = distance, distance <= 50{
                currentLocationName = locationObject.name
                let predicate = NSPredicate(format: "location.locationID == %@", locationObject.locationID! as CVarArg )
                if let specificItems = itemLocationClassInstance.loadSpecific(location: locationObject){
                    itemsToPack[0] = specificItems
                    delegate?.update()
                }
            }
            
            
        }
        itemLocationClassInstance.loadSuitcase()?.forEach({ (itemlocation) in
            itemsToPack[1].append(itemlocation)
            delegate?.setBool()
            delegate?.update()
        })
    }
    
    func reOrder(indexPath: IndexPath, amount: Int, fullRemove: Bool){
        if fullRemove{
            let itemToRemove = itemsToPack[indexPath.section].remove(at: indexPath.row)
            itemsToPack[1].append(itemToRemove)
        }else{
            guard let context = context else{
                return
            }
            let itemToChange = itemsToPack[indexPath.section][indexPath.row]
            itemToChange.amount -= Int32(amount)
            let item = ItemLocation(context: context)
            item.amount = Int32(amount)
            item.item = itemToChange.item
            itemsToPack[1].append(item)
            
        }
    }
    
    func saveSuitcase(){
        
        itemLocationClassInstance.createSuitcase(items: itemsToPack[1])
    }
    
    
    func deleteSuitcase(){
        
        itemsToPack[1].forEach { (item) in
            if !item.isSaved {
                if let sameItem = itemsToPack[0].last(where: { (currItem) -> Bool in
                    return currItem.item?.itemID == item.item?.itemID
                }){
                    sameItem.amount += item.amount
                }else{
                    itemsToPack[0].append(item)
                }
            }
            
            
        }
        
        itemLocationClassInstance.deleteNotSaved(itemLocations: itemsToPack[1])
        itemsToPack[1].removeAll()
        delegate?.update()
        
    }
    
    
    
    
    
}

class SuitCase: ItemLocation {
    
    
    
}
