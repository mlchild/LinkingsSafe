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
    @NSManaged private(set) var startTime: NSDate?
    @NSManaged private(set) var endTime: NSDate?
    
    @NSManaged private var entryCost: NSNumber?
    @NSManaged private var entryCount: NSNumber?
    @NSManaged private var prizeSum: NSNumber?
    @NSManaged private var prizeTier: NSNumber?
    
    var contestEntryCost: Double? { return entryCost as? Double }
    var contestEntryCount: Int? { return entryCount as? Int }
    var totalPrize: Double? { return prizeSum as? Double }
    var prizeCutoffPercentage: Double? { return prizeTier as? Double }
    
    enum ContestType: String {
        case Daily = "daily"
    }
    
    //MARK: - Local Properties
//    var contestType: PFContest.ContestType? {
//        guard let typeString = type, let myType = ContestType(rawValue: typeString) else {
//            return nil
//        }
//        return myType
//    }
    
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