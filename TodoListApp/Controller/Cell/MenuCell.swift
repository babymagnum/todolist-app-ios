//
//  MenuCell.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 25/01/19.
//  Copyright © 2019 Kotalogue. All rights reserved.
//

import UIKit

class MenuCell: UICollectionViewCell {
    
    @IBOutlet weak var contentMain: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var arrowRight: UIImageView!
    
    override func awakeFromNib() {
        PublicFunction().changeTintColor(imageView: arrowRight, hexCode: 0x000000, alpha: 0.9)
    }
    
    var dataMenu: MenuModel? {
        didSet {
            if let data = dataMenu {
                text.text = data.text
                icon.image = UIImage(named: data.image!)
            }
        }
    }
}
