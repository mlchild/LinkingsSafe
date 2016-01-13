//
//  SocialManager.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

enum SocialNetwork: String {
    case Facebook = "facebook"
    case Twitter = "twitter"
    case Contacts = "phoneContacts"
    case Instagram = "instagram"
    case Text = "textMessage"
    case Email = "email"
    case Parse = "parse" //just for debug-mode new logins
}

class SocialManager {
    
    typealias SocialNetworkSetupBlock = (user: PFUser?, friendIds: [String]?, error: NSError?) -> ()

    
    //MARK: - Facebook
    class func setupFacebook(completion: SocialNetworkSetupBlock) {
        if PFUser.currentUser() == nil {
            PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "user_friends"], block: { (user, error) -> Void in
                if error != nil || user == nil {
                    log.debug("Error logging in with fb \(error)")
                    completion(user: user, friendIds: nil, error: error)
                } else {
                    self.updateFBOnUser(user!, completion: completion)
                }
            })
        } else if !PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
            PFFacebookUtils.linkUserInBackground(PFUser.currentUser()!, withReadPermissions: ["public_profile", "user_friends"], block: { (success, error) -> Void in
                if error != nil || !success {
                    log.debug("Error linking with fb \(error)")
                    completion(user: PFUser.currentUser()!, friendIds: nil, error: error)
                } else {
                    self.updateFBOnUser(PFUser.currentUser()!, completion: completion)
                }
            })
        } else {
            self.updateFBOnUser(PFUser.currentUser()!, completion: completion)
        }
        AnalyticsManager.callAnalyticsWithEventName("calledSetupFacebook", params: ["currentUserExists" : PFUser.currentUser() != nil])
    }
    
    static let userFieldParams = ["fields" : "id, name"]
    
    class func updateFBOnUser(user:PFUser, completion: SocialNetworkSetupBlock) {
        if user[PFUser.Property.facebookId] == nil || user[PFUser.Property.facebookName] == nil {
            FBSDKGraphRequest(graphPath: "me", parameters: userFieldParams).startWithCompletionHandler({ (connection, result, error) -> Void in
                if let id = result.valueForKey("id") as? String,
                    let name = result.valueForKey("name") as? String where error == nil {
                        
                        user[PFUser.Property.facebookId] = id
                        user[PFUser.Property.facebookName] = name
                        user.saveEventually()
                        self.findFBFriendsForUser(user, completion: completion)
                        
                        AnalyticsManager.callAnalyticsWithEventName("linkedFacebook", params: nil)
                } else {
                    log.debug("Error requesting user info from facebook \(error)")
                    completion(user: user, friendIds: nil, error: error)
                }
            })
        } else {
            findFBFriendsForUser(user, completion: completion)
        }
    }
    
    class func findFBFriendsForUser(user:PFUser, completion: SocialNetworkSetupBlock) {
        FBSDKGraphRequest(graphPath: "me/friends", parameters: userFieldParams).startWithCompletionHandler({ (connection, result, error) -> Void in
            if let friendResult = result,
                let friendObjects = friendResult.valueForKey("data") as? [[String:String]] where error == nil {
                    var friendIds = [String]()
                    var friendNames = [String]()
                    for friendInfo in friendObjects {
                        if let friendId = friendInfo["id"],
                            let friendName = friendInfo["name"] {
                                friendIds.append(friendId)
                                friendNames.append(friendName)
                        }
                    }
                    user[PFUser.Property.facebookFriends] = friendIds
                    user[PFUser.Property.facebookFriendNames] = friendNames
                    user.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if error != nil || !success {
                            completion(user: user, friendIds: nil, error: error)
                        } else {
                            completion(user: user, friendIds: friendIds, error: nil)
                        }
                    })
            } else {
                log.debug("Error requesting friends list from facebook \(error)")
                completion(user: user, friendIds: nil, error: error)
            }
        })
    }
    
    class func getCurrentUserProfilePhotoURL(completion: (urlString: String?, fetchError: NSError?) -> ()) {
        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: ["fields":"url"])
        pictureRequest.startWithCompletionHandler({
            (connection, result, error: NSError!) -> Void in
            log.debug("facebook picture result \(result)")
            if let pictureInfo = result["data"] as? [String:String] where error == nil,
                let url = pictureInfo["url"] {
                    
                    completion(urlString: url, fetchError: error)
            } else {
                completion(urlString: nil, fetchError: error)
            }
        })
    }

    //MARK: - Show errors
    class func showError(error: NSError?, network: SocialNetwork, showWarning: Bool = false, showAlert: Bool = false, presenter: UIViewController? = nil, failedProcessDescription: String? = nil) {
        
        var networkName : String
        switch network {
        case .Facebook:
            networkName = "Facebook"
        case .Twitter:
            networkName = "Twitter"
        case .Contacts:
            networkName = "your contacts"
        case .Instagram:
            networkName = "Instagram"
        case .Text:
            networkName = "iMessage"
        case .Email:
            networkName = "email"
        case .Parse:
            networkName = "Parse"
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let alertPresenter = presenter where showAlert {
                let failAlert = UIAlertController(title: "Problem Logging In", message: "We're having trouble connecting with \(networkName). Perhaps try again.", preferredStyle: UIAlertControllerStyle.Alert)
                failAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                alertPresenter.presentViewController(failAlert, animated: true, completion: nil)
            } else if showWarning {
                MRProgressOverlayView.showErrorWithStatus("Error connecting to \(networkName)", inView: MRProgressOverlayView.sharedView(), afterDelay: 0.4)
            }
        })
        
        log.error("Error with \(network.rawValue) \(failedProcessDescription): \(error)")
    }
}