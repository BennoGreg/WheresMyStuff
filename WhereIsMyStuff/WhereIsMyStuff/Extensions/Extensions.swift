//
//  Extensions.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 09.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import MapboxMaps

extension UIViewController{
    
    func hideKeyboardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

extension MapView {
    
    func hideKeyboardWhenTappedAround(tap: UITapGestureRecognizer){
        
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
}


extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 2;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "AppleColorEmoji", size: 13)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}

