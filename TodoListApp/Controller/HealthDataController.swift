//
//  HealthDataController.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 25/01/19.
//  Copyright © 2019 Kotalogue. All rights reserved.
//

import UIKit

class HealthDataController: UIViewController, UICollectionViewDelegate {
    
    var listImage = [ImageModel]()
    var listMenu = [MenuModel]()
    var titleAppear = false

    @IBOutlet weak var contentMainHeight: NSLayoutConstraint!
    @IBOutlet weak var menuCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var layoutHealthData: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var iconSearch: UIImageView!
    @IBOutlet weak var layoutSearch: UIView!
    @IBOutlet weak var imageMainCollectionView: UICollectionView!
    @IBOutlet weak var imageMainCollectionHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setupView()
        setupCollection()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !titleAppear {
            self.navigationItem.title = ""
        }
    }
    
    private func setupView() {
        contentMainHeight.constant = layoutHealthData.frame.height
        
        layoutSearch.layer.cornerRadius = 10
        PublicFunction().changeTintColor(imageView: iconSearch, hexCode: 0xCBCBCB, alpha: 1.0)
        
        // Find size for blur effect.
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let bounds = self.navigationController?.navigationBar.bounds.insetBy(dx: 0, dy: -(statusBarHeight)).offsetBy(dx: 0, dy: -(statusBarHeight))
        // Create blur effect.
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        visualEffectView.frame = bounds!
        
        // Set navigation bar up.
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.addSubview(visualEffectView)
        navigationController?.navigationBar.sendSubviewToBack(visualEffectView)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let buttonProfile = UIButton(type: .system)
        buttonProfile.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        buttonProfile.setImage(UIImage(named: "profile")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonProfile)
    }
    
    private func setupCollection() {
        imageMainCollectionView.delegate = self
        imageMainCollectionView.dataSource = self
        imageMainCollectionView.showsVerticalScrollIndicator = false
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.showsVerticalScrollIndicator = false
        
        //populate image collectionview data
        for index in 0...3 {
            var imageModel = ImageModel()
            imageModel.id = index
            listImage.append(imageModel)
            
            if index == 3 {
                self.imageMainCollectionView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.imageMainCollectionHeight.constant = self.imageMainCollectionView.contentSize.height
                    self.contentMainHeight.constant = self.imageMainCollectionView.contentSize.height
                }
            }
        }
        
        //populate list menu
        listMenu.append(MenuModel(id: 0, text: "Body Measurements", image: "body"))
        listMenu.append(MenuModel(id: 1, text: "Health Records", image: "health"))
        listMenu.append(MenuModel(id: 2, text: "Heart", image: "heart"))
        listMenu.append(MenuModel(id: 3, text: "Reproductive Health", image: "reproductive"))
        listMenu.append(MenuModel(id: 4, text: "Results", image: "result"))
        listMenu.append(MenuModel(id: 5, text: "Vitals", image: "vitals"))
        menuCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.menuCollectionHeight.constant = self.menuCollectionView.contentSize.height
            self.contentMainHeight.constant += self.menuCollectionView.contentSize.height
        }
    }

}

extension HealthDataController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let thePosition = titleText.frame
        
        if scrollView.bounds.contains(thePosition) {
            self.navigationItem.title = ""
            self.titleAppear = false
        } else {
            self.navigationItem.title = "Health Data"
            self.titleAppear = true
        }
    }
}

//MARK: Handle gesture recognizer
extension HealthDataController {
    @objc func imageClick(sender: UITapGestureRecognizer) {
        if let indexPath = imageMainCollectionView.indexPathForItem(at: sender.location(in: imageMainCollectionView)) {
            switch listImage[indexPath.item].id {
            case 0:
                if !titleAppear { self.navigationItem.title = "Health Data" }
                let activityController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ActivityController") as! ActivityController
                self.navigationController?.pushViewController(activityController, animated: true)
            case 1: performSegue(withIdentifier: "MindfulnessController", sender: self)
            case 2: performSegue(withIdentifier: "NutritionController", sender: self)
            default: performSegue(withIdentifier: "SleepController", sender: self)
            }
        }
    }
}

extension HealthDataController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageMainCollectionView {
            return listImage.count
        } else {
            return listMenu.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == imageMainCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageMainCell", for: indexPath) as! ImageMainCell
            cell.imageData = listImage[indexPath.item]
            cell.image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClick(sender:))))
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as! MenuCell
            cell.dataMenu = listMenu[indexPath.item]
            return cell
        }
    }
}

extension HealthDataController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == imageMainCollectionView {
            let size = (UIScreen.main.bounds.width / 2) - 25
            
            return CGSize(width: size, height: size)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as! MenuCell
            let width = UIScreen.main.bounds.width
            let height = cell.icon.frame.height + 30
            return CGSize(width: width, height: height)
        }
        
    }
}
