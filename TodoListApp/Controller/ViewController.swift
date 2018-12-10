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
    var todoList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            self.todoList.append((alertInputTodo.text?.trim())!)
            self.todoListCollectionView.reloadData()
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
        changeTintColor(imageView: iconAdd, hexCode: 0xFFFFFF, alpha: 1.0)
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

    func changeTintColor(imageView: UIImageView, hexCode: Int, alpha: CGFloat) {
        imageView.image = imageView.image!.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(rgb: 0xFFFFFF).withAlphaComponent(alpha)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var alertTextField = UITextField()
        
        let alert = UIAlertController(title: "Change Todo List", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (inputTextField) in
            alertTextField = inputTextField
            inputTextField.text = self.todoList[indexPath.row]
        }
        
        alert.addAction(UIAlertAction(title: "Change Todo", style: .default, handler: {
            (uiAlertAction) in
            if alertTextField.text?.trim() == ""{
                self.view.makeToast("Anda belum memasukan Todo name yang baru")
                return
            }
            
            self.todoList[indexPath.row] = (alertTextField.text?.trim())!
            self.todoListCollectionView.reloadData()
        }))
        
        present(alert, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as! TodoListCell
        
        //set content
        cell.todoName.text = todoList[indexPath.row]
        
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

