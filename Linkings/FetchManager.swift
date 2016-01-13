//
//  FetchManager.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class FetchManager {
    
    typealias PFActivityArrayResultBlock = (activity: [PFActivity]?, error: NSError?) -> ()
    typealias PFContestResultBlock = (contest: PFContest?, error: NSError?) -> ()
    
    //MARK: - Higher level functions
    class func fetchPosts(completion:PFActivityArrayResultBlock) {
        postActivityQuery().findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let postActivity = objects as? [PFActivity] where error == nil {
                completion(activity: postActivity, error: nil)
            } else {
                completion(activity: nil, error: error)
            }
        }
    }
    
    class func currentContest(completion: PFContestResultBlock) {
        PFCloud.callFunctionInBackground("getCurrentContest", withParameters: nil) { (object, error) -> Void in
            guard let contest = object as? PFContest where error == nil else {
                completion(contest: nil, error: error)
                return
            }
            completion(contest: contest, error: nil)
        }
    }
    
    //MARK: - Queries
    class func postActivityQuery() -> PFQuery {
        let postActivityQuery = activityQuery([.Post])
        return postActivityQuery
    }
    
    class func activityQuery(types: [PFActivity.ActivityType]) -> PFQuery {
        let activityQuery = PFQuery(className: PFActivity.parseClassName())
        let activityTypeStrings = types.map({ $0.rawValue })
        activityQuery.whereKey(PFActivity.Property.type, containedIn: activityTypeStrings)
        activityQuery.includeKey(PFActivity.Property.user)
        activityQuery.includeKey(PFActivity.Property.post)
        activityQuery.includeKey(PFActivity.Property.contest)
        activityQuery.includeKey(PFActivity.Property.toUser)
        return activityQuery
    }
}