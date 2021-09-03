//
//  MyLocationsViewController.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 18.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreLocation

class MyLocationsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let allLocations = LocationClass.locations
    var locations = [Location]()

   
    @IBOutlet weak var locationCollectionView: UICollectionView!
    
    @IBOutlet weak var removeButton: UIBarButtonItem!
    
    var composeButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Your locations"
        self.locationCollectionView.allowsSelection = true
        
        composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(edit))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editDone))
        
        self.navigationItem.leftBarButtonItem = composeButton
        removeButton.target = self
        removeButton.action = #selector(remove)
        // Do any additional setup after loading the view.
    }
    
    @objc func edit(sender: UIBarButtonItem){
        setEditing(true, animated: true)
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
    @objc func editDone(sender: UIBarButtonItem){
        setEditing(false, animated: true)
        removeButton.isEnabled = false
        self.navigationItem.leftBarButtonItem = composeButton
    }
    
    @objc func remove(sender: UIBarButtonItem){
        if let selectedCells = locationCollectionView.indexPathsForSelectedItems{
            let items = selectedCells.map{$0.item}.sorted().reversed()
            for item in items{
                let location = locations.remove(at: item)
                allLocations.delete(location: location)
            }
            
            locationCollectionView.deleteItems(at: selectedCells)
            removeButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        allLocations.load()
        locations = allLocations.getAll()
        self.locationCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as! LocationCollectionViewCell
        let location = locations[indexPath.row]
        cell.updateView(name: location.name,coordinates: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        cell.isInEditingMode = isEditing
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        locationCollectionView.allowsMultipleSelection = editing
        let indexPaths = locationCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = locationCollectionView.cellForItem(at: indexPath) as! LocationCollectionViewCell
            cell.isInEditingMode = editing
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            removeButton.isEnabled = false
        } else {
            removeButton.isEnabled = true
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
            removeButton.isEnabled = false
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
