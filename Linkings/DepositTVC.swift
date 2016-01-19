//
//  DepositTVC.swift
//  Linkings
//
//  Created by Max Child on 1/14/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation
import Stripe

class DepositTVC: UITableViewController, PKPaymentAuthorizationViewControllerDelegate, UITextFieldDelegate {
    
    var depositInProgress: Double?
    var customDepositAmount: Double?
    
    enum RowType {
        case Header(title: String?)
        case DepositAmount(Double)
        case OtherDepositAmount
        case PaymentMethod
        case Finish
        
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
    let layout: [[RowType]] = [[.Header(title: "Deposit Amount".uppercaseString)], [.DepositAmount(5), .DepositAmount(10), .OtherDepositAmount], [.Header(title: nil)], [.Finish]]
    
    //MARK: - Basics
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Deposit"
        
        tableView.estimatedRowHeight = 66
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        setupNavButtons()
    }
    
    func setupNavButtons() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelPressed")
        navigationItem.leftBarButtonItem = cancelButton
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
        guard let rowInfoType = RowType.typeForIndexPath(indexPath, layout: layout) else {
            return cell
        }
        
        switch rowInfoType {
        case .Header(let title):
            let headerCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.sectionHeaderTextCellDeposit)!
            configureHeaderCell(headerCell, title: title)
            cell = headerCell
        case .DepositAmount:
            let amountCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.depositTextCellSimple)!
            configureDepositAmountCell(amountCell, forRowAtIndexPath: indexPath)
            cell = amountCell
        case .OtherDepositAmount:
            let otherTextFieldCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.textFieldCellDeposit)!
            configureOtherAmountCell(otherTextFieldCell, forRowAtIndexPath: indexPath)
            cell = otherTextFieldCell
        case .PaymentMethod:
            return cell
        case .Finish:
            let finishCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.depositButtonCell)!
            configureFinishCell(finishCell, forRowAtIndexPath: indexPath)
            cell = finishCell
        }
        
        cell.configureStandardSeparatorInTableView(tableView, atIndexPath: indexPath)
        return cell
    }
    
    func configureHeaderCell(headerCell: TextTableCell, title: String?) {
        headerCell.title.text = title
        headerCell.selectionStyle = .None
    }
    
    func configureDepositAmountCell(amountCell: TextTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.green1976()
        amountCell.selectedBackgroundView = selectedView
        
        amountCell.title.highlightedTextColor =  UIColor.whiteShoebox()
        
        guard let rowType = RowType.typeForIndexPath(indexPath, layout: layout) else {
            log.error("no row type for deposit amount cell")
            return
        }
        switch rowType {
        case .DepositAmount(let amount):
            amountCell.title.text = amount.format(Currency.USD).removeDecimal()
        default:
            log.error("wrong row type for amount cell \(rowType) at ip \(indexPath)")
        }
    }
    
    func configureOtherAmountCell(textFieldCell: TextFieldTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        textFieldCell.textField.delegate = self
        textFieldCell.textField.indexPath = indexPath
        textFieldCell.textField.returnKeyType = UIReturnKeyType.Done
        
        var placeholderAttributes = textFieldCell.textField.attributedPlaceholder?.attributesAtIndex(0, effectiveRange: nil)
        placeholderAttributes?[NSForegroundColorAttributeName] = UIColor.veryLightGrayShoebox()
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.green1976()
        textFieldCell.selectedBackgroundView = selectedView
        
        textFieldCell.textField.textColor = textFieldCell.selected ? UIColor.lightGrayShoebox() : UIColor.darkGrayShoebox()
        
        textFieldCell.textField.text = customDepositAmount != nil ? "$\(Int(customDepositAmount!))" : nil
        textFieldCell.textField.attributedPlaceholder = NSAttributedString(string: "Other Amount", attributes: placeholderAttributes)
        textFieldCell.textField.keyboardType = UIKeyboardType.NumberPad
    }
    
    func configureFinishCell(finishCell: TextTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        finishCell.title.text = "DEPOSIT"
        finishCell.title.textColor = UIColor.green1976()
        finishCell.selectionStyle = .Default
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let rowType = RowType.typeForIndexPath(indexPath, layout: layout) else {
            return
        }
        
        switch rowType {
        case .DepositAmount(let amount):
            depositInProgress = amount
            view.endEditing(true)
        case .OtherDepositAmount:
            if let textFieldCell = tableView.cellForRowAtIndexPath(indexPath) as? TextFieldTableCell {
                textFieldCell.textField.becomeFirstResponder()
            }
        default:
            view.endEditing(true)
        }
    }
    

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        tableView.indexPathsForSelectedRows?.forEach({ tableView.deselectRowAtIndexPath($0, animated: true) }) //make sure to deselect text field cell
        return indexPath
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let rowType = RowType.typeForIndexPath(indexPath, layout: layout) else {
            return 0
        }
        
        switch rowType {
        case .OtherDepositAmount: return 100
        default: return UITableViewAutomaticDimension
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        guard let indexedTF = textField as? IndexedTextField,
            let ip = indexedTF.indexPath,
            let textFieldCell = tableView.cellForRowAtIndexPath(ip) else  {
                log.error("No cell for selected textField \(textField)")
                return
        }
        textFieldCell.selected = true
        tableView.indexPathsForSelectedRows?.forEach({ tableView.deselectRowAtIndexPath($0, animated: true) }) //make sure to deselect text field cell
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        depositPressed(textField)
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        saveTextFromTextField(textField.text, showError: true)
       
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            if let indexedTF = textField as? IndexedTextField,
                let ip = indexedTF.indexPath,
                let _ = self.tableView.cellForRowAtIndexPath(ip) as? TextFieldTableCell {
                    self.tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: .None)
            }
        })

    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let newText = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            saveTextFromTextField(newText, showError: false)
        }
        return true
    }
    
    func saveTextFromTextField(text: String?, showError: Bool) {
        guard let depositText = text where depositText.characters.count > 0 else {
            return
        }
        
        guard let strippedText = depositText.componentsSeparatedByString("$").last, let depositAmount = Double(strippedText) else {
            log.error("Textfield text invalid \(depositText)")
            if showError {
                MRProgressOverlayView.showErrorWithStatus("Invalid deposit amount")
            }
            return
        }
        
//        guard let indexedTF = textField as? IndexedTextField,
//            let ip = indexedTF.indexPath,
//            let textFieldCell = tableView.cellForRowAtIndexPath(ip) else  {
//                log.error("No cell for saved textField \(textField)")
//        }
        
        customDepositAmount = depositAmount
        depositInProgress = customDepositAmount
    }
    
    //MARK: - PKPaymentAuth Delegate
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        log.debug("payment authorized \(payment)")
        guard let depositAmount = depositInProgress else {
            MRProgressOverlayView.showErrorWithStatus("No deposit selected")
            return
        }
        /*
        We'll implement this method below in 'Creating a single-use token'.
        Note that we've also been given a block that takes a
        PKPaymentAuthorizationStatus. We'll call this function with either
        PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
        after all of our asynchronous code is finished executing. This is how the
        PKPaymentAuthorizationViewController knows when and how to update its UI.
        */
        PaymentManager.handlePaymentAuthorizationWithPayment(payment, amount: depositAmount) { (authStatus) -> () in
            self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
            switch authStatus {
            case .Success:
                MRProgressOverlayView.showSuccessWithStatus("Made deposit!")
                self.dismissViewControllerAnimated(true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.NSNotification.FetchDataChanged, object: self)
            default:
                log.error("deposit error: \(authStatus)")
                MRProgressOverlayView.showErrorWithStatus("Error making deposit")
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        log.debug("payment controller finished")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Presses
    @IBAction func depositPressed(sender: AnyObject) {
        guard let depositAmount = depositInProgress else {
            MRProgressOverlayView.showErrorWithStatus("No deposit selected")
            return
        }
        
        PaymentManager.requestApplePayForItem(PaidItem(title: "Linkings Deposit", cost: depositAmount), presenter: self)
    }
    
    func cancelPressed() {
        view.endEditing(true)
        
        if let _ = depositInProgress {
            let areYouSure = UIAlertController(title: "Cancel deposit?", message: "You miss 100% of the shots you don't take.", preferredStyle: UIAlertControllerStyle.Alert)
            areYouSure.addAction(UIAlertAction(title: "Deposit", style: UIAlertActionStyle.Default, handler:nil))
            areYouSure.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            presentViewController(areYouSure, animated: true, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}