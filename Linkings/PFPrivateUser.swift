//
//  PFPrivateUser.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class PFPrivateUser: PFObject, PFSubclassing {
    
    @NSManaged private var balance: NSNumber?
    
    var cashBalance: Double? {
        return balance as? Double
    }
    
    //MARK: - Parse Necessities
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "PFPrivateUser"
    }
}