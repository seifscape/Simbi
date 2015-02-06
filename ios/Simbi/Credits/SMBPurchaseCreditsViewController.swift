//
//  SMBPurchaseCreditsViewController.swift
//  Simbi
//
//  Created by flynn on 11/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBPurchaseCreditsViewController: UITableViewController {
    
    var products: [PFProduct] = []
    var hud: MBProgressHUD?
    var isProcessingPurchase = false
    
    // MARK: - ViewController Lifecycle
    
    convenience override init() {
        self.init(style: .Grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Purchase Credits"
        self.tableView.backgroundColor = UIColor.simbiLavender2Color()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "loadProducts:", forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "purchaseDidSucceed:", name: "purchaseSucceeded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "purchaseDidFail:", name: "purchaseFailed", object: nil)
        
        loadProducts(self)
    }
    
    
    func loadProducts(sender: AnyObject) {
        
        var activityIndicator: UIActivityIndicatorView?
        
        if products.count == 0 {
            
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            activityIndicator!.frame = CGRectMake(0, 88, self.view.frame.width, 44)
            activityIndicator!.startAnimating()
            self.tableView.addSubview(activityIndicator!)
        }
        
        let query = PFProduct.query()
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if sender is UIRefreshControl {
                (sender as UIRefreshControl).endRefreshing()
            }
            
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
            
            if let products = objects {
                self.products = products as [PFProduct]
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    // MARK: - User Actions
    
    func purchaseCreditsAction(productIdentifier: String) {
                
        PFCloud.callFunctionInBackground("echo", withParameters: [:]) { (response: AnyObject!, error: NSError!) -> Void in
            
            if response != nil {
                
                self.hud = MBProgressHUD.HUDwithMessage("Processing...", parent: self)
                
                SMBPurchase.buyProduct(productIdentifier, block: { (error: NSError!) -> Void in
                    if error != nil {
                        self.hud?.dismissQuickly()
                    }
                })
            }
            else {
                let alertView = UIAlertView(title: "Unavailable", message: "We're sorry, but purchasing credits is unavailable at this time. Please try again later.", delegate: nil, cancelButtonTitle: "Ok")
                alertView.show()
            }
        }
    }
    
    
    // MARK: - Purchase Status Updates
    
    // After the purchases go through with Apple, a block (in SMBPurchase) gets called to
    // document the transaction on Parse and give the user their credits. That block will
    // post a notification indicating success or failure.
    
    func purchaseDidSucceed(notification: NSNotification) {
        
        isProcessingPurchase = false
        hud?.dismissQuickly()
        
        self.tableView.reloadData()
    }
    
    
    func purchaseDidFail(notification: NSNotification) {
        
        isProcessingPurchase = false
        hud?.dismissQuickly()
        
        let alertView = UIAlertView(title: "Uh Oh!", message: "Your purchase was not able to be processed by Simbi.", delegate: nil, cancelButtonTitle: "Ok")
        alertView.show()
    }
    
    
    // MARK: - UITableViewDataSource/Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else {
            return products.count
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 44
        }
        else {
            return 54
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.font = UIFont.simbiFontWithAttributes(kFontLight, size: 16)
        cell.selectionStyle = .None
        
        let lineView = UIView(frame: CGRectMake(16, 54-0.5, self.view.frame.width-32, 0.5))
        lineView.backgroundColor = UIColor.simbiDarkGrayColor()
        
        let creditsIconView = UIImageView(image: UIImage(named: "credits_icon"))
        creditsIconView.frame = CGRectMake(16, (54-26)/2, 26, 26)
        cell.addSubview(creditsIconView)
        
        let priceLabel = UILabel(frame: CGRectMake(tableView.frame.width-88, 0, 88, 54))
        priceLabel.font = UIFont.simbiFontWithAttributes(kFontLight, size: 16)
        priceLabel.textAlignment = .Center
        cell.addSubview(priceLabel)
        
        
        if indexPath.section == 0 {
        
            cell.selectionStyle = .None
            cell.textLabel?.text = "Total:"
            
            creditsIconView.frame = CGRectMake(self.view.frame.width-32-66, (44-26)/2, 26, 26)
            
            let creditsTotalLabel = UILabel(frame: CGRectMake(self.view.frame.width-66, 0, 66, 44))
            creditsTotalLabel.text = "342" // Future: Should reflect actual credit balance
            creditsTotalLabel.textColor = UIColor.blackColor()
            creditsTotalLabel.font = UIFont.simbiFontWithAttributes(kFontLight, size: 16)
            cell.addSubview(creditsTotalLabel)
            
            if SMBUser.currentUser().credits == nil {
                creditsTotalLabel.text = "0"
            }
            else {
                SMBUser.currentUser().credits.fetchIfNeededInBackgroundWithBlock({ (object: PFObject!, error: NSError!) -> Void in
                    creditsTotalLabel.text = "\(SMBUser.currentUser().credits.balance)"
                })
            }
        }
        else {
            
            cell.textLabel?.text = "         \(products[indexPath.row].title)"
            priceLabel.text = products[indexPath.row].objectForKey("price") as? String
            
            if indexPath.row != products.count-1 {
                cell.addSubview(lineView)
            }
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 {
            purchaseCreditsAction(products[indexPath.row].productIdentifier)
        }
    }
}
