//
//  TextTableCell.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class TextTableCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
}

class DetailTextTableCell: TextTableCell {
    @IBOutlet weak var subtitle: UILabel!
}

class ContestTitleCell: TextTableCell {
    @IBOutlet weak var countdownLabel: MZTimerLabel!
    @IBOutlet weak var countdownCaption: UILabel!
    @IBOutlet weak var entryCountLabel: UILabel!
    @IBOutlet weak var entryCountCaption: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    @IBOutlet weak var prizeCaption: UILabel!
}