//
//  ComposeTVC.swift
//  Linkings
//
//  Created by Max Child on 1/13/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation

class ComposeTVC: UITableViewController, UITextFieldDelegate, TextViewCellDelegate {
    
    var contestForEntry: PFContest?
    
    enum PostInfoType: String {
        case URL
        case Title
        case Subtitle
    }
    
    enum RowType {
        case Header(title: String?)
        case TextField(postInfoType: PostInfoType)
        case TextView(postInfoType: PostInfoType)
        case Button
        
        static func typeForIndexPath(indexPath: NSIndexPath, layout: [[RowType]]) -> RowType? {
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
    
    let layout = [[RowType.Header(title: "Link")],
        [RowType.TextField(postInfoType: .URL)],
        [RowType.Header(title: "Info")],
        [RowType.TextField(postInfoType: .Title), RowType.TextView(postInfoType: .Subtitle)],
        [RowType.Header(title: nil)],
        [.Button]]
    
    var newPostInfo = [PostInfoType: String]()
    //ask whether to cancel
    var postInProgress: Bool {
        return !newPostInfo.isEmpty
    }
    
    //MARK: - Basics
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Entry"
        
        tableView.estimatedRowHeight = 66
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        setupNavButtons()
    }
    
    func setupNavButtons() {
//        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "donePressed")
//        navigationItem.rightBarButtonItem = doneButton
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let firstCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
            becomeFirstResponderInTextCell(firstCell)
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
        guard let rowType = RowType.typeForIndexPath(indexPath, layout: layout) else {
            return cell
        }
        
        switch rowType {
        case .Header(title: let title):
            let headerCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.sectionHeaderTextCellCompose)!
            headerCell.title.text = title?.uppercaseString
            headerCell.selectionStyle = .None
            cell = headerCell
        case .TextField(postInfoType: let postInfoType):
            let textFieldCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.textFieldCell)!
            configureTextFieldCell(textFieldCell, forPostInfoType: postInfoType, atIndexPath: indexPath)
            cell = textFieldCell
        case .TextView(postInfoType: let postInfoType):
            let textViewCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.multilineTextCell)!
            configureTextViewCell(textViewCell, forPostInfoType: postInfoType, atIndexPath: indexPath)
            cell = textViewCell
        case .Button:
            let finishCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.finishTextCellSimple)!
            configureFinishCell(finishCell, forRowAtIndexPath: indexPath)
            cell = finishCell
        }
    
        cell.configureStandardSeparatorInTableView(tableView, atIndexPath: indexPath)
        return cell
    }
    
    //MARK: - Configure
    func configureTextFieldCell(cell: TextFieldTableCell, forPostInfoType postInfoType: PostInfoType, atIndexPath indexPath: NSIndexPath) {
        cell.textField.delegate = self
        cell.textField.indexPath = indexPath
        cell.textField.returnKeyType = UIReturnKeyType.Next
        
        var placeholderAttributes = cell.textField.attributedPlaceholder?.attributesAtIndex(0, effectiveRange: nil)
        placeholderAttributes?[NSForegroundColorAttributeName] = UIColor.veryLightGrayShoebox()
        
        
        switch postInfoType {
        case .URL:
            cell.textField.text = newPostInfo[.URL]
            cell.textField.attributedPlaceholder = NSAttributedString(string: "link.to.share.com", attributes: placeholderAttributes)
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
    func configureTextViewCell(cell: MultilineTextInputTableCell, forPostInfoType postInfoType: PostInfoType, atIndexPath indexPath: NSIndexPath) {
        
        cell.delegate = self
        if let subtitle = newPostInfo[.Subtitle] where subtitle.characters.count > 0 && cell.trueText == nil {
            cell.trueText = subtitle
        }
        cell.placeholder = "Add some context..."
        cell.setupText()
    }
    
    func configureFinishCell(finishCell: TextTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        finishCell.title.text = "POST"
        finishCell.title.textColor = UIColor.green1976()
        finishCell.selectionStyle = .Default
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let rowType = RowType.typeForIndexPath(indexPath, layout: layout) else {
            return
        }
        switch rowType {
        case .TextField(postInfoType: _), .TextView(postInfoType: _):
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                becomeFirstResponderInTextCell(cell)
            }
        case .Button:
            donePressed()
        default: break
        }
        
    }
    
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let indexedTF = textField as? IndexedTextField,
            let ip = indexedTF.indexPath,
            let cell = tableView.cellForRowAtIndexPath(ip),
            let nextTextCell = nextTextCell(cell)  {
                
                becomeFirstResponderInTextCell(nextTextCell)
        }
        return true
    }
    
    func nextTextCell(cell: UITableViewCell) -> UITableViewCell? {
        guard let nextCell = tableView.nextCell(cell) else {
            return nil
        }
        guard nextCell is TextFieldTableCell || nextCell is MultilineTextInputTableCell else {
            return nextTextCell(nextCell)
        }
        return nextCell
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        saveTextFromTextField(textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        saveTextFromTextField(textField)
        return true
    }
    
    func saveTextFromTextField(textField: UITextField) {
        
        if let indexedTF = textField as? IndexedTextField,
            let ip = indexedTF.indexPath,
            let rowType = RowType.typeForIndexPath(ip, layout: layout) {
                switch rowType {
                case .TextField(postInfoType: let postInfoType):
                    if textField.text != newPostInfo[postInfoType] {
                        newPostInfo[postInfoType] = textField.text
                    }
                default: break
                }
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
        
        if postInProgress {
            let areYouSure = UIAlertController(title: "Delete post?", message: "You're working on a masterpiece. Do you want to delete it?", preferredStyle: UIAlertControllerStyle.Alert)
            areYouSure.addAction(UIAlertAction(title: "Keep editing", style: UIAlertActionStyle.Default, handler:nil))
            areYouSure.addAction(UIAlertAction(title: "Delete it", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                self.view.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(areYouSure, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func donePressed() {
        guard let contest = contestForEntry, let urlString = newPostInfo[.URL], let title = newPostInfo[.Title] else {
            log.error("Missing new post info \(newPostInfo) in contest \(contestForEntry)")
            MRProgressOverlayView.showErrorWithStatus("Missing post info")
            return
        }
        
        view.endEditing(true)
        MRProgressOverlayView.showOverlayAddedTo(MRProgressOverlayView.sharedView(), title: "Posting...", mode: .Indeterminate, animated: true)
        
        PFActivity.newEntryForContest(contest, urlString: urlString, title: title, subtitle: newPostInfo[.Subtitle]) { (entry, error) -> Void in
            MRProgressOverlayView.dismissAllOverlaysForView(MRProgressOverlayView.sharedView(), animated: true)
            if let newEntry = entry where error == nil {
                if let newEntryPost = newEntry.post {
                    newEntryPost.upvotePressed({ (success, upvoteError) -> Void in
                        self.postSuccess()
                        if let voteError = upvoteError {
                            log.error("Error upvoting new post \(voteError)")
                        }
                    })
                } else {
                    self.postSuccess()
                }
            } else {
                MRProgressOverlayView.showErrorWithStatus("Error posting, maybe try again", inView: MRProgressOverlayView.sharedView(), afterDelay: 0.4)
            }
        }
    }
    
    func postSuccess() {
        MRProgressOverlayView.showSuccessWithStatus("Posted new hotness!", inView: MRProgressOverlayView.sharedView(), afterDelay: 0.4)
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NSNotification.FetchDataChanged, object: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
