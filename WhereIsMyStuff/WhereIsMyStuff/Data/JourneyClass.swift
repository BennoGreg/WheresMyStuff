//
//  JourneyClass.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 21.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import CoreData
import UIKit

class JourneyClass{
    
    lazy var context: NSManagedObjectContext? = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return delegate.persistentContainer.viewContext
    }()
    
    
    var allJourneys = [Journey]()
    var tempJourney: Journey?
    
    static let instance = JourneyClass()
    
    private init(){
        if let journeys = loadJourneys(){
            allJourneys = journeys
        }
    }
    
    func save(startLocation: String, date: Date?){
        
        guard let context = context else {
            return
        }
        
        let journey = Journey(context: context)
        journey.journeyID = UUID()
        journey.date = date
        journey.startLocation = startLocation
        journey.endLocation = nil
        
        do{
            try context.save()
        }catch let e {
            print(e.localizedDescription)
        }
        tempJourney = journey
    }
    
    func loadJourneys() -> [Journey]?{
        guard let context = context else {
            return nil
        }
        let predicate = NSPredicate(format: "endLocation != nil")
        let request = NSFetchRequest<Journey>(entityName: "Journey")
        request.predicate = predicate
        var journeys: [Journey]?
        do{
            journeys = try context.fetch(request)
        }catch let e {
            print(e.localizedDescription)
        }
        return journeys
    }
    
    func setEndLocation(locationName: String){
        
        guard let context = context else {
            return
        }
        if let journey = tempJourney{
            journey.endLocation = locationName
            journey.date = Date()
            do{
                try context.save()
            }catch let e {
                print(e.localizedDescription)
            }
            allJourneys.append(journey)
        }
        
        
    }
    
    func deleteAll(){
        guard let context = context else {
            return
        }
        allJourneys.forEach { (journey) in
            context.delete(journey)
        }
        allJourneys.removeAll()
        do{
            try context.save()
        }catch let e {
            print(e.localizedDescription)
        }
    }
    
}
