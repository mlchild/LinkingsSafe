//
//  Extensions.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation
import Crashlytics

//MARK: - Parse
extension PFUser {
    
    struct Property {
        
        static let username = "username"
        static let setUsername = "setUsername"
        
        static let privateUser = "privateUser"
        
        static let profilePhoto = "profilePhoto"
        static let bio = "bio"
        static let website = "website"
        static let featured = "featured"
        
//        static let phoneNumber = "phoneNumber"
//        static let digitsId = "digitsId"
        static let facebookId = "facebookId"
        static let facebookName = "facebookName"
        static let facebookFriends = "facebookFriends"
        static let facebookFriendNames = "facebookFriendNames"
//        static let twitterId = "twitterId"
//        static let instagramId = "instagramId"
//        static let instagramUsername = "instagramUsername"
        static let contactsUsingApp = "contactsUsingApp"
        
//        static let following = "following"
//        static let followingCount = "followingCount"
//        static let followerCount = "followerCount"
        
//        static let blockedByUserIds = "blockedByUserIds"
        
        static let isDebugUser = "isDebugUser"
    }
    
    var facebookName: String? {
        return self[Property.facebookName] as? String
    }
    
    var privateUser: PFPrivateUser? {
        return self[Property.privateUser] as? PFPrivateUser
    }
    
    //user setup
    class func setup() {
        if let currentUser = PFUser.currentUser() {
            
//            NotificationManager.setupNotificationSettings()
            
            let userID = currentUser.objectId
            Crashlytics.sharedInstance().setUserIdentifier(userID)
            if userID == "qKL8N5dGqw" || userID == "6G0w4oSnSg" {
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: PFUser.Property.isDebugUser)
            }
            
        }
    }
}

extension PFObject {
    func decrementKey(key: String, stayPositive: Bool) {
        if let numberValue = self[key] as? NSNumber {
            if stayPositive && numberValue.integerValue <= 0 {
                log.debug("Error: trying to decrement zero or negative value \(numberValue) for key \(key)")
                return
            }
            self.incrementKey(key, byAmount: -1)
        }
    }
}

//MARK: - UIKit
extension UIView {
    
    func findFirstSubviewWithClass<T: UIView>(subviewClass: T.Type) -> T? {
        for subview in self.subviews {
            if subview.isKindOfClass(subviewClass) {
                return (subview as! T)
            }
        }
        return nil
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor: UIColor? {
        get {
            return (layer.borderColor != nil) ? UIColor(CGColor: layer.borderColor!) : nil
        }
        set {
            layer.borderColor = newValue?.CGColor
        }
    }
    
    /// The color of the shadow. Defaults to opaque black. Colors created from patterns are currently NOT supported. Animatable.
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let cgColor  = layer.shadowColor {
                return UIColor(CGColor: cgColor)
            }
            return nil
        }
        set {
            self.layer.shadowColor = newValue?.CGColor
        }
    }
    
    /// The opacity of the shadow. Defaults to 0. Specifying a value outside the [0,1] range will give undefined results. Animatable.
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    /// The shadow offset. Defaults to (0, -3). Animatable.
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    /// The blur radius used to create the shadow. Defaults to 3. Animatable.
    @IBInspectable var shadowRadius: Double {
        get {
            return Double(self.layer.shadowRadius)
        }
        set {
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }

}


extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
    
    class func avenirNextBold(size size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Bold", size: size)!
    }
    class func avenirNextDemiBold(size size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-DemiBold", size: size)!
    }
    class func avenirNextHeavy(size size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Heavy", size: size)!
    }
    class func avenirNextMedium(size size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: size)!
    }
    class func avenirNextMediumItalic(size size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-MediumItalic", size: size)!
    }
    class func avenirNextRegular(size size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: size)!
    }
    class func avenirNextItalic(size size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Italic", size: size)!
    }
    class func avenirNextUltraLight(size size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-UltraLight", size: size)!
    }
    
}

extension UIColor {
    class func green1976() -> UIColor {
        return UIColor(0x70ab99)
    }
    class func green1976Opaque() -> UIColor {
        return UIColor(0x5F9C87)
    }
    class func veryDarkGrayShoebox() -> UIColor {
        return UIColor(0x444444)
    }
    class func darkGrayShoebox() -> UIColor {
        return UIColor(0x666666)
    }
    class func lightGrayShoebox() -> UIColor {
        return UIColor(0x929292)
    }
    class func veryLightGrayShoebox() -> UIColor {
        return UIColor(0xCBCBCB)
    }
    class func whiteShoebox() -> UIColor {
        return UIColor(0xF8F8F8)
    }
    class func whiteTabBarShoebox() -> UIColor {
        return UIColor(white: 0.88, alpha: 1.0)
    }
}

extension UIImageView {
    func setTemplateColor(color: UIColor?) {
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        tintColor = color
    }
}

extension UITableViewController {
    func reloadDataSoftly() {
        if let spinner = refreshControl {
            spinner.endRefreshing()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
}

extension UITableView {
    
    func nextCell(cell: UITableViewCell) -> UITableViewCell? {
        guard let ip = indexPathForCell(cell) else { return nil }
        return nextCellForIndexPath(ip)
    }
    
    func nextCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        guard let nextIP = nextIndexPath(indexPath) else { return nil }
        return cellForRowAtIndexPath(nextIP)
    }
    
    func nextIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        if numberOfRowsInSection(indexPath.section) > indexPath.row + 1 {
            return NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
        } else if numberOfSections > indexPath.section + 1 && numberOfRowsInSection(indexPath.section + 1) > 0 {
            return NSIndexPath(forRow: 0, inSection: indexPath.section + 1)
        }
        return nil
    }
}

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableSuperview: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
}

//MARK: - Foundation
extension String {
    
    func validURL(httpOnly httpOnly: Bool = false) -> NSURL? {
        guard let url = NSURL(string: self) else {
            return nil
        }
        guard (self as NSString).isValidURL() else {
            return nil
        }
        
        if httpOnly {
            if url.scheme == "" {
                let newURLString = "http://" + url.absoluteString
                return newURLString.validURL(httpOnly: httpOnly) //recursion with http added on
            }
            guard url.scheme == "http" || url.scheme == "https" else {
                return nil
            }
        }
        
        return url
    }
    
    func removeDecimal() -> String {
        return componentsSeparatedByString(".").first!
    }
}

