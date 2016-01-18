//
//  PostTableCell.swift
//  Linkings
//
//  Created by Max Child on 1/17/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class PostTableCell: ImageTableCell {
    @IBOutlet weak var upvoteCountLabel: UILabel!
    @IBOutlet weak var upvoteButton: IndexedButton!
    @IBOutlet weak var urlHostSlugLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    
    func configureWithPost(post: PFPost, showTimeAgo: Bool = false) {
        
        //Title/text
        title.text = post.title //TODO: crazy width constraint on label allows for self-sizing height to work, for some reason
        subtitle.text = post.subtitle
        
        //Upvotes
        if CacheManager.sharedCache.iUpvoted(post: post) {
            mainImageView.image = R.image.upvoted
        } else {
            mainImageView.image = R.image.upvoteLarge
        }
        mainImageView.setTemplateColor(UIColor.darkGrayShoebox()) //has to be after setting image
        
        upvoteCountLabel.text = post.upvotes != nil ? "\(post.upvotes!)" : nil
        
        //url + player name (w/prize)
        var hostName = post.postURL?.host ?? ""
        if hostName.hasPrefix("www.") {
            hostName = (hostName as NSString).substringFromIndex(4)
        }
        
        let posterName = post.user?.username
        let posterNameText = posterName != nil ? " via \(posterName!)" : ""
        
        var timeAgoText = ""
        if let created = post.createdAt {
            if created.hoursAgo() < 24 { timeAgoText = " yesterday" }
            else { timeAgoText = " \(created.timeAgoSinceNow())" }
        }
        
        urlHostSlugLabel.text = hostName + (showTimeAgo ? timeAgoText : posterNameText)
        
        //rank/prize badge
        var rankText = ""
        if let upvoteRank = post.upvoteRank {
            rankText = upvoteRank.format(General.Ordinal)
        }
        
        var prizeText = ""
        if let prize = post.postPrizeInDollars where prize > 0 {
            var prizeCurrencyString = prize.format(Currency.USD)
            if prize >= 10 { prizeCurrencyString = prizeCurrencyString.removeDecimal() }
            prizeText = "  \(rankText):💰\(prizeCurrencyString)  "
        }
        prizeLabel.text = prizeText
        
//        urlHostSlugLabel.text = (hostName ?? "") + (posterName != nil ? " via \(posterName!)\(prizeText)" : "")

    }
}