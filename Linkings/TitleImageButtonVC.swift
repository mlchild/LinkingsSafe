//
//  TitleImageButtonVC.swift
//  Linkings
//
//  Created by Max Child on 1/12/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation


class TitleImageButtonVC : UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    
    override func viewDidLoad() {
        mainImage.setTemplateColor(UIColor.green1976())
    }
    
    //MARK: - Presses
    @IBAction func topButtonPressed(sender: AnyObject) {
    }
    @IBAction func bottomButtonPressed(sender: AnyObject) {
    }
}