//
//  PublicFunction.swift
//  TodoListApp
//
//  Created by Arief Zainuri on 10/12/18.
//  Copyright © 2018 Kotalogue. All rights reserved.
//

import Foundation
import UIKit

class PublicFunction{
    
//    open func getMilliseconds(stringDate: String, pattern: String) -> Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = pattern
//        let date = dateFormatter.date(from: stringDate)
//        return getDiffernce(toTime: date!)
//    }
//
//    func getDiffernce(toTime:Date) -> Int{
//        let elapsed = NSDate().timeIntervalSince(toTime)
//        return Int(elapsed * 1000)
//    }
    
    open func getCurrentDate(pattern: String) -> String {
        let formater = DateFormatter()
        formater.dateFormat = pattern
        return formater.string(from: Date())
    }
    
    open func getCurrentMillisecond(pattern: String) -> Int{
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return Int((formatter.date(from: getCurrentDate(pattern: pattern))?.timeIntervalSince1970)!)
    }
    
    open func dateLongToString(dateInMillis: Int, pattern: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(exactly: dateInMillis)!))
    }
    
    open func dateStringToInt(stringDate: String, pattern: String) -> Int{
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return Int((formatter.date(from: stringDate)?.timeIntervalSince1970)!)
    }
    
    open func changeStatusBar(hexCode: Int, view: UIView){
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(rgb: hexCode).withAlphaComponent(1.0)
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
    }
    
    open func changeTintColor(imageView: UIImageView, hexCode: Int, alpha: CGFloat) {
        imageView.image = imageView.image!.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(rgb: hexCode).withAlphaComponent(alpha)
    }
    
}
