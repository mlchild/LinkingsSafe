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
    
    class func fetchPostsOnCurrentContest(page: Int = 0, completion: PFActivityArrayResultBlock) {
        fetchActivityOnContest(.Posts, contestCategory: .Current, page: page, completion: completion)
    }
    class func fetchPostsOnContest(contestId: String, page: Int = 0, completion: PFActivityArrayResultBlock) {
        fetchActivityOnContest(.Posts, contestCategory: .ContestId(id: contestId), page: page, completion: completion)
    }
    
    class func fetchMyUpvotesOnCurrentContest(completion: PFActivityArrayResultBlock) {
        fetchActivityOnContest(.MyUpvotes, contestCategory: .Current, completion: completion)
    }
    class func fetchMyUpvotesOnContest(contestId: String, completion: PFActivityArrayResultBlock) {
        fetchActivityOnContest(.MyUpvotes, contestCategory: .ContestId(id: contestId), completion: completion)
    }
    
    //MARK: - All activity fetch function
    enum ActivityCategory {
        case MyUpvotes
        case Posts
    }
    enum ContestCategory {
        case Current
        case ContestId(id: String)
    }
    static let pageLength = 100

    private class func fetchActivityOnContest(activityCategory: ActivityCategory, contestCategory: ContestCategory, page: Int = 0, completion: PFActivityArrayResultBlock) {
        
        var functionName: String
        var params = [String: AnyObject]()
        
        
        switch activityCategory {
        case .MyUpvotes:
            functionName = "fetchUpvotesByUserFor"
        case .Posts:
            functionName = "fetchPostActivityFor"
            params["skip"] = page * pageLength
            params["limit"] = pageLength
        }
        switch contestCategory {
        case .Current:
            functionName += "CurrentContest"
        case .ContestId(let contestId):
            functionName += "Contest"
            params["contestId"] = contestId
        }
        //let adjustedParams: [String: AnyObject]?  = params.isEmpty ? nil : params
        
        PFCloud.callFunctionInBackground(functionName, withParameters: params) { (result, error) -> Void in
            log.debug("fetch \(activityCategory) activity for contest \(contestCategory) result \(result)")
            guard let postActivity = result as? [PFActivity] where error == nil else {
                log.error("Error fetching \(activityCategory) activity for contest \(contestCategory) : \(error)")
                completion(activity: nil, error: error)
                return
            }
            completion(activity: postActivity, error: nil)
        }
    }
    
    //MARK: - Get current contest
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