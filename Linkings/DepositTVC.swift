//
//  DepositTVC.swift
//  Linkings
//
//  Created by Max Child on 1/14/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation
import Stripe

class DepositTVC: UITableViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    var depositInProgress: Double?
    
    enum RowType {
        case DepositAmount(Double)
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
    let layout: [[RowType]] = [[.DepositAmount(5), .DepositAmount(10)], [.Finish]]
    
    //MARK: - Basics
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Deposit"
        
        tableView.estimatedRowHeight = 66
        tableView.rowHeight = UITableViewAutomaticDimension
        
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
        case .DepositAmount:
            let amountCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.depositTextCellSimple)!
            configureDepositAmountCell(amountCell, forRowAtIndexPath: indexPath)
            cell = amountCell
        case .PaymentMethod:
            return cell
        case .Finish:
            let finishCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.depositTextCellSimple)!
            configureFinishCell(finishCell, forRowAtIndexPath: indexPath)
            cell = finishCell
        }
        
        return cell
    }
    
    func configureDepositAmountCell(amountCell: TextTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        amountCell.selectionStyle = .Default
        guard let rowType = RowType.typeForIndexPath(indexPath, layout: layout) else {
            log.error("no row type for deposit amount cell")
            return
        }
        switch rowType {
        case .DepositAmount(let amount):
            let amountString = amount.format(Currency.USD)
            amountCell.title.text = amountString.componentsSeparatedByString(".").first //no decimal
        default:
            log.error("wrong row type for amount cell \(rowType) at ip \(indexPath)")
        }
    }
    
    func configureFinishCell(finishCell: TextTableCell, forRowAtIndexPath indexPath: NSIndexPath) {
        finishCell.title.text = "DEPOSIT"
        finishCell.selectionStyle = .None
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let rowType = RowType.typeForIndexPath(indexPath, layout: layout) else {
            return
        }
        
        switch rowType {
        case .DepositAmount(let amount):
            depositInProgress = amount
        case .PaymentMethod:
            break
        case .Finish:
            guard let depositAmount = depositInProgress else {
                MRProgressOverlayView.showErrorWithStatus("No deposit selected")
                return
            }
            
            PaymentManager.requestApplePayForItem(PaidItem(title: "Linkings Deposit", cost: depositAmount), presenter: self)
        }
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