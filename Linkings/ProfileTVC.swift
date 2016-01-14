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
    
    var activityByType: [PFActivity.ActivityType : [PFActivity]]? //all activity to show
    let activityTypeSegOrder = [PFActivity.ActivityType.Post, PFActivity.ActivityType.Upvote] //this order doesn't really matter, could be a set
    var selectedActivityType = PFActivity.ActivityType.Post {
        didSet {
            if selectedActivityType != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    enum Section: Int {
        case UserInfo
        case Activity
    }
    enum UserInfoType: Int {
        case Username
        case Cash
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
            return UserInfoType.Cash.rawValue + 1
        case .Activity:
            if let activityShowing = activityByType?[selectedActivityType] {
                return activityShowing.count
            } else {
                return 0
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
            let textCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.usernameCellSimple)!
            configureTextCell(textCell, forRowAtIndexPath: indexPath)
            cell = textCell
        case .Activity:
            break
        }

        return cell
    }
    
    func configureTextCell(cell: TextTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let userInfoType = UserInfoType(rawValue: indexPath.row) else {
            return
        }
        switch userInfoType {
        case .Username:
            cell.title.text = userDisplaying?.facebookName
        case .Cash:
            cell.title.text = "CASH VALUE: $1,729"
        }
    }
    
    //MARK: - Fetch
    func fetchProfile() {
        
    }
}
