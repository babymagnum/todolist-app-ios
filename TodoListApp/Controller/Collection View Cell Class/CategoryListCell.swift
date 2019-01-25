//
//  CategoryListCell.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 11/12/18.
//  Copyright © 2018 Kotalogue. All rights reserved.
//

import UIKit

class CategoryListCell: UICollectionViewCell {
    //MARK: Outlet
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var iconEdit: UIImageView!
    @IBOutlet weak var iconTrash: UIImageView!
    @IBOutlet weak var contentMain: UIView!
    
    override func awakeFromNib() {}
}
