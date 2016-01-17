//
//  ImageTableCell.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class ImageTableCell: DetailTextTableCell {
    @IBOutlet weak var mainImageView: UIImageView!
//    var parseMainImageView: PFImageView? {
//        return imageLargeView as? PFImageView
//    }
}

class PostTableCell: ImageTableCell {
    @IBOutlet weak var upvoteCountLabel: UILabel!
    @IBOutlet weak var upvoteButton: IndexedButton!
    @IBOutlet weak var urlHostSlugLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    
    func configureWithPost(post: PFPost) {
        
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
        
        var prizeText = ""
        if let prize = post.postPrize where prize > 0 {
            var prizeCurrencyString = prize.format(Currency.USD)
            if prize >= 10 { prizeCurrencyString = prizeCurrencyString.removeDecimal() }
            prizeText = " (💰\(prizeCurrencyString))"
        }
        //        postCell.prizeLabel.text = prizeText
        
        urlHostSlugLabel.text = (hostName ?? "") + (posterName != nil ? " via \(posterName!)\(prizeText)" : "")
    }
}

