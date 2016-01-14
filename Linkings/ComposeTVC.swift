//
//  ComposeTVC.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class ComposeTVC: UITableViewController, UITextFieldDelegate, TextViewCellDelegate {
    
    enum PostInfoType: String {
        case URL
        case Title
        case Subtitle
        
        static func typeForIndexPath(indexPath: NSIndexPath, layout: [[PostInfoType]]) -> PostInfoType? {
            guard indexPath.section < layout.count else {
                return nil
            }
            let sectionLayout = layout[indexPath.section]
            guard indexPath.row < sectionLayout.count else {
                return nil
            }
            return sectionLayout[indexPath.row]
        }
    }
    
    let layout = [[PostInfoType.URL], [PostInfoType.Title, PostInfoType.Subtitle]]
    
    var newPostInfo = [PostInfoType: String]()
    //ask whether to cancel
    var postInProgress: Bool {
        return !newPostInfo.isEmpty
    }
    
    //MARK: - Basics
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"
        
        tableView.estimatedRowHeight = 66
        tableView.rowHeight = UITableViewAutomaticDimension
        
        setupNavButtons()
    }
    
    func setupNavButtons() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "donePressed")
        navigationItem.rightBarButtonItem = doneButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelPressed")
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func updateNavButtons() {
        if newPostInfo[.URL] != nil && newPostInfo[.Title] != nil {
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return layout.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < layout.count else {
            return 0
        }
        return layout[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        guard let rowInfoType = PostInfoType.typeForIndexPath(indexPath, layout: layout) else {
            return cell
        }
        
        switch rowInfoType {
        case .URL:
            let textFieldCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.textFieldCell)!
            configureTextFieldCell(textFieldCell, forRowAtIndexPath: indexPath)
            cell = textFieldCell
        case .Title:
            let textFieldCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.textFieldCell)!
            configureTextFieldCell(textFieldCell, forRowAtIndexPath: indexPath)
            cell = textFieldCell
        case .Subtitle:
            let textViewCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.multilineTextCell)!
            configureTextViewCell(textViewCell, forRowAtIndexPath: indexPath)
            cell = textViewCell
        }
    
        return cell
    }
    
    //MARK: - Configure
    func configureTextFieldCell(cell: TextFieldTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textField.delegate = self
        cell.textField.indexPath = indexPath
        cell.textField.returnKeyType = UIReturnKeyType.Next
        
        var placeholderAttributes = cell.textField.attributedPlaceholder?.attributesAtIndex(0, effectiveRange: nil)
        placeholderAttributes?[NSForegroundColorAttributeName] = UIColor.veryLightGrayShoebox()
        
        guard let rowInfoType = PostInfoType.typeForIndexPath(indexPath, layout: layout) else {
            return
        }
        
        switch rowInfoType {
        case .URL:
            cell.textField.text = newPostInfo[.URL]
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Link to share", attributes: placeholderAttributes)
            cell.textField.keyboardType = UIKeyboardType.URL
            cell.textField.autocorrectionType = .No
            cell.textField.autocapitalizationType = .None
        case .Title:
            cell.textField.text = newPostInfo[.Title]
            cell.textField.attributedPlaceholder = NSAttributedString(string: "Post title", attributes: placeholderAttributes)
            cell.textField.keyboardType = UIKeyboardType.Default
            cell.textField.autocorrectionType = .Default
            cell.textField.autocapitalizationType = .Words
        default: break
        }


    }
    func configureTextViewCell(cell: MultilineTextInputTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.delegate = self
        if let subtitle = newPostInfo[.Subtitle] where subtitle.characters.count > 0 && cell.trueText == nil {
            cell.trueText = subtitle
        }
        cell.placeholder = "Add some context..."
        cell.setupText()
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            becomeFirstResponderInTextCell(cell)
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let indexedTF = textField as? IndexedTextField,
            let ip = indexedTF.indexPath where self.tableView(tableView, numberOfRowsInSection: ip.section) > ip.row + 1,
            let nextCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: ip.row + 1, inSection: ip.section)) {
                
                becomeFirstResponderInTextCell(nextCell)
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let indexedTF = textField as? IndexedTextField,
            let ip = indexedTF.indexPath,
            let infoType = PostInfoType.typeForIndexPath(ip, layout: layout) where textField.text != newPostInfo[infoType] {
                newPostInfo[infoType] = textField.text
        }
    }
    
    func becomeFirstResponderInTextCell(textCell: UITableViewCell) {
        if let fieldCell = textCell as? TextFieldTableCell {
            fieldCell.textField.becomeFirstResponder()
        } else if let textViewCell = textCell as? MultilineTextInputTableCell {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { //necessary to prevent extra return
                textViewCell.textView.becomeFirstResponder()
            }
        }
    }
    
    func textViewCellUpdated(text: String) {
        if text != newPostInfo[.Subtitle] {
            newPostInfo[.Subtitle] = text
        }
    }
    
    //MARK: - Presses
    func cancelPressed() {
        view.endEditing(true)
        
        if postInProgress {
            let areYouSure = UIAlertController(title: "Delete post?", message: "You're working on a masterpiece. Do you want to delete it?", preferredStyle: UIAlertControllerStyle.Alert)
            areYouSure.addAction(UIAlertAction(title: "Keep editing", style: UIAlertActionStyle.Default, handler:nil))
            areYouSure.addAction(UIAlertAction(title: "Delete it", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(areYouSure, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func donePressed() {
        guard let urlString = newPostInfo[.URL], let title = newPostInfo[.Title] else {
            log.error("Missing new post info \(newPostInfo)")
            MRProgressOverlayView.showErrorWithStatus("Missing post info")
            return
        }
        
        view.endEditing(true)
        PFActivity.newEntryInCurrentContest(urlString, title: title, subtitle: newPostInfo[.Subtitle]) { (success, error) -> Void in
            if success && error == nil {
                MRProgressOverlayView.showSuccessWithStatus("Posted new hotness!")
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.NSNotification.FetchDataChanged, object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                MRProgressOverlayView.showErrorWithStatus("Error posting, maybe try again")
            }
        }
    }
}
