//
//  AppearanceManager.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class AppearanceManager {
    
    class func setupAppearance(window: UIWindow?) {
        
        window?.tintColor = UIColor.green1976Opaque()
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont.avenirNextBold(size: 14.0),
            NSForegroundColorAttributeName : UIColor.whiteShoebox()], forState: UIControlState.Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont.avenirNextBold(size: 14.0),
            NSForegroundColorAttributeName : UIColor.veryLightGrayShoebox()], forState: UIControlState.Disabled)
        UIBarButtonItem.appearance().tintColor = UIColor.whiteShoebox()
        
        UIBarButtonItem.my_appearanceWhenContainedIn(UIToolbar.self).setTitleTextAttributes([
            NSFontAttributeName : UIFont.avenirNextBold(size: 14.0),
            NSForegroundColorAttributeName : UIColor.green1976Opaque()], forState: UIControlState.Normal)
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName : UIFont.avenirNextBold(size: 20.0),
            NSForegroundColorAttributeName : UIColor.whiteShoebox()]
        UINavigationBar.appearance().barTintColor = UIColor.green1976()
        UINavigationBar.appearance().translucent = true
        UINavigationBar.appearance().tintColor = UIColor.whiteShoebox()
        UINavigationBar.appearance().barStyle = UIBarStyle.Black //creates white status bar everywhere
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont.avenirNextBold(size: 14.0),
            NSForegroundColorAttributeName : UIColor.whiteShoebox()], forState: UIControlState.Normal)
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont.avenirNextBold(size: 14.0),
            NSForegroundColorAttributeName : UIColor.green1976Opaque()], forState: UIControlState.Selected)
        UISegmentedControl.my_appearanceWhenContainedIn(UISearchBar.self).setTitleTextAttributes([
            NSFontAttributeName : UIFont.avenirNextBold(size: 14.0),
            NSForegroundColorAttributeName : UIColor.green1976Opaque()], forState: UIControlState.Normal)
        UISegmentedControl.my_appearanceWhenContainedIn(UISearchBar.self).setTitleTextAttributes([
            NSFontAttributeName : UIFont.avenirNextBold(size: 14.0),
            NSForegroundColorAttributeName : UIColor.whiteShoebox()], forState: UIControlState.Selected)
        
        
        UITabBar.appearance().barTintColor = UIColor.whiteTabBarShoebox()
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont.avenirNextDemiBold(size: 9.0),
            NSForegroundColorAttributeName : UIColor.darkGrayShoebox()], forState: UIControlState.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont.avenirNextDemiBold(size: 9.0),
            NSForegroundColorAttributeName : UIColor.green1976Opaque()], forState: UIControlState.Selected)
        
        
    }

    
//    class func setupAppearance(window: UIWindow?) {
//        
//        window?.tintColor = UIColor.green1976Opaque()
//        UIBarButtonItem.appearance().setTitleTextAttributes([
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProBold(size: 14.0)!,
//            NSForegroundColorAttributeName : UIColor.whiteShoebox()], forState: UIControlState.Normal)
//        UIBarButtonItem.appearance().setTitleTextAttributes([
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProBold(size: 14.0)!,
//            NSForegroundColorAttributeName : UIColor.veryLightGrayShoebox()], forState: UIControlState.Disabled)
//        UIBarButtonItem.appearance().tintColor = UIColor.whiteShoebox()
//        
//        UIBarButtonItem.my_appearanceWhenContainedIn(UIToolbar.self).setTitleTextAttributes([
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProBold(size: 14.0)!,
//            NSForegroundColorAttributeName : UIColor.green1976Opaque()], forState: UIControlState.Normal)
//        
//        UINavigationBar.appearance().titleTextAttributes = [
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProBold(size: 20.0)!,
//            NSForegroundColorAttributeName : UIColor.whiteShoebox()]
//        UINavigationBar.appearance().barTintColor = UIColor.green1976()
//        UINavigationBar.appearance().translucent = true
//        UINavigationBar.appearance().tintColor = UIColor.whiteShoebox()
//        UINavigationBar.appearance().barStyle = UIBarStyle.Black //creates white status bar everywhere
//        
//        UISegmentedControl.appearance().setTitleTextAttributes([
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProBold(size: 14.0)!,
//            NSForegroundColorAttributeName : UIColor.whiteShoebox()], forState: UIControlState.Normal)
//        UISegmentedControl.appearance().setTitleTextAttributes([
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProBold(size: 14.0)!,
//            NSForegroundColorAttributeName : UIColor.green1976Opaque()], forState: UIControlState.Selected)
//        UISegmentedControl.my_appearanceWhenContainedIn(UISearchBar.self).setTitleTextAttributes([
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProBold(size: 14.0)!,
//            NSForegroundColorAttributeName : UIColor.green1976Opaque()], forState: UIControlState.Normal)
//        UISegmentedControl.my_appearanceWhenContainedIn(UISearchBar.self).setTitleTextAttributes([
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProBold(size: 14.0)!,
//            NSForegroundColorAttributeName : UIColor.whiteShoebox()], forState: UIControlState.Selected)
//        
//        
//        UITabBar.appearance().barTintColor = UIColor.whiteTabBarShoebox()
//        UITabBarItem.appearance().setTitleTextAttributes([
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProDemi(size: 9.0)!,
//            NSForegroundColorAttributeName : UIColor.darkGrayShoebox()], forState: UIControlState.Normal)
//        UITabBarItem.appearance().setTitleTextAttributes([
//            NSFontAttributeName : R.font.iTCAvantGardeGothicProDemi(size: 9.0)!,
//            NSForegroundColorAttributeName : UIColor.green1976Opaque()], forState: UIControlState.Selected)
//        
//        
//    }
}