//
//  ButtonImageView.swift
//  Linkings
//
//  Created by Max Child on 1/16/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class ButtonImageView: UIView {
    
    var action: BlankBlock?
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonTitle: UILabel?
    
    @IBAction func buttonPressed(sender: UIButton) {
        action?()
    }
    
    @IBInspectable var buttonEnabled: Bool = true { //i.e. "highlightable"
        didSet {
            button.enabled = buttonEnabled
        }
    }
    @IBInspectable var selected: Bool = false {
        didSet {
            updateDisplayingColors()
        }
    }
    
    @IBInspectable var selectedColor: UIColor? {
        didSet {
            updateDisplayingColors()
        }
    }
    @IBInspectable var deselectedColor: UIColor? {
        didSet {
            updateDisplayingColors()
        }
    }
    
    
    //MARK - Methods
    func setupWithTitle(title: String,
        action: BlankBlock,
        image: UIImage?,
        selected: Bool,
        selectedColor: UIColor = UIColor.green1976(),
        deselectedColor: UIColor = UIColor.lightGrayShoebox()) {
        
            buttonTitle?.text = title
            self.action = action
            self.imageView.image = image
            self.selected = selected
            self.selectedColor = selectedColor
            self.deselectedColor = deselectedColor
    }
    
    private func updateDisplayingColors() {
        let displayColor = selected ? selectedColor : deselectedColor
        imageView.setTemplateColor(displayColor)
        buttonTitle?.textColor = displayColor
    }
}

//protocol ButtonView {
//    var action: BlankBlock? { get set }
//    var button: UIButton { get }
//}
//
//protocol TitledView {
//    var titleLabel: UILabel { get }
//}
//
//protocol ImagedView {
//    var imageView: UIImageView { get }
//}