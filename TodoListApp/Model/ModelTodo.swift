//
//  ModelTodo.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 10/12/18.
//  Copyright © 2018 Kotalogue. All rights reserved.
//

import Foundation

class ModelTodo: Codable {
    var todoName, createdTime: String?
    
    init(todoName: String?, createdTime: String?) {
        self.todoName = todoName
        self.createdTime = createdTime
    }
}
