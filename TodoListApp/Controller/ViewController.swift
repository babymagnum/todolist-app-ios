//
//  ViewController.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 10/12/18.
//  Copyright © 2018 Kotalogue. All rights reserved.
//

import UIKit
import Toast_Swift
import RealmSwift
import SwipeCellKit

class ViewController: UIViewController, UICollectionViewDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var iconAdd: UIImageView!
    @IBOutlet weak var todoListCollectionView: UICollectionView!
    @IBOutlet weak var labelBack: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    
    //MARK: Props
    var backLabel: String?
    var categoryID, categoryName: String?
    var realm: Realm!
    var todoList = List<RealmModelTodo>()
    let publicFunctions = PublicFunction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("Test jam sekarang dari convert an long to string \(PublicFunction().dateLongToString(dateInMillis: PublicFunction().getCurrentMillis(), pattern: "yyyy-MM-dd"))")
        
        print("Jam sekarang with converted time \(PublicFunction().dateLongToString(dateInMillis: PublicFunction().getCurrentMillisecond(pattern: "yyyy-MM-dd, kk:mm"), pattern: "yyyy-MM-dd, kk:mm"))")
        
        labelBack.text = backLabel
        labelTitle.text = categoryName
        
        //setup realm
        reloadData()
        
        //init collection view
        initTodoListCollectionView()
        
        //change view color here
        PublicFunction().changeStatusBar(hexCode: 0x73AAFF, view: view)
        changeUIColor()
        
        //add gesture recognizer
        addGestureRecognizer()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func reloadData() {
        realm = try! Realm()
        
        let todoItems = realm.objects(RealmModelTodo.self).filter("idCategory=%@", categoryID as Any)
        /*
         code to query search filter
         filter("todoName CONTAINS[cd] %@", "u")
        */
        
        todoList.removeAll()
        
        for items in todoItems {
            let todo = RealmModelTodo()
            todo.todoName = items.todoName
            todo.createdTime = items.createdTime
            todo.isDone = items.isDone
            todo.idCategory = items.idCategory
            todo.idTodoName = items.idTodoName
            todo.doneTime = items.doneTime
            todoList.append(todo)
        }
        
        self.todoListCollectionView.reloadData()
    }
    
    func addGestureRecognizer() {
        iconAdd.isUserInteractionEnabled = true
        labelBack.isUserInteractionEnabled = true
        labelBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backClick)))
        iconAdd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTodoList)))
    }
    
    @objc func backClick(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addTodoList(){
        //show alert with textfield
        showAlertWithTextField()
    }
    
    func showAlertWithTextField() {
        let alert = UIAlertController(title: "Add Your Todo", message: "", preferredStyle: .alert)
        
        var alertInputTodo = UITextField()
        
        alert.addTextField { (inputTodo) in
            alertInputTodo = inputTodo
        }
        
        alert.addAction(UIAlertAction(title: "Add Todo", style: .default, handler: {
            (alertAction) in
            
            if alertInputTodo.text?.trim() == ""{
                self.view.makeToast("Ketikan sesuatu sebelum menambahkan ke daftar Todo list")
                return
            }
            
            let todoItem = RealmModelTodo()
            todoItem.createdTime = PublicFunction().getCurrentDate(pattern: "yyyy-MM-dd")
            todoItem.todoName = alertInputTodo.text?.trim()
            todoItem.isDone = false
            todoItem.idCategory = self.categoryID
            todoItem.idTodoName = NSUUID().uuidString.lowercased()
            
            self.todoList.append(todoItem)
            
            //save data to realm here
            try! self.realm.write {
                self.realm.add(todoItem)
            }
            
            self.reloadData()
        }))
        
        present(alert, animated: true)
    }
    
    func initTodoListCollectionView() {
        todoListCollectionView.delegate = self
        todoListCollectionView.dataSource = self
    }
    
    func changeUIColor() {
        publicFunctions.changeTintColor(imageView: iconAdd, hexCode: 0xFFFFFF, alpha: 1.0)
    }
    
    //MARK: Function to change status and text bar color
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @objc func rootViewClick(sender: UITapGestureRecognizer){
        if let indexPath = self.todoListCollectionView.indexPathForItem(at: sender.location(in: self.todoListCollectionView)){
            
            //init the cell of row if you need it
            let cell = self.todoListCollectionView.cellForItem(at: indexPath) as! TodoListCell
            
            let todoData = todoList[indexPath.row]
            
            if  todoData.isDone {
                //update data to un done
                publicFunctions.changeTintColor(imageView: cell.iconCheck, hexCode: 0x000000, alpha: 1.0)
                todoList[indexPath.row].isDone = false
                todoList[indexPath.row].doneTime = PublicFunction().getCurrentDate(pattern: "yyyy-MM-dd , kk:mm")
                
                try! self.realm.write {
                    self.realm.add(todoList[indexPath.row], update: true)
                }
            } else{
                publicFunctions.changeTintColor(imageView: cell.iconCheck, hexCode: 0x73AAFF, alpha: 1.0)
                todoList[indexPath.row].isDone = true
                try! self.realm.write {
                    self.realm.add(todoList[indexPath.row], update: true)
                }
            }
            
            self.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as! TodoListCell
        
        let iconEditHeight = cell.iconEdit.frame.height
        let paddingTopBot = CGFloat(20)
        return CGSize(width: UIScreen.main.bounds.width, height: iconEditHeight + paddingTopBot)
    }
}

extension ViewController: SwipeCollectionViewCellDelegate{
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        //code dibawah ini digunakan untuk men disable orientation
        //guard orientation == .right else { return nil }
        
        let cell = collectionView.cellForItem(at: indexPath) as! TodoListCell
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") {
            (SwipeAction, IndexPath) in
            let alert = UIAlertController(title: "Delete Category", message: "Do you really want to delete \(self.todoList[indexPath.row].todoName ?? "unknown")??", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {
                (UIAlertAction) in
                let todoItem = self.todoList[indexPath.row]
                
                //then delete in realm
                try! self.realm.write {
                    //delete realm data
                    self.realm.delete(self.realm.objects(RealmModelTodo.self).filter("idTodoName=%@", todoItem.idTodoName as Any))
                }
                
                self.reloadData()
                
                cell.hideSwipe(animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel){
                (uiAlert) in
                cell.hideSwipe(animated: true)
            })
            
            self.present(alert, animated: true)
        }
        
        let updateAction = SwipeAction(style: .destructive, title: "Update") {
            (SwipeAction, IndexPath) in
            
            var alertTextField = UITextField()
            
            let alert = UIAlertController(title: "Change Todo List", message: nil, preferredStyle: .alert)
            
            alert.addTextField {
                (inputTextField) in
                alertTextField = inputTextField
                inputTextField.text = self.todoList[indexPath.row].todoName
            }
            
            alert.addAction(UIAlertAction(title: "Change Todo", style: .default, handler: {
                (uiAlertAction) in
                if alertTextField.text?.trim() == ""{
                    self.view.makeToast("Anda belum memasukan Todo name yang baru")
                    return
                }
                
                //change what field you want to change
                self.todoList[indexPath.row].todoName = alertTextField.text?.trim()
                
                try! self.realm.write {
                    self.realm.add(self.todoList[indexPath.row], update: true)
                }
                
                cell.hideSwipe(animated: true)
                
                //reload data
                self.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel){
                (uiAlert) in
                cell.hideSwipe(animated: true)
            })
            
            self.present(alert, animated: true)
        }
        
        // customize the action appearance
        updateAction.backgroundColor = UIColor(rgb: 0xff7675).withAlphaComponent(1.0)
        deleteAction.backgroundColor = UIColor(rgb: 0x74b9ff).withAlphaComponent(1.0)
        
        if orientation == .left {
            return [deleteAction, updateAction]
        } else{
            return [deleteAction, updateAction]
        }
    }
}

extension ViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as! TodoListCell
        
        //make swipe delegate
        cell.delegate = self
        
        //decode the user default custom object array
        let todoData = todoList[indexPath.row]

        //set content
        cell.todoName.text = todoData.todoName
        
        //hide unused item
        cell.iconEdit.isHidden = true
        cell.iconTrash.isHidden = true

        //check if the item in this position is saved in user default or no
        if todoData.isDone {
            //change the color tint to blue
            publicFunctions.changeTintColor(imageView: cell.iconCheck, hexCode: 0x73AAFF, alpha: 1.0)
        } else{
            //change the color tint to black
            publicFunctions.changeTintColor(imageView: cell.iconCheck, hexCode: 0x000000, alpha: 1.0)
        }

        //handle click for item
//        cell.iconEdit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editTodoName(sender:))))
//        cell.iconTrash.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteItem(sender:))))
        cell.rootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rootViewClick(sender:))))
        
        return cell
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension String{
    func trim() -> String{
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
}

extension Collection {
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }
}
