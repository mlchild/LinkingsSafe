//
//  PFPost.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class PFPost: PFObject, PFSubclassing {
    
    //MARK: - Parse Properties
    @NSManaged private(set) var user: PFUser?
    @NSManaged private var url: String?
    @NSManaged private(set) var title: String?
    @NSManaged private(set) var subtitle: String?
    @NSManaged private var upvoteCount: NSNumber?
    
    var upvotes: Int? {
        return upvoteCount as? Int
    }
    
    //MARK: - Init
    convenience init(urlString: String, title: String, subtitle: String?) throws {
        self.init()
        self.title = title
        self.subtitle = subtitle
        
        guard let url = urlString.validURL(httpOnly: true) else {
            throw Error.InvalidURL
        }
        self.url = url.absoluteString
        
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
        return "PFPost"
    }
}