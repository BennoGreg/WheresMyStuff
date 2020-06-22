//
//  MyHostViewController.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 04.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit
import CoreData

class MyItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let itemLocationClass = ItemLocationClass.instance
    
    var locations: [String]!
    var items: [[ItemLocation]]!
    
    var allItemlocations = [ItemLocation]()
    
    @IBOutlet weak var itemLocationTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locations = [String]()
        items = [[ItemLocation]]()
        allItemlocations = itemLocationClass.loadAllItemLocation()
        allItemlocations.forEach { (itemlocation) in
            if let name = itemlocation.location?.name{
                if !locations.contains(name){
                    locations.append(name)
                    items.append([ItemLocation]())
                }
                if let index = locations.firstIndex(of: name), !items[index].contains(itemlocation){
                    items[index].append(itemlocation)
                }
            }
            
        }
        
        itemLocationTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemLocationCell", for: indexPath) as! ItemLocationTableViewCell
        let item = items[indexPath.section][indexPath.row]
        cell.titleCell.text = item.item?.itemName
        cell.qtyLabel.text = "\(item.amount) Piece(s)"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return locations[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView{
            header.textLabel?.font = UIFont(name: "AppleColorEmoji", size: 13)
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            itemLocationClass.delete(itemLocation: items[indexPath.section][indexPath.row])
            items[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if items[indexPath.section].isEmpty {
                locations.remove(at: indexPath.section)
                items.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            }
        }
    }
    
    
}


