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
}

