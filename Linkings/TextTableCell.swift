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