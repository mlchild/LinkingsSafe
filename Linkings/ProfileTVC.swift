//
//  ProfileTVC.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class ProfileTVC: UITableViewController {
    
    var shouldReloadOnAppear = false
    var shouldRefreshOnAppear = false

    var userDisplaying = PFUser.currentUser()
    
    var displayingCurrentUser: Bool {
        return userDisplaying?.objectId == PFUser.currentUser()?.objectId
    }
    
    var posts = [PFPost]()
    var upvotes = [PFActivity]()
    
    let activityTypeSegOrder = [PFActivity.ActivityType.Entry, PFActivity.ActivityType.Upvote] //this order doesn't really matter, could be a set
    var selectedActivityType = PFActivity.ActivityType.Entry {
        didSet {
            if selectedActivityType != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    enum Section: Int {
        case UserInfo
        case ActivitySeg
        case Activity
    }
    enum UserInfoType: Int {
        case Username
        case Cash
        case AddCash
    }

    //MARK: - Basics
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PROFILE"
        
        fetchProfile()
        refreshControl?.addTarget(self, action: "fetchProfile", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.estimatedRowHeight = 66
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
            fetchProfile()
        }
    }
    
    func fetchDataChanged() {
        shouldRefreshOnAppear = true
    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Section.Activity.rawValue + 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        switch section {
        case .UserInfo:
            return UserInfoType.AddCash.rawValue + 1
        case .ActivitySeg:
            return upvotes.count > 0 ? 1 : 0
        case .Activity:
            switch selectedActivityType {
            case .Upvote:
                return upvotes.count
            case .Entry:
                return posts.count
            default: return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        guard let section = Section(rawValue: indexPath.section) else {
            return cell
        }
        
        switch section {
        case .UserInfo:
            let textCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.profileTextCellSimple)!
            configureTextCell(textCell, forRowAtIndexPath: indexPath)
            cell = textCell
        case .ActivitySeg:
            let segCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.profileActivityTypeSegCell)!
            configureActivitySegCell(segCell)
            cell = segCell
        case .Activity:
            let postCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.postCellProfile)!
            configurePostCell(postCell, forRowAtIndexPath: indexPath)
            cell = postCell
        }

        return cell
    }
    
    func configureTextCell(cell: TextTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.title.textColor = UIColor.veryDarkGrayShoebox()
        guard let userInfoType = UserInfoType(rawValue: indexPath.row) else {
            cell.title.text = " " //so it doesn't kill auto layout
            return
        }
        
        let name = userDisplaying?.facebookName
        var cashBalanceText = "Loading balance..."
        if let privateUser = userDisplaying?.privateUser where privateUser.dataAvailable {
            let balance = privateUser.cashBalance ?? 0
            cashBalanceText = "CASH VALUE: " + balance.format(Currency.USD)
        }

        switch userInfoType {
        case .Username:
            cell.title.text = name
        case .Cash:
            cell.title.text = cashBalanceText
        case .AddCash:
            cell.title.text = "ADD CASH"
            cell.title.textColor = UIColor.green1976()
        }
    }
    
    func configureActivitySegCell(segCell: SegButtonCell) {
        
        segCell.firstButtonView.setupWithTitle("\(posts.count)",
            action: { self.selectedActivityType = .Entry },
            image: R.image.comment,
            selected: selectedActivityType == .Entry)
        
        segCell.secondButtonView.setupWithTitle("\(upvotes.count)",
            action: { self.selectedActivityType = .Upvote },
            image: R.image.upvote,
            selected: selectedActivityType == .Upvote)
    }
    
    func configurePostCell(postCell: PostTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        var post: PFPost?
        switch selectedActivityType {
        case .Entry:
            guard posts.count > indexPath.row else {
                return
            }
            post = posts[indexPath.row]
        case .Upvote:
            guard upvotes.count > indexPath.row else {
                return
            }
            post = upvotes[indexPath.row].post
        default: break
        }
        
        guard let postToShow = post else {
            log.error("No post for indexPath \(indexPath), activity mode \(selectedActivityType), posts \(posts), upvotes \(upvotes)")
            return
        }
        
        postCell.upvoteButton.indexPath = indexPath //has to be in ip knowledgeable function
        postCell.configureWithPost(postToShow)
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        
        switch section {
        case .UserInfo:
            guard let userInfoType = UserInfoType(rawValue: indexPath.row) else {
                return
            }
            switch userInfoType {
            case .AddCash:
                performSegueWithIdentifier(R.segue.profileTVC.showDeposit, sender: self)
            default: break
            }
        default: break
        }
    }
    
    //MARK: - Fetch
    func fetchProfile() {
        
        PFCloud.callFunctionInBackground("fetchFullUser", withParameters: nil) { (object, error) -> Void in
            if let user = object as? PFUser, let privateUser = user.privateUser where error == nil {
                self.userDisplaying = user
                log.debug("private user \(privateUser)")
                self.reloadDataSoftly()
                self.fetchPastActivity()
            } else {
                log.error("Error fetching my user, result \(object), error: \(error)")
            }
        }
    }
    
    func fetchPastActivity() {
        FetchManager.fetchMyPostsOnPastContests { (posts, postError) -> () in
            guard let userPosts = posts where postError == nil else {
                log.error("Error fetching my posts \(postError)")
                MRProgressOverlayView.showErrorWithStatus("Error fetching user activity")
                return
            }
            self.posts = userPosts
            
            FetchManager.fetchMyUpvotesOnPastContests(completion: { (upvotes, upvoteError) -> () in
                if let userUpvotes = upvotes where upvoteError == nil {
                    self.upvotes = userUpvotes
                } else {
                    log.error("Error fetching my upvotes \(upvoteError)")
                    MRProgressOverlayView.showErrorWithStatus("Error fetching user activity")
                    return
                }
                self.reloadDataSoftly() //reload either way, don't use guard
            })
        }
    }
}
