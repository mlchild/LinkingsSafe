//
//  MultilineTextInputTableCell.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

protocol TextViewCellDelegate {
    func textViewCellUpdated(text: String)
}

class MultilineTextInputTableCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet var textView: UITextView!

    var delegate: TextViewCellDelegate?
    var placeholder = ""
    var trueText: String? {
        didSet {
            if let newText = trueText {
                delegate?.textViewCellUpdated(newText)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func setupText() {
        if let text = trueText where text.characters.count > 0 {
            textString = text
            textView.textColor = UIColor.darkGrayShoebox()
        } else {
            if textView.isFirstResponder() {
                textString = ""
                textView.textColor = UIColor.darkGrayShoebox()
            } else {
                textString = placeholder
                textView.textColor = UIColor.veryLightGrayShoebox()
            }
        }
    }
    
    /// Custom setter so we can initialise the height of the text view
    var textString: String {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            
            textViewDidChange(textView)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Disable scrolling inside the text view so we enlarge to fitted size
        textView.scrollEnabled = false
        textView.delegate = self
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textView.becomeFirstResponder()
        } else {
            textView.resignFirstResponder()
        }
    }
    
    //MARK: - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        setupText()
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        setupText()
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if textView.isFirstResponder() {
            trueText = textString
        }
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
        
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableSuperview?.beginUpdates()
            tableSuperview?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            if let thisIndexPath = tableSuperview?.indexPathForCell(self) {
                tableSuperview?.scrollToRowAtIndexPath(thisIndexPath, atScrollPosition: .Bottom, animated: false)
            }
        }
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        if newText.characters.count > 160 {
            MRProgressOverlayView.showErrorWithStatus("Too long")
            return false
        }
        return true
    }
}