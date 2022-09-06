//
//  FooterView.swift
//  symple-todolist
//
//  Created by 横山　賢一 on 2022/08/30.
//

import UIKit

protocol FooterViewDelegate: AnyObject {
    func plusButtonTapped()
}

class FooterView: UITableViewHeaderFooterView {
    
    var footerViewDelegate: FooterViewDelegate?

    @IBAction func plusButtonTapped(_ sender: Any) {
        footerViewDelegate?.plusButtonTapped()
    }
    
}
