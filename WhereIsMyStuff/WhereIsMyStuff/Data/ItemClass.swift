//
//  ItemClass.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 29.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreData

class ItemClass{
    
    lazy var context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    private var allItems = [Item]()
    
    static let itemClass = ItemClass()
    
    private init(){
        load()
    }
    
    func load(){
        guard let context = context else {return}
        
        let request = NSFetchRequest<Item>(entityName: "Item")
        
        do{
            self.allItems = try context.fetch(request)
        }catch let e {
            print(e.localizedDescription)
        }
    }
    
    func getAll() -> [Item]{
        load()
        return allItems
    }
    
    func save(name: String, type: String) {
        guard let context = context else {return}
        let item = Item(context: context)
        
        item.itemID = UUID()
        item.itemName = name
        item.itemType = type
        
        do{
            try context.save()
        }catch let e {
            print(e.localizedDescription)
        }
    }
    
    
    
    func delete(deletableItem: Item){
        
        guard let context = context else {return}
        
        context.delete(deletableItem)
        allItems.removeAll {$0 === deletableItem}
        do{
            try context.save()
        }catch let e {
            print(e.localizedDescription)
        }
    }
    
    func loadSpecific(predicate: NSPredicate) -> [Item]?{
        guard let context = context else{
            return nil
        }
        let request = NSFetchRequest<Item>(entityName: "Item")
        request.predicate = predicate
        var items: [Item]?
        do{
            try items = context.fetch(request)
        }catch let e {
            print(e.localizedDescription)
        }
        return items
    }
    
}
