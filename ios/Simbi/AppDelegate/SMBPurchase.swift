//
//  SMBPurchase.swift
//  Simbi
//
//  Created by flynn on 11/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//


enum SMBPurchaseType: String {
    case Credits50  = "com.simbisocial.simbi.50credits"
    case Credits100 = "com.simbisocial.simbi.100credits"
    case Credits200 = "com.simbisocial.simbi.200credits"
}

class SMBPurchase: PFPurchase {
    
    // MARK: - Register Purchases
    
    class func registerPurchases() {
        
        SMBPurchase.register50CreditPurchase()
        SMBPurchase.register100CreditPurchase()
        SMBPurchase.register200CreditPurchase()
    }
    
    
    class func register50CreditPurchase() {
        
        SMBPurchase.addObserverForProduct(SMBPurchaseType.Credits50.rawValue, block: { (transaction: SKPaymentTransaction!) -> Void in
            
            if (transaction != nil) {
                SMBPurchase.purchaseCredits(50, transaction: transaction)
            }
        })
    }
    
    
    class func register100CreditPurchase() {
        
        SMBPurchase.addObserverForProduct(SMBPurchaseType.Credits100.rawValue, block: { (transaction: SKPaymentTransaction!) -> Void in
            
            if (transaction != nil) {
                SMBPurchase.purchaseCredits(100, transaction: transaction)
            }
        })
    }
    
    
    class func register200CreditPurchase() {
        
        SMBPurchase.addObserverForProduct(SMBPurchaseType.Credits200.rawValue, block: { (transaction: SKPaymentTransaction!) -> Void in
            
            if (transaction != nil) {
                SMBPurchase.purchaseCredits(200, transaction: transaction)
            }
        })
    }
    
    
    // MARK: - Carry out purchase
    
    class func purchaseCredits(amount: Int, transaction: SKPaymentTransaction) {
        
        let receipt = SMBReceipt(className:SMBReceipt.parseClassName())
        receipt.user = SMBUser.currentUser()
        receipt.identifier = transaction.transactionIdentifier
        
        if let url = NSBundle.mainBundle().appStoreReceiptURL {
            
            let receiptData = NSData(contentsOfURL: url)
            let receiptFile = PFFile(data: receiptData!)
            receipt.data = receiptFile
        }
        else {
            println("\(__FUNCTION__) - No App Store receipt!")
        }
        
        receipt.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            
            if succeeded {
                
                let params: [String: AnyObject] = ["amount"      : amount,
                                                   "receiptId"   : receipt.objectId!,
                                                   "information" : "Apple IAP \(amount) Credits"]
                
                PFCloud.callFunctionInBackground("purchaseCredits", withParameters: params, block: { (response, error) -> Void in
                    
                    if response != nil {
                        SMBUser.currentUser().fetch()
                        SMBUser.currentUser().credits.fetch()
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("purchaseSucceeded", object: nil)
                    }
                    else {
                        NSNotificationCenter.defaultCenter().postNotificationName("purchaseFailed", object: nil)
                    }
                })
            }
            else {
                NSNotificationCenter.defaultCenter().postNotificationName("purchaseFailed", object: nil)
            }
        }
    }
}

