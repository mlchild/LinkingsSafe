//
//  PFContest.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class PFContest: PFObject, PFSubclassing {
    
    //MARK: - Parse Properties
    @NSManaged private(set) var user: PFUser?
    @NSManaged private var type: String?
    
    enum ContestType: String {
        case Daily = "daily"
    }
    
    //MARK: - Local Properties
    var contestType: PFContest.ContestType? {
        guard let typeString = type, let myType = ContestType(rawValue: typeString) else {
            return nil
        }
        return myType
    }
    
    //MARK: - Parse Necessities
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "PFContest"
    }
}