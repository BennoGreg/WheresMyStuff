//
//  TextFieldTableViewCell.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 09.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

protocol TextCellDelegate {
    func closeCells()
    func passContent(content: String, cellTag: CellTag)
}

class TextFieldTableViewCell: UITableViewCell {
    
    var delegate: TextCellDelegate?

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateTextField(label: String, placeHolder: String, keyBoardType: UIKeyboardType){
        cellLabel.font = UIFont(name: "AppleColorEmoji", size: 13)
        cellLabel.text = label
        valueTextField.font = UIFont(name: "AppleColorEmoji", size: 13)
        valueTextField.placeholder = placeHolder
        valueTextField.keyboardType = keyBoardType
    }
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "TextFieldTableViewCellIdentifier"
    }
    
    // Nib name
    class func nibName() -> String {
        return "TextFieldTableViewCell"
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 44.0
    }
    
    @IBAction func textFieldTouch(_ sender: UITextField) {
        delegate?.closeCells()
    }
    @IBAction func editingChange(_ sender: UITextField) {
        delegate?.passContent(content: sender.text ?? "0", cellTag: .amountCell)
    }
    
    override func prepareForReuse() {
        delegate = nil
        valueTextField.text = nil
    }
    
    
    
    
    
}
