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
    //TODO: photo on swipe rigth?
    
    var posts = [PFPost]()
    var contest: PFContest? {
        didSet {
            newContest = true
        }
    }
    var newContest = false
    
    var disabledUpvotePaths = Set([NSIndexPath]())
    
    var shouldReloadOnAppear = true //resize first time
    var shouldRefreshOnAppear = false

    enum Section: Int {
        case Title
        case Posts
    }
    
    //MARK: - Basics
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "LINKINGS"
        
        fetchPosts()
        refreshControl?.addTarget(self, action: "fetchPosts", forControlEvents: .ValueChanged)
        
        tableView.estimatedRowHeight = 140
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
        return Section.Posts.rawValue + 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        switch sectionType {
        case .Title: return contest != nil ? 1 : 0
        case .Posts: return posts.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            log.error("No section type at indexPath \(indexPath)")
            return UITableViewCell()
        }
        
        var cell = UITableViewCell()
        switch section {
        case .Title:
            let titleCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.contestTitleCellAvenir)!
            configureTitleCell(titleCell, forRowAtIndexPath: indexPath)
            cell = titleCell
        case .Posts:
            let postCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.postCellAvenir)!
            configurePostCell(postCell, forRowAtIndexPath: indexPath)
            cell = postCell
        }
        
        return cell
    }
    
    func configureTitleCell(titleCell: ContestTitleCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let start = contest?.startTime, end = contest?.endTime, let entries = contest?.contestEntryCount, let prizes = contest?.totalPrizeInDollars else {
            return
        }
        titleCell.title.text = start.formattedDateWithStyle(.MediumStyle)
        configureCountdownLabel(titleCell.countdownLabel, endTime: end)
        titleCell.entryCountLabel.text = "\(entries)"
        titleCell.prizeLabel.text = prizes.format(Currency.USD)
    }
    
    func configureCountdownLabel(countdownLabel: MZTimerLabel, endTime: NSDate) {
        if endTime.secondsUntil() > 0 && !countdownLabel.counting {
            countdownLabel.timerType = MZTimerLabelTypeTimer
            countdownLabel.setCountDownTime(endTime.secondsUntil())
            countdownLabel.startWithEndingBlock({ (countTime) -> Void in
                //self.configureCountdownLabel(countdownLabel) //restart, perhaps reload?
                self.fetchPosts()
            })
        } else {
            countdownLabel.text = nil
        }
    }
    
    func configurePostCell(postCell: PostTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let post = postForIndexPath(indexPath) else {
            return
        }
        
        postCell.upvoteButton.indexPath = indexPath //has to be in ip knowledgeable function
        postCell.configureWithPost(post)
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewAutomaticDimension
        }
        switch section {
        case .Title: return 76
        default: return UITableViewAutomaticDimension
        }
    }
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
        FetchManager.fetchAllPostsOnCurrentContest { (posts, error) -> () in
            guard let newPosts = posts where error == nil else {
                log.error("Error fetching posts \(error)")
                MRProgressOverlayView.showErrorWithStatus("Error fetching posts")
                self.refreshControl?.endRefreshing()
                return
            }
            
            self.posts = newPosts //okay if empty
            
            guard let contest = newPosts.first?.contest where contest.dataAvailable else {
                log.debug("No posts or error getting contest from posts \(newPosts)")
                self.fetchCurrentContest()
                return
            }
            self.saveContest(contest)
        }
    }
    
    func fetchCurrentContest() {
        FetchManager.currentContest { (contest, contestError) -> () in
            guard let currentContest = contest else {
                log.error("Error fetching contest \(contestError)")
                self.contest = nil
                self.refreshControl?.endRefreshing()
                return
            }
            self.saveContest(currentContest)
        }
    }
    
    func saveContest(contest: PFContest) {
        guard let contestId = contest.objectId else {
            log.error("No contest id \(contest)")
            self.refreshControl?.endRefreshing()
            return
        }
        if self.contest != contest {
            self.contest = contest
            log.debug("new current contest displaying \(self.contest)")
        }
        self.fetchMyPosts(contestId: contestId)
    }
    
    func fetchMyPosts(contestId contestId: String) { //in case not on page 1
        FetchManager.fetchMyPostsOnContest(contestId) { (posts, error) -> () in
            guard let myPosts = posts where error == nil else {
                log.error("Error fetching my posts \(error)")
                MRProgressOverlayView.showErrorWithStatus("Error fetching posts")
                self.refreshControl?.endRefreshing()
                return
            }
            
            let myNewPosts = myPosts.filter({ !self.posts.contains($0) })
            self.posts += myNewPosts

            
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
            
            let _ = CacheManager.sharedCache.cacheMyActivity(upvoteActivity) //changed activity
            if self.newContest {
                self.reloadDataSoftly()
                self.newContest = false
            } else {
                self.reloadDataSoftly(Section.Posts.rawValue, indexPaths: nil)
            }
            
//            for post in changedPosts {
//                if let postIndex = self.posts.indexOf(post),
//                    let postCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: postIndex, inSection: Section.Posts.rawValue)) as? PostTableCell {
//                        self.configurePostCell(postCell, forRowAtIndexPath: NSIndexPath(forRow: postIndex, inSection: Section.Posts.rawValue))
//                }
//            }
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
    @IBAction func composePressed(sender: AnyObject) {
        
        guard let _ = contest else {
            MRProgressOverlayView.showErrorWithStatus("Contest not loaded")
            return
        }
        
        performSegueWithIdentifier(R.segue.contestTVC.compose, sender: self)
    }
    
    //MARK - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else {
            log.error("No segue identifier \(segue)")
            return
        }
        
        if let nav = segue.destinationViewController as? UINavigationController where segueIdentifier == R.segue.contestTVC.compose.identifier,
            let composeVC = nav.viewControllers.first as? ComposeTVC {
            guard let contestToEnter = contest else {
                MRProgressOverlayView.showErrorWithStatus("Contest not loaded")
                return
            }
            composeVC.contestForEntry = contestToEnter
        }
    }
}