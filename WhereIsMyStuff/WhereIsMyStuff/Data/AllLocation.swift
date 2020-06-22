
//
//  DataA+.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 27.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationClass {
    
    lazy var context: NSManagedObjectContext? = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else{
            return nil
        }
        
        return delegate.persistentContainer.viewContext
    }()
    
    
    static let locations = LocationClass()
    
    private var allLocations = [Location]()
    
    
    private init(){
        load()
    }
    
    func load(){
        guard let context = context else{
            return
        }
        let request = NSFetchRequest<Location>(entityName: "Location")
        
        do{
            allLocations = try context.fetch(request)
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getAll() -> [Location]{
        return allLocations
    }
    
    func loadSpecific(predicate: NSPredicate) -> [Location]?{
        guard let context = context else{
            return nil
        }
        let request = NSFetchRequest<Location>(entityName: "Location")
        request.predicate = predicate
        var locations: [Location]?
        do{
            try locations = context.fetch(request)
        }catch let e {
            print(e.localizedDescription)
        }
        return locations
    }
    
    
    func save(coordinates: CLLocationCoordinate2D, name: String, street: String? = nil, houseNumber: Int? = nil, city: String? = nil, zipCode: Int? = nil, country: String? = nil){
        guard let context = context else{
            return
        }
        
        let location = Location(context: context)
        location.locationID = UUID()
        location.name = name
        location.longitude = Double(coordinates.longitude)
        location.latitude = Double(coordinates.latitude)
        location.street = street
        location.houseNumber = Int32(houseNumber ?? 0)
        location.city = city
        location.zipCode = Int32(zipCode ?? 0)
        location.country = country
        
        do{
            try context.save()
            print("saving Successfull")
        }catch let e{
            print(e.localizedDescription)
        }
        load()
    }
    
    func delete(location: Location){
        
        guard let context = context else {
            return
        }
        
        do{
            context.delete(location)
            allLocations.removeAll{$0 === location}
            try context.save()
        }catch let e {
            print(e.localizedDescription)
        }
    }
    
    
    
}
