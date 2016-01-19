//
//  ProfileTVC.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation
import SafariServices

class ProfileTVC: UITableViewController, SFSafariViewControllerDelegate {
    
    var shouldReloadOnAppear = false
    var shouldRefreshOnAppear = false

    var userDisplaying = PFUser.currentUser()
    
    var displayingCurrentUser: Bool {
        return userDisplaying?.objectId == PFUser.currentUser()?.objectId
    }
    
    var posts = [PFPost]()
    var upvotes = [PFActivity]()
    var transactions = [PFActivity]()
    
    var selectedActivityType = ActivityCategory.MyPosts {
        didSet {
            if selectedActivityType != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    enum Section: Int {
        case UserInfo
        case ActivityHeader
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
        case .ActivityHeader, .ActivitySeg:
            return 1
        case .Activity:
            switch selectedActivityType {
            case .MyPosts:
                return posts.count
            case .MyUpvotes:
                return upvotes.count
            case .MyTransactions:
                return transactions.count
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
        case .ActivityHeader:
            let headerCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.sectionHeaderTextCell)!
            headerCell.title.text = "Your Activity".uppercaseString
            cell = headerCell
        case .ActivitySeg:
            let segCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.profileActivityTypeSegCell)!
            configureActivitySegCell(segCell)
            cell = segCell
        case .Activity:
            switch selectedActivityType {
            case .MyPosts, .MyUpvotes:
                let postCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.postCellProfile)!
                configurePostCell(postCell, forRowAtIndexPath: indexPath)
                cell = postCell
            case .MyTransactions:
                let transactionPostCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.transferCellProfile)!
                configureTransactionCell(transactionPostCell, forRowAtIndexPath: indexPath)
                cell = transactionPostCell
            }
            
        }

        cell.configureStandardSeparatorInTableView(tableView, atIndexPath: indexPath)
        return cell
    }
    
    func configureTextCell(cell: TextTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.title.textColor = UIColor.veryDarkGrayShoebox()
        
        guard let userInfoType = UserInfoType(rawValue: indexPath.row) else {
            cell.title.text = " " //so it doesn't kill auto layout
            return
        }
        
        let name = userDisplaying?.username ?? "anonymous"
        var cashBalanceText = "Loading balance..."
        if let privateUser = userDisplaying?.privateUser where privateUser.dataAvailable {
            let balance = privateUser.cashBalanceInDollars ?? 0
            cashBalanceText = "BALANCE: " + balance.format(Currency.USD)
        }

        switch userInfoType {
        case .Username:
            cell.title.text = "\(name)"
        case .Cash:
            cell.title.text = cashBalanceText
        case .AddCash:
            cell.title.text = "ADD CASH"
            cell.title.textColor = UIColor.green1976()
        }
    }
    
    func configureActivitySegCell(segCell: SegButtonCell) {
        
        segCell.firstButtonView.setupWithTitle("\(posts.count)",
            action: { self.selectedActivityType = .MyPosts },
            image: R.image.comment,
            selected: selectedActivityType == .MyPosts)
        
        segCell.secondButtonView.setupWithTitle("\(upvotes.count)",
            action: { self.selectedActivityType = .MyUpvotes },
            image: R.image.upvote,
            selected: selectedActivityType == .MyUpvotes)
        
        segCell.thirdButtonView.setupWithTitle(" ",
            action: { self.selectedActivityType = .MyTransactions },
            image: R.image.transferArrows,
            selected: selectedActivityType == .MyTransactions)
    }
    
    func configurePostCell(postCell: PostTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let postToShow = postForIndexPath(indexPath) else {
            log.error("No post for indexPath \(indexPath), activity mode \(selectedActivityType), posts \(posts), upvotes \(upvotes)")
            return
        }
        
        postCell.upvoteButton.indexPath = indexPath //has to be in ip knowledgeable function
        postCell.configureWithPost(postToShow, showTimeAgo: true)
    }
    
    func configureTransactionCell(transactionCell: PostTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard transactions.count > indexPath.row else { return }
        let transaction = transactions[indexPath.row]
        
        transactionCell.configureWithTransaction(transaction)
    }
    
    func postForIndexPath(indexPath: NSIndexPath) -> PFPost? {
        switch selectedActivityType {
        case .MyPosts:
            guard posts.count > indexPath.row else { return nil }
            return posts[indexPath.row]
        case .MyUpvotes:
            guard upvotes.count > indexPath.row else { return nil }
            return upvotes[indexPath.row].post
        default: return nil
        }
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
        case .Activity:
            if let post = postForIndexPath(indexPath) {
                showPostInSafari(post)
            }
        default: break
        }
    }
    
    func showPostInSafari(post: PFPost) {
        guard let postURL = post.postURL else {
            log.error("Missing/invalid url \(post)")
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
    
    //MARK: - Fetch
    func fetchProfile() {
        
        PFCloud.callFunctionInBackground("fetchFullUser", withParameters: nil) { (object, error) -> Void in
            if let user = object as? PFUser, let privateUser = user.privateUser where error == nil {
                self.userDisplaying = user
                log.debug("private user \(privateUser)")
                self.fetchMyActivity()
            } else {
                log.error("Error fetching my user, result \(object), error: \(error)")
            }
        }
    }
    
    func fetchMyActivity() {
        fetchMyPosts()
    }
    
    func fetchMyPosts() {
        FetchManager.fetchMyPostsOnPastContests { (posts, postError) -> () in
            guard let userPosts = posts where postError == nil else {
                log.error("Error fetching my posts \(postError)")
                MRProgressOverlayView.showErrorWithStatus("Error fetching user activity")
                return
            }
            self.posts = userPosts
            self.fetchMyUpvotes()
        }
    }
    
    func fetchMyUpvotes() {
        FetchManager.fetchMyUpvotesOnPastContests({ (upvotes, upvoteError) -> () in
            guard let userUpvotes = upvotes where upvoteError == nil else  {
                log.error("Error fetching my upvotes \(upvoteError)")
                MRProgressOverlayView.showErrorWithStatus("Error fetching user activity")
                return
            }
            CacheManager.sharedCache.cacheMyActivity(userUpvotes)
            self.upvotes = userUpvotes
            self.fetchMyTransactions()
        })
    }
    
    func fetchMyTransactions() {
        FetchManager.fetchMyTransactions { (transactions, transactionError) -> () in
            if let userTransactions = transactions where transactionError == nil {
                self.transactions = userTransactions
            } else {
                log.error("Error fetching my transactions \(transactionError)")
                MRProgressOverlayView.showErrorWithStatus("Error fetching user activity")
                return
            }
            
        }
        self.reloadDataSoftly() //reload either way, don't use guard
    }
}
