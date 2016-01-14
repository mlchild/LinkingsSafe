//
//  PFActivity.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class PFActivity: PFObject, PFSubclassing {
    
    //MARK: - Parse Properties
    @NSManaged private(set) var user: PFUser?
    @NSManaged private var type: String?
    
    @NSManaged private(set) var post: PFPost?
    @NSManaged private(set) var contest: PFContest?
    
    @NSManaged private(set) var text: String?
    @NSManaged private(set) var toUser: PFUser?
    
    @NSManaged private var cost: NSNumber?
    
    //MARK: - Local Properties
    var activityType: PFActivity.ActivityType? {
        guard let typeString = type, let myType = ActivityType(rawValue: typeString) else {
            return nil
        }
        return myType
    }
    
    var activityCost: Double? {
        return cost as? Double
    }
    
    //MARK: - Data Types
    struct Property {
        static let user = "user"
        static let type = "type"
        static let post = "post"
        static let contest = "contest"
        static let toUser = "toUser"
    }
    
    enum ActivityType: String {
        case Entry = "entry"
        case Upvote = "upvote"
        case Deposit = "deposit"
    }
    
    //MARK: - High Level Convenience
    class func newEntryInCurrentContest(urlString: String, title: String, subtitle: String?, completion: PFBooleanResultBlock) {
        
        guard urlString.validURL(httpOnly: true) != nil else {
            completion(false, Error.InvalidURL as NSError)
            return
        }
        
        var params = ["url" : urlString, "title" : title]
        params["subtitle"] = subtitle
        
        PFCloud.callFunctionInBackground("newEntryInCurrentContest", withParameters: params) { (object, error) -> Void in
            if let postError = error {
                log.error("Error posting params \(params): \(postError)")
            }
            completion(error == nil, error)
        }
    }
    
    //don't use this for now (james posts)
    private class func newPost(urlString: String, title: String, subtitle: String?, inContest contest: PFContest, completion: PFBooleanResultBlock) {
        do {
            let post = try PFPost(urlString: urlString, title: title, subtitle: subtitle)
            let postActivity = try PFActivity(type: .Entry, post: post, contest: contest)
            postActivity.saveInBackgroundWithBlock(completion)
        } catch {
            completion(false, error as NSError)
        }
    }
    
    
    //MARK: - Init
    convenience init(type: ActivityType,
        post: PFPost?,
        contest: PFContest?,
        text: String? = nil,
        toUser: PFUser? = nil) throws {
            
            self.init()
            self.type = type.rawValue
            self.post = post
            self.contest = contest
            self.text = text
            self.toUser = toUser
            
            guard let currentUser = PFUser.currentUser() else {
                throw Error.NoCurrentUser
            }
            self.user = currentUser
    }
    
    
    //MARK: - Parse Necessities
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "PFActivity"
    }
}