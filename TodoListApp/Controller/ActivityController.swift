//
//  ActivityController.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 25/01/19.
//  Copyright © 2019 Kotalogue. All rights reserved.
//

import UIKit

class ActivityController: UIViewController {
    
    var titleTop: String? {
        didSet {
            if let title = title{
                navigationItem.title = title
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        navigationController?.navigationBar.tintColor = UIColor(rgb: 0xff7675)
        navigationController?.navigationBar.barTintColor = UIColor(rgb: 0xff7675)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
