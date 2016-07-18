//
//  AppDelegate.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Fabric
import Crashlytics
import Stripe

let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FontBlaster.blast() //must be first!
        AppearanceManager.setupAppearance(window)
        
        Fabric.with([Crashlytics.self, STPAPIClient.self])
        
        PFActivity.registerSubclass()
        PFPrivateUser.registerSubclass()
        PFPost.registerSubclass()
        PFContest.registerSubclass()
        Parse.enableLocalDatastore() //for object equality (for now, can use "sameObjects" fxn from GramCracker)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (user, error) -> Void in
            if error != nil || user == nil {
                log.debug("Error fetching current user \(error)")
            }
            PFUser.setup()
        })
        
        //Logger
        log.setup(.Debug, showLogIdentifier: true, showFunctionName: true, showThreadName: true, showLogLevel: false, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLogLevel: .Debug)

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    //MARK: - URL Routing

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
}

