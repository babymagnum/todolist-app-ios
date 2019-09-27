//
//  RealmModelTodo.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 11/12/18.
//  Copyright © 2018 Kotalogue. All rights reserved.
//

import Foundation
import RealmSwift

class RealmModelTodo: Object {
    @objc dynamic var todoName: String?
    @objc dynamic var createdTime: String?
    @objc dynamic var doneTime: String?
    @objc dynamic var isDone: Bool = false
    @objc dynamic var idCategory: String?
    @objc dynamic var idTodoName: String?
    
    override static func primaryKey() -> String? {
        return "idTodoName"
    }
}
