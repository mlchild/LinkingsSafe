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
    @NSManaged private(set) var url: String?
    @NSManaged private(set) var title: String?
    @NSManaged private(set) var subtitle: String?
    @NSManaged private var upvoteCount: NSNumber?
    @NSManaged private var score: NSNumber?
    
    var upvotes: Int? {
        return upvoteCount as? Int
    }
    var postScore: Int? {
        return score as? Int
    }
    var postURL: NSURL? {
        guard let urlString = url, let validURL = NSURL(string: urlString) else {
            log.error("invalid url for post \(url)")
            return nil
        }
        return validURL
    }
    
    struct Property {
        static let upvoteCount = "upvoteCount"
    }
    
    //MARK: - High Level Convenience
    func upvotePressed(completion: PFBooleanResultBlock) {
        if !CacheManager.sharedCache.iUpvoted(post: self) {
            upvoteOrRemoveUpvote(true) { (success, error) -> Void in
                if error as? Error == Error.NoNetworkConnection {
                    MRProgressOverlayView.showErrorWithStatus("No network connection")
                } else if let errorName = error?.userInfo["error"] as? String,
                    let _ = errorName.rangeOfString("already upvoted") {
                        MRProgressOverlayView.showSuccessWithStatus("Already upvoted")
                } else {
                    MRProgressOverlayView.showErrorWithStatus("Error upvoting")
                }
                completion(success, error)
            }
        } else {
            upvoteOrRemoveUpvote(false) { (success, error) -> Void in
                if error as? Error == Error.NoNetworkConnection {
                    MRProgressOverlayView.showErrorWithStatus("No network connection")
                } else {
                    MRProgressOverlayView.showErrorWithStatus("Error removing upvote")
                }
                completion(success, error)
            }
        }
    }
    
    private func upvoteOrRemoveUpvote(upvote: Bool, completion: PFBooleanResultBlock) {
        
        guard let postId = objectId else {
            completion(false, Error.NoObjectId as NSError)
            return
        }
        let params = ["postId" : postId]
        
        CacheManager.sharedCache.iUpvoteOrDeleteMyUpvote(post: self, upvote: upvote)
//        incrementKey(Property.upvoteCount, byAmount: upvote ? 1 : -1) //gets double-counted
        
        PFCloud.callFunctionInBackground(upvote ? "upvotePost" : "deleteUpvote", withParameters: params) { (object, error) -> Void in
            if let upvoteError = error {
                CacheManager.sharedCache.iUpvoteOrDeleteMyUpvote(post: self, upvote: !upvote)
//                self.incrementKey(Property.upvoteCount, byAmount: upvote ? -1 : 1)
                log.error("Error upvoting or removing upvote \(upvote) post \(self): \(upvoteError)")
            }
            completion(error == nil, error)
        }
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