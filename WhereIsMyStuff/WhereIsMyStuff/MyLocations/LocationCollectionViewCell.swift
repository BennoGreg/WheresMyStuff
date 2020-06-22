//
//  LocationCollectionViewCell.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 27.05.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import Mapbox


class LocationCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var mapImage: UIImageView!
    
    @IBOutlet weak var checkMarkLabel: UILabel!
    
    
    
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
    
    
    func updateView(name: String?, coordinates: CLLocationCoordinate2D){
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        

        
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
    
    func getImage(coordinates: CLLocationCoordinate2D, snapShotCompletion: @escaping ((UIImage?) -> Void)){
        let camera = MGLMapCamera(lookingAtCenter: coordinates, altitude: 100, pitch: 20, heading: 0)
        
        let options = MGLMapSnapshotOptions(styleURL: MGLStyle.streetsStyleURL, camera: camera, size: self.bounds.size)
        
        options.zoomLevel = 16
        
        let snapshotter = MGLMapSnapshotter(options: options)
        snapshotter.start { (snapshot, error) in
            if let err = error {
                fatalError(err.localizedDescription)
            }
            snapShotCompletion(snapshot?.image)
        }
    }
    
    
    
}
