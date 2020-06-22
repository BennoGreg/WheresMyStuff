//
//  NewSuitcaseViewController.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 04.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreLocation

class NewSuitcaseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let titles = ["Select your items", "Now in your Suitcase"]
    let dataModel = NewSuitcaseDataModel()
    let locationManager = CLLocationManager()
    var saveSuitcaseButton: UIBarButtonItem?
    var willSave = false
    
    let center = UNUserNotificationCenter.current()
    
    @IBOutlet weak var newSuitCaseCollectionView: UICollectionView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        dataModel.delegate = self
        
        requestForLocation()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
    }
    
    func requestForLocation(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .authorizedWhenInUse:
            self.locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            locationPermissionDenied()
        default:
            break
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        saveSuitcaseButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(NewSuitcaseViewController.saveSuitcase(sender:)))
        
        self.navigationItem.rightBarButtonItem = saveSuitcaseButton
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        dataModel.deleteSuitcase()
        
        super.viewWillDisappear(animated)
    }
    
    @objc func saveSuitcase(sender: UIBarButtonItem){
        willSave = true
        dataModel.saveSuitcase()
        let journeyInstance = JourneyClass.instance
        journeyInstance.save( startLocation: dataModel.currentLocationName ?? "Home", date: nil)
        print(locationManager.allowsBackgroundLocationUpdates)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let delegateLocationManager = appDelegate.locationManager
        
        delegateLocationManager.distanceFilter = 200
        delegateLocationManager.allowsBackgroundLocationUpdates = true
        delegateLocationManager.startUpdatingLocation()

        center.requestAuthorization(options: [.alert, .sound]) { (granted , error) in
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel.itemsToPack[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.StuffCell.rawValue, for: indexPath) as! StuffCollectionViewCell
        let itemName = dataModel.itemsToPack[indexPath.section][indexPath.row].item?.itemName ?? ""
        let itemAmount = dataModel.itemsToPack[indexPath.section][indexPath.row].amount
        let categoryName = dataModel.itemsToPack[indexPath.section][indexPath.row].item?.itemType ?? "Something else"
        cell.updateContent(image: UIImage(named: categoryName), name: "\(itemAmount)x \(itemName)")
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SuitCaseHeaderView", for: indexPath) as! SuitcaseHeaderView
            let title = titles[indexPath.section]
            header.setHeaderLabel(title: title)
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.StuffCell.rawValue, for: indexPath) as! StuffCollectionViewCell
            let amount = dataModel.itemsToPack[indexPath.section][indexPath.row].amount
            let alertController = UIAlertController(title: "Add Item(s) to suitcase", message: "Time in the amount (max. \(amount)) you want to add to your Suitcase", preferredStyle: .alert)
            
            alertController.addTextField { (textfield) in
                textfield.placeholder = "0"
                textfield.keyboardType = .numberPad
            }
            
            alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
                let textFieldValue = Int(alertController.textFields?[0].text ?? "0") ?? 0
                if textFieldValue == amount{
                    self.dataModel.reOrder(indexPath: indexPath, amount: textFieldValue, fullRemove: true)
                    collectionView.performBatchUpdates({
                        collectionView.deleteItems(at: [indexPath])
                        collectionView.insertItems(at: [IndexPath(row: self.dataModel.itemsToPack[1].count-1, section: 1)])
                    }, completion: nil)
                }else if textFieldValue >= 1 && textFieldValue < amount {
                    self.dataModel.reOrder(indexPath: indexPath, amount: textFieldValue, fullRemove: false)
                    collectionView.performBatchUpdates({
                        collectionView.reloadItems(at: [indexPath])
                        collectionView.insertItems(at: [IndexPath(row: self.dataModel.itemsToPack[1].count-1, section: 1)])
                    }, completion: nil)
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertController,animated: true, completion: nil)
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension NewSuitcaseViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }
        dataModel.currentLocation = location
    }
    
    
    
    
}

extension NewSuitcaseViewController: SuitcaseDataModelDelegate{
    
    func update() {
        newSuitCaseCollectionView.reloadData()
    }
    
    func setBool() {
        willSave = false
    }
}

enum CellIdentifier: String {
    
    case StuffCell = "StuffCollectionViewCell"
}

extension NewSuitcaseViewController {
    
    func locationPermissionDenied() {
        let message = "The location permission was not authorized. Please enable it in Settings to continue."
        presentSettingsAlert(message: message)
    }
    
    private func presentSettingsAlert(message: String) {
        let alertController = UIAlertController(title: "Permissions Denied!",
                                                message: message,
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true)
    }
}
