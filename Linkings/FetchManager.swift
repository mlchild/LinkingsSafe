//
//  FetchManager.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

typealias PFActivityArrayResultBlock = (activity: [PFActivity]?, activityError: NSError?) -> ()
typealias PFPostArrayResultBlock = (posts: [PFPost]?, postError: NSError?) -> ()
typealias PFContestResultBlock = (contest: PFContest?, contestError: NSError?) -> ()
typealias PFActivityResultBlock = (activity: PFActivity?, activityError: NSError?) -> ()


class FetchManager {
    
    //MARK: - Higher level functions
    
    //posts
    class func fetchAllPostsOnCurrentContest(page: Int = 0, completion: PFPostArrayResultBlock) {
        fetchPosts(.AllPosts, contestCategory: .Current, page: page, completion: completion)
    }
    class func fetchAllPostsOnContest(contestId: String, page: Int = 0, completion: PFPostArrayResultBlock) {
        fetchPosts(.AllPosts, contestCategory: .ContestId(id: contestId), page: page, completion: completion)
    }
    class func fetchMyPostsOnContest(contestId: String, page: Int = 0, completion: PFPostArrayResultBlock) {
        fetchPosts(.MyPosts, contestCategory: .ContestId(id: contestId), page: page, completion: completion)
    }
    class func fetchMyPostsOnPastContests(page: Int = 0, completion: PFPostArrayResultBlock) {
        fetchPosts(.MyPosts, contestCategory: .PastContests, page: page, completion: completion)
    }
    
    //my upvotes--no paging
    class func fetchMyUpvotesOnCurrentContest(completion: PFActivityArrayResultBlock) {
        fetchActivity(.MyUpvotes, contestCategory: .Current, completion: completion)
    }
    class func fetchMyUpvotesOnContest(contestId: String, completion: PFActivityArrayResultBlock) {
        fetchActivity(.MyUpvotes, contestCategory: .ContestId(id: contestId), completion: completion)
    }
    class func fetchMyUpvotesOnPastContests(completion: PFActivityArrayResultBlock) {
        fetchActivity(.MyUpvotes, contestCategory: .PastContests, completion: completion)
    }
    
    
    
    //MARK: - All activity fetch function
    enum ActivityType {
        case MyUpvotes
    }
    enum PostType {
        case MyPosts
        case AllPosts
    }
    
    enum ContestCategory {
        case Current
        case ContestId(id: String)
        case PastContests
        
        func functionSuffix() -> String {
            switch self {
            case .Current:
                return "CurrentContest"
            case .ContestId:
                return "Contest"
            case .PastContests:
                return "PastContests"
            }
        }
    }
    static let pageLength = 100

    private class func fetchActivity(activityCategory: ActivityType, contestCategory: ContestCategory, page: Int = 0, completion: PFActivityArrayResultBlock) {
        
        //function name
        var functionName: String
        
        switch activityCategory {
        case .MyUpvotes:
            functionName = "fetchUpvotesByUserFor"
        }
        
        functionName += contestCategory.functionSuffix()
        
        //params
        var params = [String: AnyObject]()
        switch contestCategory {
        case .ContestId(let contestId): params["contestId"] = contestId
        default: break
        }
        
        //call
        PFCloud.callFunctionInBackground(functionName, withParameters: params) { (result, error) -> Void in
            log.debug("fetch \(activityCategory) activity for contest \(contestCategory) result \(result)")
            guard let postActivity = result as? [PFActivity] where error == nil else {
                log.error("Error fetching \(activityCategory) activity for contest \(contestCategory) : \(error)")
                completion(activity: nil, activityError: error)
                return
            }
            completion(activity: postActivity, activityError: nil)
        }
    }
    
    private class func fetchPosts(postType: PostType, contestCategory: ContestCategory, page: Int = 0, completion: PFPostArrayResultBlock) {
        
        //function name
        var functionName = "fetchPosts"
        
        switch postType {
        case .MyPosts: functionName += "ByUser"
        default: break
        }
        functionName += "For" + contestCategory.functionSuffix()
        
        //params
        var params = [String: AnyObject]()
        params["limit"] = pageLength
        params["skip"] = page * pageLength
        
        switch contestCategory {
        case .ContestId(let contestId): params["contestId"] = contestId
        default: break
        }
        
        //call
        PFCloud.callFunctionInBackground(functionName, withParameters: params) { (result, error) -> Void in
            log.debug("fetch posts for contest \(contestCategory) result \(result)")
            guard let posts = result as? [PFPost] where error == nil else {
                log.error("Error fetching posts for contest \(contestCategory) : \(error)")
                completion(posts: nil, postError: error)
                return
            }
            completion(posts: posts, postError: nil)
        }
    }
    
    
    //MARK: - Get current contest
    class func currentContest(completion: PFContestResultBlock) {
        PFCloud.callFunctionInBackground("getCurrentContest", withParameters: nil) { (object, error) -> Void in
            guard let contest = object as? PFContest where error == nil else {
                completion(contest: nil, contestError: error)
                return
            }
            completion(contest: contest, contestError: nil)
        }
    }
    
    //MARK: - Queries
    class func postActivityQuery() -> PFQuery {
        let postActivityQuery = activityQuery([.Entry])
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