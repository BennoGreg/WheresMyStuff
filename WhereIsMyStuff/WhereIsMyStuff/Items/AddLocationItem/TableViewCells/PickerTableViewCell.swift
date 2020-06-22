//
//  ItemPickerTableViewCell.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 09.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

protocol ItemPickerDelegate {
    func didChangeValue(item: String, indexPath: IndexPath)
}

class PickerTableViewCell: UITableViewCell {
    
    var items = [String]()
    var indexPath: IndexPath!
    var delegate: ItemPickerDelegate?

    @IBOutlet weak var itemPicker: UIPickerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemPicker.delegate = self
        itemPicker.dataSource = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    func updateCell(currentItem: String, items: [String], indexPath: IndexPath) {
        self.items = items
        let index = items.firstIndex(of: currentItem)
        itemPicker.selectRow(index ?? 0, inComponent: 0, animated: true)
        
        self.indexPath = indexPath
    }
    
    class func reuseIdentifier() -> String {
        return "ItemPickerTableViewCellIdentifier"
    }
    
    // Nib name
    class func nibName() -> String {
        return "PickerTableViewCell"
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 180.0
    }
}


extension PickerTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    override func didChangeValue(forKey key: String) {
         let indexPathForDisplayItem = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        
        delegate?.didChangeValue(item: key, indexPath: indexPathForDisplayItem)
            
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPathForDisplayItem = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        
        delegate?.didChangeValue(item: items[row], indexPath: indexPathForDisplayItem)
    }
    
    override func prepareForReuse() {
       super.prepareForReuse()
       delegate = nil
       items = [String]()
       itemPicker.reloadAllComponents()
       itemPicker.dataSource = self  // This is it !
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerlabel = view as? UILabel
        if pickerlabel == nil{
            pickerlabel = UILabel()
            pickerlabel?.textAlignment = NSTextAlignment.center
        }
        
        pickerlabel?.font = UIFont(name: "AppleColorEmoji", size: 16)
        pickerlabel?.text = items[row]
        return pickerlabel!
    }
    
    
    
    
    
}
