//
//  ImageMainCell.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 25/01/19.
//  Copyright © 2019 Kotalogue. All rights reserved.
//

import UIKit

class ImageMainCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    var imageData: ImageModel? {
        didSet {
            if let data = imageData{
                switch data.id {
                case 0: image.image = UIImage(named: "activity")
                case 1: image.image = UIImage(named: "mindfulness")
                case 2: image.image = UIImage(named: "nutrition")
                case 3: image.image = UIImage(named: "sleep")
                default: break
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 2.5, height: 5)
        self.layer.shadowRadius = 5
    }
}
