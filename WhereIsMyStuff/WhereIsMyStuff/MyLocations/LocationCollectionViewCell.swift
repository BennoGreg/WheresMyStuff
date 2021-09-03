//
//  LocationCollectionViewCell.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 27.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import MapboxMaps
import MapboxStatic



class LocationCollectionViewCell: UICollectionViewCell{
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var mapImage: UIImageView!
    
    @IBOutlet weak var checkMarkLabel: UILabel!
    
    var coordinates: CLLocationCoordinate2D?
    var name: String?
    
    
    
    
    var isInEditingMode: Bool = false{
        didSet{
            checkMarkLabel.isHidden = !isInEditingMode
        }
    }
    
    override var isSelected: Bool {
        didSet{
            if isInEditingMode{
                checkMarkLabel.tintColor = .label
                checkMarkLabel.text = isSelected ? "✓" : ""
            }
        }
    }
    
    
    
    fileprivate func createView() {
        if let coordinates = coordinates, let name = name {
            getImage(coordinates: coordinates) { (image) in
                DispatchQueue.main.async {
                    if let image = image{
                        self.mapImage.image = image
                        self.nameLabel.font = UIFont(name: "AppleColorEmoji", size: 13)
                        self.nameLabel.text = name
                    }
                }
            }
        }
    }
    
    func updateView(name: String?, coordinates: CLLocationCoordinate2D){
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.coordinates = coordinates
        self.name = name
        
        createView()
        
    }
    
    func getImage(coordinates: CLLocationCoordinate2D, snapShotCompletion: @escaping ((UIImage?) -> Void)){
        
        //let camera = MGLMapCamera(lookingAtCenter: coordinates, altitude: 100, pitch: 20, heading: 0)
        
        //let options = MapSnapshotOptions(styleURL: MGLStyle.streetsStyleURL, camera: camera, size: self.bounds.size)

        
        let camera = SnapshotCamera(lookingAtCenter: coordinates, zoomLevel: 16, pitch: 20, heading: 0)
        let options = SnapshotOptions(styleURL: URL(string: MapStyle.shared.mapStyleUrl)!, camera: camera, size: self.bounds.size)
        let snapshot = Snapshot(options: options)
        let task = snapshot.image { image, error in
            if let image = image {
                snapShotCompletion(image)
            }
            snapShotCompletion(nil)
        }
        
        task.resume()

    }
        
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        createView()
    }
}


