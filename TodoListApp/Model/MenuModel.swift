//
//  MenuModel.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 25/01/19.
//  Copyright © 2019 Kotalogue. All rights reserved.
//

import Foundation
struct MenuModel {
    var id: Int?
    var text, image: String?
    
    init(id: Int, text: String, image: String) {
        self.id = id
        self.text = text
        self.image = image
    }
}
