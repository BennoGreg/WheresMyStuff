//
//  AddItemViewController.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 10.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {
    
    
    let itemInstance = ItemClass.itemClass
    var tableView: UITableView!
    var itemName: String?
    let itemCategory = ["Clothing", "Toilet-Article", "IT-Equipment","Leisure-Stuff","Food", "Something else"]
    var currentCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        hideKeyboardWhenTappedAround()
        setupTableView()
        self.title = "Create Item"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentCategory = itemCategory[0]
    }
    
    func setupTableView(){
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height), style: .grouped)
        view.addSubview(tableView)
        
        tableView.register(UINib(nibName: TextFieldTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier())
        tableView.register(UINib(nibName: PickerTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: PickerTableViewCell.reuseIdentifier())
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        if let name = itemName, name != ""{
            itemInstance.save(name: name, type: currentCategory)
            navigationController?.popViewController(animated: true)
        }
        let alert = UIAlertController(title: "Not specified the name", message: "You have to specify the name for the Item", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
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

extension AddItemViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier()) as! TextFieldTableViewCell
            cell.updateTextField(label: "Name: ", placeHolder: "Item Name", keyBoardType: .default)
            cell.delegate = self
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PickerTableViewCell.reuseIdentifier()) as! PickerTableViewCell
            cell.updateCell(currentItem: itemCategory[0], items: itemCategory, indexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }
    

    
}

extension AddItemViewController: TextCellDelegate, ItemPickerDelegate{
    func didChangeValue(item: String, indexPath: IndexPath) {
        currentCategory = item
    }
    
    func closeCells() {
        print("nothing to close")
    }
    
    func passContent(content: String, cellTag: CellTag) {
        if cellTag == .amountCell{
            itemName = content
        }
    }
    
    
}
