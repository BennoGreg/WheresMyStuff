//
//  TextViewTableViewCell.swift
//  WhereIsMyStuff
//
//  Created by Benedikt Langer on 09.06.20.
//  Copyright © 2020 Benedikt. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var remarkTextView: UITextView!
    
    var delegate: TextCellDelegate?
    let placeHolder = "Add some remarks"
    override func awakeFromNib() {
        super.awakeFromNib()
        remarkTextView.font = UIFont(name: "AppleColorEmoji", size: 13)
        remarkTextView.text = placeHolder
        remarkTextView.textColor = .lightGray
        remarkTextView.layer.borderColor = UIColor.systemGray3.cgColor
        remarkTextView.layer.borderWidth = 1
        remarkTextView.layer.cornerRadius =  4
        remarkTextView.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Reuser identifier
    class func reuseIdentifier() -> String {
        return "TextViewTableViewCellIdentifier"
    }
    
    // Nib name
    class func nibName() -> String {
        return "TextViewTableViewCell"
    }
    
    // Cell height
    class func cellHeight() -> CGFloat {
        return 170.0
    }
    
}

extension TextViewTableViewCell: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.closeCells()
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.passContent(content: textView.text, cellTag: .remarkCell)
        delegate?.closeCells()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolder
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    
}
