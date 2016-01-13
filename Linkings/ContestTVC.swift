//
//  ContestTVC.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class ContestTVC: UITableViewController {
    
    var posts = [PFPost]()
    
    var shouldReloadOnAppear = false
    var shouldRefreshOnAppear = false

    enum Section: Int {
        case Posts
    }
    
    
    //MARK: - Basics
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let test = "http://volleythat.com".validURL(httpOnly: true)
        
        title = "LINKINGS"
        
        fetchPosts()
        refreshControl?.addTarget(self, action: "fetchPosts", forControlEvents: .ValueChanged)
        
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableViewAutomaticDimension
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
        guard posts.count > indexPath.row else {
            log.error("No post for index path \(indexPath)")
            return
        }
        
        let post = posts[indexPath.row]
        
        postCell.title.text = post.title
        postCell.subtitle.text = post.subtitle
        postCell.upvoteCountLabel.text = post.upvotes != nil ? "\(post.upvotes)" : nil
        
        postCell.mainImageView.setTemplateColor(UIColor.darkGrayShoebox())
    }
    
    
    //MARK: - Fetch Data
    func fetchPosts() {
        FetchManager.fetchPosts { (activity, error) -> () in
            guard let postActivity = activity where error == nil else {
                log.error("Error fetching post activity \(error)")
                MRProgressOverlayView.showErrorWithStatus("Error fetching posts")
                return
            }
            
            let newPosts = postActivity.flatMap({ $0.post })
            if self.posts != newPosts {
                self.posts = newPosts
                self.reloadDataSoftly()
            }
        }
    }
}