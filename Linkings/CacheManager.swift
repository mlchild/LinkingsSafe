//
//  CacheManager.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class CacheManager {
    
    //MARK: - Class methods
    class var sharedCache : CacheManager {
        struct Static {
            static let instance = CacheManager()
        }
        return Static.instance
    }
    
    //MARK: - Basics
    let cache = NSCache()
    
    enum CacheAttributeType: String {
        case UpvoteCount = "UpvoteCount"
        case CommentCount = "CommentCount"
        case ReboxCount = "ReboxCount"
        case CurrentUserUpvoted = "iUpvoted"
        case CurrentUserReboxed = "iReboxed"
        case FollowingUsers = "FollowingUsers"
    }
    
    typealias CacheAttributes = [String : AnyObject]
    
    //MARK: - Activity Filtering
    func cacheMyActivity(allActivity: [PFActivity]) -> [PFPost] {
        var postsWithActivity = [PFPost]()
        for activity in allActivity {
            if let onPost = activity.post,
                let activityType = activity.activityType where activity.user?.objectId == PFUser.currentUser()?.objectId {
                    switch activityType {
                    case .Upvote:
                        iUpvoteOrDeleteMyUpvote(post: onPost, upvote: true)
                    default: break
                    }
                    postsWithActivity.append(onPost)
            }
        }
        return postsWithActivity
    }
    
    //MARK: - Upvotes
    func upvoteCount(post post: PFPost) -> Int {
        if let upvoteValue = attribute(CacheAttributeType.UpvoteCount, forObject: post) as? Int {
            return upvoteValue
        }
        return 0
    }
    
    func incrementOrDecrementUpvoteCount(post post: PFPost, increment: Bool) {
        incrementOrDecrementAttribute(CacheAttributeType.UpvoteCount, increment: increment, forObject: post)
    }
    
    func iUpvoted(post post: PFPost) -> Bool {
        if let upvoteValue = attribute(CacheAttributeType.CurrentUserUpvoted, forObject: post) as? Bool {
            return upvoteValue
        }
        return false
    }
    
    func iUpvoteOrDeleteMyUpvote(post post: PFPost, upvote: Bool) {
        setAttribute(CacheAttributeType.CurrentUserUpvoted, value: upvote, forObject: post)
    }
    
    //MARK: - Single-attribute helper functions
    func incrementOrDecrementAttribute(attribute: CacheAttributeType, increment: Bool, forObject object: PFObject) {
        var newAttributes = attributesForObject(object)
        if let intAttributeValue = newAttributes[attribute.rawValue] as? Int {
            newAttributes[attribute.rawValue] = intAttributeValue + 1
        } else {
            newAttributes[attribute.rawValue] = 1
        }
        setAttributes(newAttributes, forObject: object)
    }
    
    func toggleAttribute(attribute: CacheAttributeType, on: Bool, forObject object: PFObject) {
        var newAttributes = attributesForObject(object)
        newAttributes[attribute.rawValue] = on
        setAttributes(newAttributes, forObject: object)
    }
    
    //MARK: - Single-attribute base functions
    func setAttribute(attribute: CacheAttributeType, value: AnyObject, forObject object: PFObject) {
        var newAttributes = attributesForObject(object)
        newAttributes[attribute.rawValue] = value
        setAttributes(newAttributes, forObject: object)
    }
    
    func attribute(attribute: CacheAttributeType, forObject object: PFObject) -> AnyObject? {
        if let attributeValue: AnyObject = attributesForObject(object)[attribute.rawValue] {
            return attributeValue
        }
        return nil
    }
    
    
    //MARK: - All-attribute functions
    func setAttributes(attributes: CacheAttributes, forObject object: PFObject) {
        cache.setObject(attributes, forKey: keyForPFObject(object))
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NSNotification.LocalDataChanged, object: nil)
    }
    
    func attributesForObject(object: PFObject) -> CacheAttributes {
        if let attributes = cache.objectForKey(keyForPFObject(object)) as? CacheAttributes {
            return attributes
        } else {
            return CacheAttributes()
        }
    }
    
    //MARK: - Low-level helpers
    func keyForPFObject(object: PFObject) -> String {
        assert(object.objectId != nil, "No object id for cached post!")
        return "\(object.parseClassName)_\(object.objectId!)"
    }
    
    func clear() {
        cache.removeAllObjects()
    }

}