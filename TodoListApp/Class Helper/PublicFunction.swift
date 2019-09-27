import Foundation
import UIKit
import CoreLocation
import MapKit

class PublicFunction{
    /*
     bottom_right = .layerMaxXMaxYCorner
     bottom_left = .layerMinXMaxYCorner
     top_right = .layerMaxXMinYCorner
     top_left = .layerMinXMinYCorner
     */
    
    let imageCache = NSCache<NSString, UIImage>()
    let imageCacheKey: NSString = "CachedMapSnapshot"
    
    open func getStraightDistance(latitude: Double, longitude: Double) -> Double{
        let location = CLLocation()
        return location.distance(from: CLLocation(latitude: latitude, longitude: longitude))
    }
    
    open func getAddressFromLatLon(pdblLatitude: String, pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil){
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                    return
                }
                
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    
                    var addressString : String = ""
                    
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    print(addressString)
                }
        })
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///  This function converts decimal degrees to radians              ///
    ///////////////////////////////////////////////////////////////////////
    func deg2rad(deg:Double) -> Double {
        return deg * .pi / 180
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///  This function converts radians to decimal degrees              ///
    ///////////////////////////////////////////////////////////////////////
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / .pi
    }
    
    func cacheImage(image: UIImage) {
        imageCache.setObject(image, forKey: imageCacheKey)
    }
    
    func cachedImage() -> UIImage? {
        return imageCache.object(forKey: imageCacheKey)
    }
    
    open func loadStaticMap(_ latitude: Double, _ longitude: Double, _ metters: Double, _ image: UIImageView, _ markerFileName: String) {
        if let cachedImage = self.cachedImage() {
            image.image = cachedImage
            return
        }
        
        let coords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let distanceInMeters: Double = metters
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: coords, latitudinalMeters: distanceInMeters, longitudinalMeters: distanceInMeters)
        options.size = image.frame.size
        
        let bgQueue = DispatchQueue.global(qos: .background)
        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start(with: bgQueue, completionHandler: { [weak self] (snapshot, error) in
            guard error == nil else {
                return
            }
            
            if let snapShotImage = snapshot?.image, let coordinatePoint = snapshot?.point(for: coords), let pinImage = UIImage(named: markerFileName) {
                UIGraphicsBeginImageContextWithOptions(snapShotImage.size, true, snapShotImage.scale)
                snapShotImage.draw(at: CGPoint.zero)
                
                let fixedPinPoint = CGPoint(x: coordinatePoint.x - pinImage.size.width / 2, y: coordinatePoint.y - pinImage.size.height)
                pinImage.draw(at: fixedPinPoint)
                let mapImage = UIGraphicsGetImageFromCurrentImageContext()
                if let unwrappedImage = mapImage {
                    self?.cacheImage(image: unwrappedImage)
                }
                
                DispatchQueue.main.async {
                    image.image = mapImage
                }
                UIGraphicsEndImageContext()
            }
        })
    }
    
    open func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        
        if (unit == "Kilometer") {
            dist = dist * 1.609344
        }
        else if (unit == "Nautical Miles") {
            dist = dist * 0.8684
        }
        return dist
    }
    
    open func getCurrentDate(pattern: String) -> String {
        let formater = DateFormatter()
        formater.dateFormat = pattern
        return formater.string(from: Date())
    }
    
    open func getCurrentMillisecond(pattern: String) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return Double((formatter.date(from: getCurrentDate(pattern: pattern))?.timeIntervalSince1970)! * 1000.0)
    }
    
    open func dateLongToString(dateInMillis: Double, pattern: String) -> String {
        let date = Date(timeIntervalSince1970: (dateInMillis / 1000.0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        return dateFormatter.string(from: date)
    }
    
    open func dateStringToInt(stringDate: String, pattern: String) -> Double{
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return Double((formatter.date(from: stringDate)?.timeIntervalSince1970)! * 1000.0)
    }
    
    open func changeStatusBar(hexCode: Int, view: UIView, opacity: CGFloat){
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(rgb: hexCode).withAlphaComponent(opacity)
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
    }
    
    open func changeTintColor(imageView: UIImageView, hexCode: Int, alpha: CGFloat) {
        imageView.image = imageView.image!.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(rgb: hexCode).withAlphaComponent(alpha)
    }
    
    open func stretchToSuperView(view: UIView){
        view.translatesAutoresizingMaskIntoConstraints = false
        var d = Dictionary<String,UIView>()
        d["view"] = view
        for axis in ["H","V"] {
            let format = "\(axis):|[view]|"
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: [:], views: d)
            view.superview?.addConstraints(constraints)
        }
    }
}

extension UIButton {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIImage {
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}

