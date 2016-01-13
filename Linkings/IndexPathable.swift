//
//  IndexPathable.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

protocol IndexPathable {
    var indexPath: NSIndexPath? { get set }
}

class IndexedTextField: UITextField, IndexPathable {
    var indexPath: NSIndexPath?
}

class IndexedButton: UIButton, IndexPathable {
    var indexPath: NSIndexPath?
}