//
//  RootViewController.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class RootViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: handle invalid session token
        if let _ = PFUser.currentUser()  {
            performSegueWithIdentifier(R.segue.rootViewController.showMain, sender: self)
        } else {
            performSegueWithIdentifier(R.segue.rootViewController.login, sender: self)
        }
  
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}