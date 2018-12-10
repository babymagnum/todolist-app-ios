//
//  TodoListCell.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 10/12/18.
//  Copyright © 2018 Kotalogue. All rights reserved.
//

import UIKit

class TodoListCell: UICollectionViewCell {
    //MARK: Outlet
    @IBOutlet weak var todoName: UILabel!
    @IBOutlet weak var iconCheck: UIImageView!
    @IBOutlet weak var iconEdit: UIImageView!
    @IBOutlet weak var rootView: UIView!
    
    override func awakeFromNib() {}
}
