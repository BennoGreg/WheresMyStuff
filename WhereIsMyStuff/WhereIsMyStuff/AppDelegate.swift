//
//  AppDelegate.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 18.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
              title: "Accept",
              options: UNNotificationActionOptions(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
              title: "Decline",
              options: UNNotificationActionOptions(rawValue: 0))
        // Define the notification type
        let placeItemCategory =
              UNNotificationCategory(identifier: "LOCATION_ENTER",
              actions: [acceptAction, declineAction],
              intentIdentifiers: [],
              hiddenPreviewsBodyPlaceholder: "",
              options: .customDismissAction)
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([placeItemCategory])
        
        
        center.delegate = self
        
        locationManager.delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "WhereIsMyStuff")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let curLocation = locations.first else {
            return
        }
        let locationInstance = LocationClass.locations
        let locations = locationInstance.getAll()
        locations.forEach { (locationObject) in
            let location = CLLocation(latitude: locationObject.latitude, longitude: locationObject.longitude)
            let curvisit = CLLocation(latitude: curLocation.coordinate.latitude, longitude: curLocation.coordinate.longitude)
            let distance = curvisit.distance(from: location)
            if distance <= 50 {
                newVisitReceived( description: "Your current position is \(locationObject.name ?? "").", location: locationObject)
            }
        }
        
    }
    
    class func getDelegate() ->AppDelegate{
        return (UIApplication.shared.delegate as? AppDelegate)!
    }
    
    
    func newVisitReceived( description: String, location: Location){
        
        let content = UNMutableNotificationContent()
        content.title = "Do you want to save your stuff here?"
        content.body = description
        content.sound = .default
        content.categoryIdentifier = "LOCATION_ENTER"
        content.userInfo = ["LocationUUID": location.locationID?.uuidString ?? ""]
        
        if UIApplication.shared.applicationState == .active{
            
            NotificationCenter.default.post(name: .didReceiveData, object: nil, userInfo: ["LocationName": location.name, "LocationUUID": location.locationID?.uuidString])
        }else{
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "LOCATION_ENTER", content: content, trigger: trigger)
            
            center.add(request) { (error) in
                if let error = error{
                    print(error.localizedDescription)
                }
                
                print("Awesome it worked")
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager,  didFailWithError error: Error){
        
      // Location updates are not authorized.
        locationManager.stopMonitoringVisits()
        print(error.localizedDescription)
      
       
       // Notify the user of any errors.
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.badge,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        let uuidString = userInfo["LocationUUID"] as? String
        let itemLocationInstance = ItemLocationClass.instance
        switch response.actionIdentifier{
            
            case "ACCEPT_ACTION":
                 print("accepted")
                 itemLocationInstance.unloadSuitcase(uuidString: uuidString ?? "")
                 locationManager.stopUpdatingLocation()
                 locationManager.allowsBackgroundLocationUpdates = false
                 break
                   
              case "DECLINE_ACTION":
                 print("declined")
                 break
                   
              // Handle other actions…
            
              default:
                 break
              
        }
        completionHandler()
    }
}

//extension AppDelegate: CLLocationManagerDelegate{
//
//    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
//        let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
//    }
//}

