//
//  Category.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 11/12/18.
//  Copyright © 2018 Kotalogue. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var categoryID: String?
    @objc dynamic var categoryName: String?
    
    override static func primaryKey() -> String? {
        return "categoryID"
    }
}

class CategoryList: Object{
    let categoryList = List<Category>()
}
