//
//  ViewController.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 10/12/18.
//  Copyright © 2018 Kotalogue. All rights reserved.
//

import UIKit
import Toast_Swift

class ViewController: UIViewController, UICollectionViewDelegate {
    
    //MARK: Outlet
    @IBOutlet weak var iconAdd: UIImageView!
    @IBOutlet weak var todoListCollectionView: UICollectionView!
    
    //MARK: Props
    var todoList = [ModelTodo]()
    var listPicked = [String]()
    let userDefaults = UserDefaults.standard
    let publicFunctions = PublicFunction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //user already set the userdefault list picked
        if let itemsListPicked = userDefaults.array(forKey: "ListPicked") {
            listPicked = itemsListPicked as! [String]
        } /* user first time open the apps */
        else{
            userDefaults.set(listPicked, forKey: "ListPicked")
        }
        
        //check if userdefault is nil or no, if its not then clone the userdefault array to todoList array
        if let itemsTodoList = userDefaults.data(forKey: "TodoListArray") {
            let todoData = itemsTodoList
            let todoArray = try! JSONDecoder().decode([ModelTodo].self, from: todoData)
            todoList = todoArray
        }
        
        //init collection view
        initTodoListCollectionView()
        
        //change view color here
        changeStatusBar()
        changeUIColor()
        
        //add gesture recognizer
        addGestureRecognizer()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func addGestureRecognizer() {
        iconAdd.isUserInteractionEnabled = true
        iconAdd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTodoList)))
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
            
            let currentDate = self.publicFunctions.dateLongToString(dateInMillis: self.publicFunctions.currentTimeInMilliSeconds(), pattern: "yyyy-MM-dd")
            
            self.todoList.append(ModelTodo(todoName: alertInputTodo.text?.trim(), createdTime: currentDate))
            let todoListUserDefault = try! JSONEncoder().encode(self.todoList)
            self.userDefaults.set(todoListUserDefault, forKey: "TodoListArray")
            
            self.todoListCollectionView.reloadData()
            //print(self.userDefaults.array(forKey: "TodoListArray")!)
            
            alert.dismiss(animated: true, completion: nil)
            //self.todoListCollectionView.insertItems(at: <#T##[IndexPath]#>)
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
    func changeStatusBar(){
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(rgb: 0x73AAFF).withAlphaComponent(1.0)
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @objc func rootViewClick(sender: UITapGestureRecognizer){
        if let indexPath = self.todoListCollectionView.indexPathForItem(at: sender.location(in: self.todoListCollectionView)){
            
            //init the cell of row if you need it
            let cell = self.todoListCollectionView.cellForItem(at: indexPath) as! TodoListCell
            
            let todoData = userDefaults.data(forKey: "TodoListArray")
            let todoArray = try! JSONDecoder().decode([ModelTodo].self, from: todoData!)
            
            if listPicked.contains(todoArray[indexPath.row].todoName!) {
                listPicked = listPicked.filter{ $0 != todoArray[indexPath.row].todoName }
                userDefaults.set(listPicked, forKey: "ListPicked")
                publicFunctions.changeTintColor(imageView: cell.iconCheck, hexCode: 0x000000, alpha: 1.0)
            } else{
                listPicked.append(todoArray[indexPath.row].todoName!)
                userDefaults.set(listPicked, forKey: "ListPicked")
                publicFunctions.changeTintColor(imageView: cell.iconCheck, hexCode: 0x73AAFF, alpha: 1.0)
            }
        }
    }
    
    @objc func editTodoName(sender: UITapGestureRecognizer){
        if let indexPath = self.todoListCollectionView?.indexPathForItem(at: sender.location(in: self.todoListCollectionView)) {
            
            var alertTextField = UITextField()
            
            let alert = UIAlertController(title: "Change Todo List", message: nil, preferredStyle: .alert)
            
            alert.addTextField {
                (inputTextField) in
                alertTextField = inputTextField
                
                let todoData = self.userDefaults.data(forKey: "TodoListArray")
                let todoArray = try! JSONDecoder().decode([ModelTodo].self, from: todoData!)
                
                inputTextField.text = todoArray[indexPath.row].todoName
            }
            
            alert.addAction(UIAlertAction(title: "Change Todo", style: .default, handler: {
                (uiAlertAction) in
                if alertTextField.text?.trim() == ""{
                    self.view.makeToast("Anda belum memasukan Todo name yang baru")
                    return
                }
                
                let currentDate = self.publicFunctions.dateLongToString(dateInMillis: self.publicFunctions.currentTimeInMilliSeconds(), pattern: "yyyy-MM-dd")
                
                print(currentDate)
                
                self.todoList[indexPath.row] = ModelTodo(todoName: alertTextField.text?.trim(), createdTime: currentDate)
                let todoListUserDefault = try! JSONEncoder().encode(self.todoList)
                self.userDefaults.set(todoListUserDefault, forKey: "TodoListArray")

                if self.listPicked[optional: indexPath.row] != nil {
                    self.listPicked[indexPath.row] = (alertTextField.text?.trim())!
                    self.userDefaults.set(self.listPicked, forKey: "ListPicked")
                }
    
                self.todoListCollectionView.reloadData()
            }))
            
            present(alert, animated: true)
            
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

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userDefaults.array(forKey: "TodoListArray") != nil ? (userDefaults.array(forKey: "TodoListArray")?.count)! : todoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as! TodoListCell
        
        //decode the user default custom object array
        let todoData = userDefaults.data(forKey: "TodoListArray")
        let todoArray = try! JSONDecoder().decode([ModelTodo].self, from: todoData!)
        
        //set content
        cell.todoName.text = todoArray[indexPath.row].todoName
        
        //check if the item in this position is saved in user default or no
        if listPicked.contains(todoArray[indexPath.row].todoName!) {
            //change the color tint to blue
            publicFunctions.changeTintColor(imageView: cell.iconCheck, hexCode: 0x73AAFF, alpha: 1.0)
        } else{
            //change the color tint to black
            publicFunctions.changeTintColor(imageView: cell.iconCheck, hexCode: 0x000000, alpha: 1.0)
        }
        
        //handle click for item
        cell.iconEdit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editTodoName(sender:))))
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
