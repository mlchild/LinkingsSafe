//
//  LoginVC.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class LoginVC: TitleImageButtonVC {
    
    func fbLogin() {
        SocialManager.setupFacebook { (user, friendIds, error) -> Void in
            if error != nil || user == nil {
                SocialManager.showError(error, network: SocialNetwork.Facebook, showWarning: false, showAlert: true, presenter: self, failedProcessDescription: "linking")
            } else {
                self.performSegueWithIdentifier(R.segue.loginVC.showMain, sender: self)
            }
        }
    }
    
    override func topButtonPressed(sender: AnyObject) {
        super.topButtonPressed(sender)
        fbLogin()
    }
}