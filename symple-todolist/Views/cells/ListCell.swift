//
//  ListCell.swift
//  testDelegateApp
//
//  Created by 横山　賢一 on 2022/08/23.
//

import UIKit
import RealmSwift

protocol ListCellDelegate: AnyObject {
    func tappedPleaseTextField()
}

class ListCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var cellTextField: UITextField!
    
    var listCellDelegate: ListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellTextField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        listCellDelegate?.tappedPleaseTextField()
    }
}
