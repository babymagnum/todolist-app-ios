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

    @IBOutlet weak var imageMainCollectionView: UICollectionView!
    @IBOutlet weak var imageMainCollectionHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollection()
    }
    
    private func setupView() {
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
    }
    
    private func setupCollection() {
        imageMainCollectionView.delegate = self
        imageMainCollectionView.dataSource = self
        imageMainCollectionView.showsVerticalScrollIndicator = false
        
        //populate image collectionview data
        for index in 0...3 {
            var imageModel = ImageModel()
            imageModel.id = index
            listImage.append(imageModel)
            
            if index == 3 {
                self.imageMainCollectionView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.imageMainCollectionHeight.constant = self.imageMainCollectionView.contentSize.height
                }
            }
        }
    }

}

//MARK: Handle gesture recognizer
extension HealthDataController {
    @objc func imageClick(sender: UITapGestureRecognizer) {
        if let indexPath = imageMainCollectionView.indexPathForItem(at: sender.location(in: imageMainCollectionView)) {
            switch listImage[indexPath.item].id {
            case 0: performSegue(withIdentifier: "ActivityController", sender: self)
            case 1: performSegue(withIdentifier: "MindfulnessController", sender: self)
            case 2: performSegue(withIdentifier: "NutritionController", sender: self)
            default: performSegue(withIdentifier: "SleepController", sender: self)
            }
        }
    }
}

extension HealthDataController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageMainCell", for: indexPath) as! ImageMainCell
        cell.imageData = listImage[indexPath.item]
        cell.image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClick(sender:))))
        return cell
    }
}

extension HealthDataController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (UIScreen.main.bounds.width / 2) - 25
        
        return CGSize(width: size, height: size)
    }
}
