//
//  PaymentManager.swift
//  Linkings
//
//  Created by Max Child on 1/14/16.
//  Copyright © 2016 Volley Inc. All rights reserved.
//

import Foundation
import Stripe

struct PaidItem {
    let title: String
    let cost: Double
}

//protocol PaymentAbleVC: PKPaymentAuthorizationViewControllerDelegate, Presenter {
//    func requestApplePayForItem(paidItem: PaidItem)
//    func handlePaymentAuthorizationWithPayment(payment: PKPayment, completion: PKPaymentAuthorizationStatus -> ())
//    func createBackendChargeWithToken(token: STPToken, completion: PKPaymentAuthorizationStatus -> ())
//}
//
//protocol Presenter {
//    func presentViewController(viewControllerToPresent: UIViewController,
//        animated flag: Bool,
//        completion: (() -> Void)?)
//}

class PaymentManager {
    
    class func requestApplePayForItem(paidItem: PaidItem, presenter: UIViewController) {
        
        log.debug("requesting apple pay")

        guard let authController = presenter as? PKPaymentAuthorizationViewControllerDelegate else {
            log.error("Apple Pay presenter is not a PKAuthDelegate")
            return
        }
        
        guard let request = Stripe.paymentRequestWithMerchantIdentifier("merchant.com.volleythat.linkings") else {
            log.error("Apple Pay payment request failed")
            return
        }
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: paidItem.title, amount: NSDecimalNumber(double: paidItem.cost))
        ]
        
        if (Stripe.canSubmitPaymentRequest(request)) {
            log.debug("can submit apple pay request, showing vc")
            let paymentController = PKPaymentAuthorizationViewController(paymentRequest: request)
            paymentController.delegate = authController
            presenter.presentViewController(paymentController, animated: true, completion: nil)
        } else {
            //TODO: Show the user your own credit card form (see options 2 or 3)
            log.debug("can't submit apple pay request, need plan b")
        }
    }
    
    class func handlePaymentAuthorizationWithPayment(payment: PKPayment, amount: Double, completion: PKPaymentAuthorizationStatus -> ()) {
        log.debug("handling payment auth")
        STPAPIClient.sharedClient().createTokenWithPayment(payment) { (token, error) -> Void in
            log.debug("token \(token), error: \(error)")
            if error != nil {
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            /*
            We'll implement this below in "Sending the token to your server".
            Notice that we're passing the completion block through.
            See the above comment in didAuthorizePayment to learn why.
            */
            
            guard let chargeToken = token else {
                log.error("No token for payment \(payment)")
                completion(.Failure)
                return
            }
            
            self.createBackendChargeWithToken(chargeToken, amount: amount, completion: completion)
        }
    }
    
    class func createBackendChargeWithToken(token: STPToken, amount: Double, completion: PKPaymentAuthorizationStatus -> ()) {
        var params = [String : AnyObject]()
        params["token"] = token.tokenId
        params["amount"] = amount
        
        PFCloud.callFunctionInBackground("makeDeposit", withParameters: params) { (object, error) -> Void in
            if error != nil {
                log.error("error on backend charge \(error)")
                completion(.Failure)
            } else {
                log.error("made deposit, params \(params)")
                completion(.Success)
            }
        }
    }
}