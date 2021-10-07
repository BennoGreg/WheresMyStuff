//
//  AllItemClass.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 30.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreData










class ItemLocationClass: ObservableObject{
    lazy var context: NSManagedObjectContext? = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else{
            return nil
        }
        
        return delegate.persistentContainer.viewContext
    }()
    
    
    var allItemLocations = [ItemLocation]()
    var suitcase = [ItemLocation]()
    
    static let instance = ItemLocationClass()
    
    private init() {
        self.allItemLocations = loadAllItemLocation()
        self.loadSuitcase()
    }
    
    func loadMockData() ->([[ItemLocation]], [String]) {
        guard let context = context else {return ([[ItemLocation]](), [String]())}
        let itemLocationOne = ItemLocation(context: context)
        let itemOne = Item(context: context)
        let locationOne = Location(context: context)
        itemOne.itemName = "MacBook"
        itemOne.itemType = "IT-Equipment"
        itemLocationOne.item = itemOne
        locationOne.street = "Krondorf"
        locationOne.houseNumber = 30
        locationOne.name = "Home"
        itemLocationOne.location = locationOne
        itemLocationOne.amount = 1
        
        let itemLocationTwo = ItemLocation(context: context)
        let itemTwo = Item(context: context)
        let locationTwo = Location(context: context)
        itemTwo.itemName = "iPad"
        itemTwo.itemType = "IT-Equipment"
        itemLocationTwo.item = itemTwo
        locationTwo.street = "Krondorf"
        locationTwo.houseNumber = 14
        locationTwo.name = "Oma & Opa"
        itemLocationTwo.location = locationTwo
        itemLocationTwo.amount = 1
        
        let itemLocationThree = ItemLocation(context: context)
        let itemThree = Item(context: context)
        itemThree.itemName = "Zipp 2"
        itemThree.itemType = "IT-Equipment"
        itemLocationThree.item = itemThree
        itemLocationThree.location = locationOne
        itemLocationThree.amount = 1
        
        let itemLocations = [itemLocationOne, itemLocationTwo, itemLocationThree]
        let locations = [locationOne.name!, locationTwo.name!]
        var itemLocations2D: [[ItemLocation]] = [[ItemLocation](), [ItemLocation]()]
        itemLocations.forEach { item in
            if let name = item.location?.name {
                if let index = locations.firstIndex(of: name), !itemLocations2D[index].contains(item){
                    itemLocations2D[index].append(item)
                }
            }
        }
        
        
        return (itemLocations2D, locations)
    }
    
    
    func loadAllItemLocation() ->[ItemLocation]{
        guard let context = context else{
            return [ItemLocation]()
        }
        let predicate = NSPredicate(format: "location != nil")
        let request = NSFetchRequest<ItemLocation>(entityName: "ItemLocation")
        request.predicate = predicate
        var allLocations = [ItemLocation]()
        do{
            allLocations = try context.fetch(request)
        }catch let e {
            print(e.localizedDescription)
        }
        
        return allLocations
        
    
    }
    
    func loadSpecific(location: Location) ->[ItemLocation]?{
        
        guard let context = context else {
            return nil
        }
        let request = NSFetchRequest<ItemLocation>(entityName: "ItemLocation")
        
        let predicate = NSPredicate(format: "location.locationID == %@", location.locationID! as CVarArg)
        let notNullPredicate = NSPredicate(format: "location != nil")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,notNullPredicate])
        var fetchedResult: [ItemLocation]?
        do{
            fetchedResult =  try context.fetch(request)
            
        }catch let e {
            print(e.localizedDescription)
        }
        
        return fetchedResult
        
    }
    
    func save(location: Location, item: Item, amount: Int, remarks: String?){
        guard let context = context else {
            return
        }
        var itemLocation: ItemLocation
        if let result = checkIfAlreadyExistend(location: location, item: item){
            itemLocation = result
            itemLocation.amount += Int32(amount)
        }else{
            itemLocation = ItemLocation(context: context)
            itemLocation.entryID = UUID()
            itemLocation.amount = Int32(amount)
            itemLocation.location = location;
            itemLocation.item = item;
            itemLocation.remarks = remarks
            itemLocation.isSaved = true
            allItemLocations.append(itemLocation)
        }
        do{
            try context.save()            
        }catch let e {
            print(e.localizedDescription)
        }
    }
    
    private func checkIfAlreadyExistend(location: Location, item: Item) ->ItemLocation?{
        var result: ItemLocation?
        _ = allItemLocations.contains { (itemLocation) -> Bool in
            if itemLocation.location?.locationID == location.locationID && itemLocation.item?.itemID == item.itemID{
                result = itemLocation
                return true
            }
            return false
        }
        
        return result
    }
    
    func delete(itemLocation: ItemLocation){
        guard let context = context else {
            return
        }
        
        if let index = allItemLocations.lastIndex(of: itemLocation){
            allItemLocations.remove(at: index)
            
            context.delete(itemLocation)
            do{
                try context.save()
            }catch let e {
                print(e.localizedDescription)
            }
        }
    }
    
    func createSuitcase(items: [ItemLocation]){
        
        guard let context = context else{
            return
        }
        
        items.forEach { (itemLocation) in
            itemLocation.location = nil
            itemLocation.isSaved = true
        }
        do{
            try context.save()
        }catch let e {
            print(e.localizedDescription)
        }
        loadAllItemLocation()
        suitcase = items
        
    }
    
    func loadSuitcase()->[ItemLocation]?{
        guard let context = context else{
            return nil
        }
        let predicate = NSPredicate(format: "location == nil")
        let request = NSFetchRequest<ItemLocation>(entityName: "ItemLocation")
        request.predicate = predicate
        do{
            suitcase = try context.fetch(request)
        }catch let e {
            print(e.localizedDescription)
        }
        
        return suitcase
        
    }
    
    func unloadSuitcase(uuidString: String){
        
        let uuid = UUID(uuidString: uuidString)
        
        guard let context = context else{
            return
        }
        
        let locationInstance = LocationClass.locations
        
        let allLocations = locationInstance.getAll()
        let location = allLocations.last { $0.locationID == uuid}
        
        
        suitcase.forEach { (suiteCaseItem) in
            if let localItem = allItemLocations.last(where: { (itemLocation) -> Bool in
                return itemLocation.location?.locationID == location?.locationID && itemLocation.item?.itemID == suiteCaseItem.item?.itemID
            }) {
                localItem.amount += suiteCaseItem.amount
                context.delete(suiteCaseItem)
            }else{
                suiteCaseItem.location = location
            }
            
            
        }
        suitcase.removeAll()
        do{
            try context.save()
        }catch let e {
            print(e.localizedDescription)
        }
        
        let journeyInstance = JourneyClass.instance
        journeyInstance.setEndLocation(locationName: location?.name ?? "")
    }
    
    func deleteNotSaved(itemLocations: [ItemLocation]){
        
        guard let context = context else{
            return
        }
        
        context.rollback()
//        itemLocations.forEach { (item) in
//            if !item.isSaved {
//                if let index = suitcase.lastIndex(of: item){
//                    suitcase.remove(at: index)
//
//                    context.reset()
//                }
//            }
//        }
//        do{
//            try context.save()
//
//        }catch let e {
//            print(e.localizedDescription)
//        }
    }
    
    
    
}

//extension ItemLocation: Identifiable{
//    
//}
