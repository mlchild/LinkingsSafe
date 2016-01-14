//
//  ContestTVC.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation
import SafariServices

class ContestTVC: UITableViewController, SFSafariViewControllerDelegate {
    
    var posts = [PFPost]()
    
    var disabledUpvotePaths = Set([NSIndexPath]())
    
    var shouldReloadOnAppear = true //resize first time
    var shouldRefreshOnAppear = false

    enum Section: Int {
        case Posts
    }
    
    //MARK: - Basics
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "LINKINGS"
        
        fetchPosts()
        refreshControl?.addTarget(self, action: "fetchPosts", forControlEvents: .ValueChanged)
        
        tableView.rowHeight = 102
//        tableView.estimatedRowHeight = 88
//        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchDataChanged", name: Constants.NSNotification.FetchDataChanged, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldReloadOnAppear {
            shouldReloadOnAppear = false
            tableView.reloadData()
        }
        
        if shouldRefreshOnAppear {
            shouldRefreshOnAppear = false
            fetchPosts()
        }
    }
    
    func fetchDataChanged() {
        shouldRefreshOnAppear = true
    }

    //MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            log.error("No section type at indexPath \(indexPath)")
            return UITableViewCell()
        }
        
        var cell = UITableViewCell()
        switch section {
        case .Posts:
            let postCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.postCell)!
            configurePostCell(postCell, forRowAtIndexPath: indexPath)
            cell = postCell
        }
        
        return cell
    }
    
    func configurePostCell(postCell: PostTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let post = postForIndexPath(indexPath) else {
            return
        }
        
        postCell.title.text = post.title
        postCell.subtitle.text = post.subtitle
        
        var hostName = post.postURL?.host
        if let host = hostName where host.hasPrefix("www.") {
            hostName = (host as NSString).substringFromIndex(4)
        }
        postCell.urlHostSlugLabel.text = hostName
        
        postCell.upvoteCountLabel.text = post.upvotes != nil ? "\(post.upvotes!)" : "XXX"
        postCell.upvoteButton.indexPath = indexPath
        
        if CacheManager.sharedCache.iUpvoted(post: post) {
            postCell.mainImageView.image = R.image.upvoted
        } else {
            postCell.mainImageView.image = R.image.upvoteLarge
        }
        postCell.mainImageView.setTemplateColor(UIColor.darkGrayShoebox()) //has to be after setting image
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let post = postForIndexPath(indexPath), let postURL = post.postURL else {
            log.error("No post at index path \(indexPath) or missing/invalid url \(postForIndexPath(indexPath))")
            return
        }
        
        let safariVC = SFSafariViewController(URL: postURL)
        safariVC.delegate = self
        presentViewController(safariVC, animated: true, completion: { log.debug("trying to present safari vc \(safariVC)") })
        //radar: issue with swiping https://openradar.appspot.com/24011284
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Helper
    func postForIndexPath(indexPath: NSIndexPath) -> PFPost? {
        guard posts.count > indexPath.row else {
            log.error("No post for index path \(indexPath)")
            return nil
        }
        return posts[indexPath.row]
    }
    
    //MARK: - Fetch Data
    func fetchPosts() {
        FetchManager.fetchPostsOnCurrentContest { (activity, error) -> () in
            guard let postActivity = activity where error == nil else {
                log.error("Error fetching post activity \(error)")
                MRProgressOverlayView.showErrorWithStatus("Error fetching posts")
                self.refreshControl?.endRefreshing()
                return
            }
            
            let newPosts = postActivity.flatMap({ $0.post }).sort({ $0.postScore > $1.postScore })
            if self.posts != newPosts {
                self.posts = newPosts
                self.reloadDataSoftly()
            }
            
            self.fetchMyUpvotes()
        }
    }
    
    func fetchMyUpvotes() {
        FetchManager.fetchMyUpvotesOnCurrentContest { (activity, error) -> () in
            self.refreshControl?.endRefreshing()
            guard let upvoteActivity = activity where error == nil else {
                log.error("Error fetching my upvote activity \(error)")
                MRProgressOverlayView.showErrorWithStatus("Error fetching upvotes")
                return
            }
            
            let changedPosts = CacheManager.sharedCache.cacheMyActivity(upvoteActivity)
            for post in changedPosts {
                if let postIndex = self.posts.indexOf(post),
                    let postCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: postIndex, inSection: Section.Posts.rawValue)) as? PostTableCell {
                        self.configurePostCell(postCell, forRowAtIndexPath: NSIndexPath(forRow: postIndex, inSection: Section.Posts.rawValue))
                }
            }
        }
    }
    
    //MARK: - Presses
    @IBAction func upvotePressed(sender: IndexedButton) {
        guard let ip = sender.indexPath,
            let postCell = tableView.cellForRowAtIndexPath(ip) as? PostTableCell,
            let post = postForIndexPath(ip) else {
                log.error("Missing info for upvote from indexed button \(sender), or row too high for posts \(posts)")
                return
        }
        guard !disabledUpvotePaths.contains(ip) else {
            log.debug("upvote at path currently disabled \(ip)")
            return
        }
        disabledUpvotePaths.insert(ip)
        
        post.upvotePressed({ (success, error) -> Void in
            self.configurePostCell(postCell, forRowAtIndexPath: ip)
            self.disabledUpvotePaths.remove(ip)
        })
        configurePostCell(postCell, forRowAtIndexPath: ip) //synchronous update before async update
        
    }
}