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
    
    func configureWithTransaction(transaction: PFActivity) {
        guard let transactionType = transaction.activityType else { return }
        
        var amountInCents: Double?
        
        switch transactionType {
        case .Entry:
            title.text = "Entry"
            urlHostSlugLabel.text = " "
            mainImageView.image = R.image.comment
            amountInCents = transaction.details?["cost"] as? Double
        case .Deposit:
            title.text = "Deposit"
            mainImageView.image = R.image.deposit
            amountInCents = transaction.details?["amount"] as? Double
            urlHostSlugLabel.text = "via Apple Pay"
        case .Win:
            title.text = "Winnings"
            mainImageView.image = R.image.win
            amountInCents = transaction.details?["prize"] as? Double
            if let upvoteCount = transaction.details?["upvoteCount"] as? Int,
                let upvoteCountRank = transaction.details?["upvoteCountRank"] as? Int {
                    urlHostSlugLabel.text = "\(upvoteCountRank.format(General.Ordinal)) place: \(upvoteCount) upvote\(upvoteCount != 1 ? "s" : "")"
            } else {
                urlHostSlugLabel.text = " "
            }
        default: break
        }
        
        subtitle.text = transaction.createdAt?.formattedDateWithStyle(.MediumStyle)
        
        if let amount = amountInCents {
            upvoteCountLabel.text = (amount / 100).format(Currency.USD)
        } else {
            upvoteCountLabel.text = " "
        }

        mainImageView.setTemplateColor(UIColor.darkGrayShoebox()) //has to be after setting image
    }
}