//
//  DashboardViewController.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 18.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var itemLocationClass = ItemLocationClass.instance
    var journeyInstance = JourneyClass.instance
    
    var stuffLocations = [ItemLocation]()
    var journeys = [Journey]()
    

    
    @IBOutlet weak var suitCaseLabel: UILabel!
    @IBOutlet weak var suitCaseImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dashboard"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        stuffLocations = itemLocationClass.suitcase
        stuffLocations.forEach { (itemLocation) in
            print(itemLocation.item?.itemName)
        }
        
        journeys = journeyInstance.allJourneys
        journeys.sort(by: {$0.date!.compare($1.date!) == .orderedDescending})
        collectionView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        
        setImageView()
        
        
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        guard let userInfo = notification.userInfo as? [String: String] else {
            return
        }
        let locationName = userInfo["LocationName"]
        let locationUUID = userInfo["LocationUUID"]
        let alertController = UIAlertController(title: "Do you want to store your stuff here", message: "You are at your location called \(locationName ?? ""). Do you want to store your items here?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { (action) in
            let itemLocationInstance = ItemLocationClass.instance
            itemLocationInstance.unloadSuitcase(uuidString: locationUUID ?? "")
            self.journeys = self.journeyInstance.allJourneys
            self.journeys.sort(by: {$0.date!.compare($1.date!) == .orderedDescending})
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
            }, completion: nil)
            self.setImageView()
        })
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true,completion: nil)
        // Do something now
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.journeys.count == 0) {
            self.collectionView.setEmptyMessage("You haven't made a journey yet :(. \n Click plus to start a new one")
        } else {
            self.collectionView.restore()
        }
        return journeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardCollectionViewCell", for: indexPath) as! DashBoardCollectionViewCell
        let journey = journeys[indexPath.row]
        cell.updateCell(title: "\(journey.startLocation!) to \(journey.endLocation!)")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader{
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DashboardIdentifiers.HeaderID.rawValue, for: indexPath) as! DashboardHeaderView
            header.updateLabel(title: "Past journeys")
            return header
        }
        return UICollectionReusableView()
    }
    
    func setImageView(){
        if !itemLocationClass.suitcase.isEmpty {
            suitCaseLabel.text = "Your suitcase is packed :) \n Add more on \"+\""
            suitCaseLabel.font = UIFont(name: "AppleColorEmoji", size: 16)
            suitCaseImage.image = UIImage(named: "suitcase")
        }else{
            suitCaseLabel.text = "Your suitcase is empty :( \n Create one on \"+\""
            suitCaseLabel.font = UIFont(name: "AppleColorEmoji", size: 16)
            suitCaseImage.image = UIImage(named: "poor")
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

enum DashboardIdentifiers: String {
    case HeaderID = "DashBoardHeaderView"
    case Cell = "DashBoardCollectionViewCell"
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let completedLengthyDownload = Notification.Name("completedLengthyDownload")
}
