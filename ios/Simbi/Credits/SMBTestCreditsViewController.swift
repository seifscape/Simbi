//
//  SMBTestCreditsViewController.swift
//  Simbi
//
//  Created by flynn on 11/14/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBTestCreditsViewController: UITableViewController {
    
    // MARK: - ViewController Lifecycle
    
    override convenience init() {
        self.init(style: .Grouped)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Credits Test"
    }
    
    
    // MARK: - User Actions
    
    func purchaseCreditsAction(amount: Int) {
        
        let hud = MBProgressHUD.HUDwithMessage("Purchasing...", parent: self)
        
        let receipt = SMBReceipt()
        
        let data = NSData(bytes: "DEBUG DATA", length: 10)
        let dataFile = PFFile(data: data)
        
        receipt.user = SMBUser.currentUser()
        receipt.data = dataFile
        
        receipt.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            
            if succeeded {
                
                let params: [String: AnyObject] = ["amount": amount, "receiptId": receipt.objectId, "information": "Debug Purchase"]
            
                PFCloud.callFunctionInBackground("purchaseCredits", withParameters: params, block: { (response: AnyObject!, error: NSError!) -> Void in
                    
                    if response != nil {
                        
                        SMBUser.currentUser().fetchInBackgroundWithBlock({ (object: PFObject!, error: NSError!) -> Void in
                            SMBUser.currentUser().credits.fetchInBackgroundWithBlock({ (object: PFObject!, error: NSError!) -> Void in
                                hud.dismissWithSuccess()
                                self.tableView.reloadData()
                            })
                        })
                    }
                    else {
                        hud.dismissWithError()
                    }
                })
            }
            else {
                hud.dismissWithError()
            }
        }
    }
    
    
    func spendCreditsAction(amount: Int) {
        
        let hud = MBProgressHUD.HUDwithMessage("Spending...", parent: self)
        
        let params: [String: AnyObject] = ["amount": amount, "information": "Debug Spend"]
        
        PFCloud.callFunctionInBackground("spendCredits", withParameters: params) { (response: AnyObject!, error: NSError!) -> Void in
            
            if response != nil {
                
                SMBUser.currentUser().fetchInBackgroundWithBlock({ (object: PFObject!, error: NSError!) -> Void in
                    SMBUser.currentUser().credits.fetchInBackgroundWithBlock({ (object: PFObject!, error: NSError!) -> Void in
                        hud.dismissWithSuccess()
                        self.tableView.reloadData()
                    })
                })
            }
            else {
                if error.userInfo != nil && error.userInfo!["error"] as String == "CANNOT_AFFORD" {
                    hud.dismissWithMessage("Not enough credits!")
                }
                else {
                    hud.dismissWithError()
                }
            }
        }
    }
    
    
    // MARK: - UITableViewDataSource/Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1, 2:
            return 3
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            
            cell.selectionStyle = .None
            
            if SMBUser.currentUser().credits != nil {
                
                SMBUser.currentUser().credits.fetchIfNeededInBackgroundWithBlock({ (object: PFObject!, error: NSError!) -> Void in
                    
                    if object != nil {
                        cell.textLabel?.text = "Balance: \(SMBUser.currentUser().credits.balance)"
                    }
                    else {
                        cell.textLabel?.text = "ERROR"
                    }
                })
            }
            else {
                cell.textLabel?.text = "Balance: 0"
            }
            
        case (1, 0):
            cell.textLabel?.text = "Purchase 50 Credits (Not IAP)"
        case (1, 1):
            cell.textLabel?.text = "Purchase 100 Credits (Not IAP)"
        case (1, 2):
            cell.textLabel?.text = "Purchase 200 Credits (Not IAP)"
            
        case (2, 0):
            cell.textLabel?.text = "Spend 50 Credits"
        case (2, 1):
            cell.textLabel?.text = "Spend 100 Credits"
        case (2, 2):
            cell.textLabel?.text = "Spend 200 Credits"
            
        default:
            break
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
            
        case (1, 0):
            purchaseCreditsAction(50)
        case (1, 1):
            purchaseCreditsAction(100)
        case (1, 2):
            purchaseCreditsAction(200)
            
        case (2, 0):
            spendCreditsAction(50)
        case (2, 1):
            spendCreditsAction(100)
        case (2, 2):
            spendCreditsAction(200)
            
        default:
            break
        }
    }
    
}
