//
//  AddItemLocationViewController.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 08.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class AddItemLocationViewController: UIViewController {

    @IBOutlet weak var itemPicker: UIPickerView!
    @IBOutlet weak var locationPicker: UIPickerView!
    
    var pickerIndexPath: IndexPath?
    var locations = [String]()
    var locationInstance = LocationClass.locations
    var itemInstance = ItemClass.itemClass
    var items = [String]()
    var inputText = ["Item: ", "Location: ", "Amount", "Remark"]
    var inputValues = [String]()
    var amount: String = ""
    var remark: String = ""
    var locationData = [Location]()
    var itemData = [Item]()
    
    var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        setupTableView()
        self.title = "Add Item"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        locationData = locationInstance.getAll()
        var locationTitles = ["Select Location"]
        locationData.forEach { (location) in
            locationTitles.append(location.name ?? "")
        }
        locations = locationTitles
        
        itemData = itemInstance.getAll()
        var titles = ["Select item or add new"]
        itemData.forEach { (item) in
            titles.append(item.itemName ?? "")
        }
        items = titles
        
        inputValues = ["Select item or add new" ,"Select Location", "",""]
        tableView.reloadData()
        
    }
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height), style: .grouped)
        view.addSubview(tableView)
        
        tableView.register(UINib(nibName: PickerValueTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: PickerValueTableViewCell.reuseIdentifier())
        tableView.register(UINib(nibName: PickerTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: PickerTableViewCell.reuseIdentifier())
        tableView.register(UINib(nibName: TextFieldTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier())
        tableView.register(UINib(nibName: TextViewTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: TextViewTableViewCell.reuseIdentifier())
        
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func indexPathToInsertPicker(indexPath: IndexPath) -> IndexPath{
        
        if let pickerIndexPath = pickerIndexPath, pickerIndexPath.row < indexPath.row{
            return indexPath
        }else{
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
    @IBAction func saveItemLocation(_ sender: UIBarButtonItem) {
        
        if inputValues[0] == "Select item or add new" || inputValues[1] == "Select Location" || amount == "0"{
            let alert = UIAlertController(title: "Not specified all Fields", message: "You have to specify some values for Item, Location and amount", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        let location = locationData.first { (location) -> Bool in
            location.name == inputValues[1]
        }
        let item = itemData.first { (item) -> Bool in
            item.itemName == inputValues[0]
        }
        
        let iLInstance = ItemLocationClass.instance
        iLInstance.save(location: location!, item: item!, amount: Int(amount) ?? 0, remarks: remark)
        self.navigationController?.popViewController(animated: true)
        
    }
    

}

extension AddItemLocationViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if let pickerIndexPath = pickerIndexPath, (pickerIndexPath.row - 1 == indexPath.row || indexPath.row >  2){
            tableView.deleteRows(at: [pickerIndexPath], with: .fade)
            self.pickerIndexPath = nil
        } else {
            if let pickerIndexPath = pickerIndexPath{
                tableView.deleteRows(at: [pickerIndexPath], with: .fade)
            }
            var index = indexPath.row;
            if let pickerIndexPath = pickerIndexPath, index > pickerIndexPath.row {
                index -= 1
            }
            switch inputText[index] {
            case "Item: ", "Location: ":
                pickerIndexPath = indexPathToInsertPicker(indexPath: indexPath)
                tableView.insertRows(at: [pickerIndexPath!], with: .fade)
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                tableView.endUpdates()
                return
            }
            
        }
        tableView.endUpdates()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        
        if pickerIndexPath == indexPath {
            return PickerTableViewCell.cellHeight()
        } else {
            var index = indexPath.row;
            if let pickerIndexPath = pickerIndexPath, index > pickerIndexPath.row {
                index -= 1
            }
            switch inputText[index] {
            case "Remark":
                return TextViewTableViewCell.cellHeight()
            case "Amount":
                return TextFieldTableViewCell.cellHeight()
            default:
                return PickerValueTableViewCell.cellHeight()
            }
        }
    }
}

extension AddItemLocationViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pickerIndexPath != nil {
            return inputText.count + 1
        } else {
            return inputText.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if pickerIndexPath == indexPath{
            
            if indexPath.row == 1 {
                let pickerCell = tableView.dequeueReusableCell(withIdentifier: PickerTableViewCell.reuseIdentifier(),for: indexPath) as! PickerTableViewCell
                pickerCell.updateCell(currentItem: inputValues[indexPath.row - 1], items: items, indexPath: indexPath)
                pickerCell.delegate = self
                return pickerCell
            }else{
                let pickerCell = tableView.dequeueReusableCell(withIdentifier: PickerTableViewCell.reuseIdentifier(), for: indexPath) as! PickerTableViewCell
                pickerCell.updateCell(currentItem: inputValues[indexPath.row - 1],items: locations, indexPath: indexPath)
                pickerCell.delegate = self
                return pickerCell
            }
            
    
        }else{
            var index = indexPath.row;
            if let pickerIndexPath = pickerIndexPath, index > pickerIndexPath.row {
                index -= 1
            }
            let text = inputText[index]
            if text == "Amount"{
                let textfieldCell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier()) as! TextFieldTableViewCell
                textfieldCell.updateTextField(label: "Amount: ", placeHolder: "0", keyBoardType: .numberPad)
                textfieldCell.delegate = self
                return textfieldCell
            }else if text == "Remark"{
                let textViewCell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseIdentifier()) as! TextViewTableViewCell
                textViewCell.delegate = self
                return textViewCell
            }else{
                let valueCell = tableView.dequeueReusableCell(withIdentifier: PickerValueTableViewCell.reuseIdentifier()) as! PickerValueTableViewCell
                valueCell.updateText(title: text, value: inputValues[index])
                return valueCell
            }
            
        }
    }
    
    
}

extension AddItemLocationViewController: ItemPickerDelegate, TextCellDelegate{
    func passContent(content: String, cellTag: CellTag) {
        switch cellTag{
        case .amountCell:
            amount = content
        case .remarkCell:
            remark = content
        default:
            print("nothing to do")
        }
    }
    
    
    func didChangeValue(item: String, indexPath: IndexPath) {
        inputValues[indexPath.row] = item
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func closeCells() {
        if let indexPath = pickerIndexPath {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.pickerIndexPath = nil
            tableView.endUpdates()
        }
    }
    
}



enum CellTag: Int {
    case locationPicker, itemPicker, amountCell, remarkCell
}




