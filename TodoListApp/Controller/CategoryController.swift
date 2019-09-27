//
//  CategoryController.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 11/12/18.
//  Copyright © 2018 Kotalogue. All rights reserved.
//

import UIKit
import RealmSwift
import Toast_Swift

class CategoryController: UIViewController, UICollectionViewDelegate {
    //MARK: Outlet
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var iconAddCategory: UIImageView!
    
    var realm: Realm!
    var notificationToken: NotificationToken?
    
    //MARK: PROPS
    var categoryName = ""
    var popRecognizer: InteractivePopRecognizer?
    var selectedCategoryID = ""
    var categories = List<Category>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInteractiveRecognizer()
        
        PublicFunction().changeStatusBar(hexCode: 0x73AAFF, view: view, opacity: 1.0)
        
        setupRealm()
        
        changeColorUI()
        
        initCategoryCollectionView()
        
        addGestureRecognizer()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func setupRealm() {
        realm = try! Realm()
        
        let categoryList = realm.objects(Category.self)
        
        for item in categoryList {
            let category = Category()
            category.categoryID = item.categoryID
            category.categoryName = item.categoryName
            categories.append(category)
        }
        
        categoryCollectionView.reloadData()
    }
    
    func changeColorUI() {
        PublicFunction().changeTintColor(imageView: iconAddCategory, hexCode: 0xFFFFFF, alpha: 1.0)
    }
    
    func addGestureRecognizer() {
        iconAddCategory.isUserInteractionEnabled = true
        iconAddCategory.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconAddCategoryClick)))
    }
    
    @objc func iconAddCategoryClick(){
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        
        alert.addTextField {
            (alertTextField) in
            textField = alertTextField
        }
        
        alert.addAction(UIAlertAction(title: "Create New Category", style: .default, handler: {
            (UIAlertAction) in
            
            if textField.text?.trim() == ""{
                self.view.makeToast("Category name cant be empty")
            } else{
                let modelCategory = Category()
                modelCategory.categoryName = textField.text?.trim()
                modelCategory.categoryID = NSUUID().uuidString.lowercased()
                
                try! self.realm.write {
                    self.realm.add(modelCategory)
                    self.categories.append(modelCategory)
                }
                
                self.categoryCollectionView.reloadData()
            }
        }))
        
        present(alert, animated: true)
    }
    
    func saveToCategoryRealm(category: Category) {
        do {
            try realm.write {
                realm.add(category)                
            }
        } catch {
            print("ERROR INSERTING TO REALM, error: \(error)")
        }
    }
    
    func initCategoryCollectionView() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
    }
    
    @objc func categoryViewClick(sender: UITapGestureRecognizer) {
        if let indexPath = self.categoryCollectionView.indexPathForItem(at: sender.location(in: self.categoryCollectionView)){
            selectedCategoryID = categories[indexPath.row].categoryID!
            categoryName = categories[indexPath.row].categoryName!
            
            performSegue(withIdentifier: "toTodoListItem", sender: self)
        }
    }
    
    @objc func editItem(sender: UITapGestureRecognizer){
        if let indexPath = self.categoryCollectionView.indexPathForItem(at: sender.location(in: self.categoryCollectionView)){
            
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Update Category", message: "Update this category by typing new category in the form below.", preferredStyle: .alert)
            
            alert.addTextField { (UITextField) in
                textField = UITextField
                UITextField.text = self.categories[indexPath.row].categoryName
            }
            
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: {
                (UIAlertAction) in
                
                if textField.text?.trim() == ""{
                    self.view.makeToast("Category name cant be empty")
                } else{                    
                    let newCategory = Category()
                    newCategory.categoryID = self.categories[indexPath.row].categoryID
                    newCategory.categoryName = textField.text?.trim()
                    
                    try! self.realm.write {
                        self.realm.add(newCategory, update: true)
                        self.categories[indexPath.row] = newCategory
                    }
                    
                    self.categoryCollectionView.reloadData()
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true)
        }
    }
    
    @objc func deleteItem(sender: UITapGestureRecognizer){
        if let indexPath = self.categoryCollectionView.indexPathForItem(at: sender.location(in: self.categoryCollectionView)){
            
            let alert = UIAlertController(title: "Delete Category", message: "Do you really want to delete \(categories[indexPath.row].categoryName ?? "unknown")??", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {
                (UIAlertAction) in
                let todoItem = self.categories[indexPath.row]
                
                //delete data in row and update
                self.categories.remove(at: indexPath.row)
                self.categoryCollectionView.reloadData()
                
                //then delete in realm
                try! self.realm.write {
                    //delete realm data
                    self.realm.delete(self.realm.objects(Category.self).filter("categoryID=%@", todoItem.categoryID as Any))
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTodoListItem" {
            let destination = segue.destination as! ViewController
            
            destination.categoryID = selectedCategoryID
            destination.backLabel = "Category"
            destination.categoryName = categoryName
        }
        
    }

}

extension CategoryController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryListCell", for: indexPath) as! CategoryListCell
        
        let labelHeight = cell.categoryName.frame.height;
        let iconHeight = cell.iconEdit.frame.height
        let mainHeight = iconHeight > labelHeight ? iconHeight : labelHeight
        let marginTopBot = CGFloat(20)
        
        return CGSize(width: UIScreen.main.bounds.width, height: mainHeight + marginTopBot)
    }
}

extension CategoryController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryListCell", for: indexPath) as! CategoryListCell
        
        cell.categoryName.text = categories[indexPath.row].categoryName
        
        //handle click listener
        cell.contentMain.isUserInteractionEnabled = true
        cell.iconTrash.isUserInteractionEnabled = true
        cell.iconEdit.isUserInteractionEnabled = true
        
        cell.contentMain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(categoryViewClick(sender:))))
        
        cell.iconTrash.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteItem(sender:))))
        
        cell.iconEdit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editItem(sender:))))
        
        return cell
        
    }
    
    
}
