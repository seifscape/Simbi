//
//  SMBCreditsViewController.swift
//  Simbi
//
//  Created by flynn on 10/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBCreditsViewController: UITableViewController {
    
    // MARK: - ViewController Lifecycle
    
    override convenience init() {
        self.init(style: .Grouped)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Credits"
        
        self.tableView.separatorColor = UIColor.clearColor()
    }
    
    
    // MARK: - User Actions

    
    
    // MARK: - UITableViewDataSource/Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            return 0.01
        case 1:
            return 16
        case 2:
            return 10
        default:
            return 22
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            return 88
        case 1:
            return 0.01
        case 2:
            return 44
        default:
            return 22
        }
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let view = UIView()
            
            let coverView = UIView(frame: CGRectMake(0, -self.view.frame.height+0.01, self.view.frame.width, self.view.frame.height))
            coverView.backgroundColor = UIColor.simbiLavender1Color()
            view.addSubview(coverView)
            
            return view
        }
        if section == 1 {
            
            let view = UIView()
            view.backgroundColor = UIColor.simbiWhiteColor()
            return view
        }
        else if section == 2 {
            
            let view = UIView()
            view.backgroundColor = UIColor.simbiLavender2Color()
            return view
        }
        else {
            return nil
        }
    }
    
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let view = UIView()
            view.backgroundColor = UIColor.simbiLightGrayColor()
            
            let label = UILabel(frame: CGRectMake(16, 0, tableView.frame.width-12, 88))
            label.text = "Earn free Tokens!\nUse Tokens to unlock fun."
            label.textColor = UIColor.blackColor()
            label.font = UIFont.simbiFontWithAttributes(kFontLight, size: 16)
            label.numberOfLines = 2
            view.addSubview(label)
            
            return view
        }
        else if section == 2 {
            
            let view = UIView()
            
            let coverView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
            coverView.backgroundColor = UIColor.simbiLavender2Color()
            view.addSubview(coverView)
            
            return view
        }
        else {
            return nil
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1 // Total
        case 1:
            return 4 // Share actions
        case 2:
            return 4 // Purchase, send, leave, test
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            return 44
            
        case (1, 0), (1, 1), (1, 2), (1, 3):
            return 54
            
        case (2, 0), (2, 1), (2, 2), (2, 3):
            return 54
            
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        
        cell.textLabel.textColor = UIColor.blackColor()
        cell.textLabel.font = UIFont.simbiFontWithAttributes(kFontLight, size: 16)
        cell.selectionStyle = .None
        
        let label = UILabel(frame: CGRectMake(tableView.frame.width-146-16, 8, 146, 36))
        label.center = CGPointMake(label.center.x, 54/2)
        label.textColor = UIColor.simbiWhiteColor()
        label.font = UIFont.simbiFontWithAttributes(kFontLight, size: 16)
        label.textAlignment = .Center
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        
        let logo = UIImageView(frame: CGRectMake(24, 0, 36, 36))
        label.addSubview(logo)
        
        let lineView = UIView(frame: CGRectMake(16, 54-0.5, self.view.frame.width-32, 0.5))
        lineView.backgroundColor = UIColor.simbiDarkGrayColor()
        
        let creditsIconView = UIImageView(image: UIImage(named: "credits_icon"))
        
        
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            cell.textLabel.text = "Total:"
            cell.backgroundColor = UIColor.simbiLavender1Color()
            
            creditsIconView.frame = CGRectMake(self.view.frame.width-32-66, 9, 26, 26)
            cell.addSubview(creditsIconView)
            
            let creditsTotalLabel = UILabel(frame: CGRectMake(self.view.frame.width-66, 0, 66, 44))
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
            
        case (1, 0):
            cell.textLabel.text = "60"
            cell.backgroundColor = UIColor.simbiWhiteColor()
            
            label.backgroundColor = UIColor.simbiGrayColor()
            label.textColor = UIColor.blackColor()
            label.text = "Per friend invited"
            cell.contentView.addSubview(label)
            
            creditsIconView.frame = CGRectMake(56, (54-26)/2, 26, 26)
            cell.addSubview(creditsIconView)
            
            cell.contentView.addSubview(lineView)
            
        case (1, 1):
            cell.textLabel.text = "250"
            cell.backgroundColor = UIColor.simbiWhiteColor()
            
            label.backgroundColor = UIColor.twitterColor()
            label.text = "     Tweet"
            cell.contentView.addSubview(label)
            
            logo.image = UIImage(named: "credits_twitter_logo")
            
            creditsIconView.frame = CGRectMake(56, (54-26)/2, 26, 26)
            cell.addSubview(creditsIconView)
            
            cell.contentView.addSubview(lineView)
            
        case (1, 2):
            cell.textLabel.text = "120"
            cell.backgroundColor = UIColor.simbiWhiteColor()
            
            label.backgroundColor = UIColor.twitterColor()
            label.text = "     Follow"
            cell.contentView.addSubview(label)
            
            logo.image = UIImage(named: "credits_twitter_logo")
            
            creditsIconView.frame = CGRectMake(56, (54-26)/2, 26, 26)
            cell.addSubview(creditsIconView)
            
            cell.contentView.addSubview(lineView)
            
        case (1, 3):
            cell.textLabel.text = "500"
            cell.backgroundColor = UIColor.simbiWhiteColor()
            
            label.backgroundColor = UIColor.facebookColor()
            label.text = "     Share"
            cell.contentView.addSubview(label)
            
            logo.image = UIImage(named: "credits_facebook_logo")
            
            creditsIconView.frame = CGRectMake(56, (54-26)/2, 26, 26)
            cell.addSubview(creditsIconView)
            
        case (2, 0):
            cell.backgroundColor = UIColor.simbiLavender2Color()
//            cell.accessoryType = .DisclosureIndicator
            cell.textLabel.text = "Purchase"
            
            creditsIconView.frame = CGRectMake(100, (54-26)/2, 26, 26)
            cell.addSubview(creditsIconView)
            
            cell.contentView.addSubview(lineView)
            
        case (2, 1):
            cell.backgroundColor = UIColor.simbiLavender2Color()
//            cell.accessoryType = .DisclosureIndicator
            cell.textLabel.text = "Send"
            
            creditsIconView.frame = CGRectMake(100, (54-26)/2, 26, 26)
            cell.addSubview(creditsIconView)
            
            cell.contentView.addSubview(lineView)
            
        case (2, 2):
            cell.backgroundColor = UIColor.simbiLavender2Color()
//            cell.accessoryType = .DisclosureIndicator
            cell.textLabel.text = "Leave"
            
            creditsIconView.frame = CGRectMake(100, (54-26)/2, 26, 26)
            cell.addSubview(creditsIconView)
            
            cell.contentView.addSubview(lineView)
            
        case (2, 3):
            cell.backgroundColor = UIColor.simbiLavender2Color()
            cell.textLabel.text = "Test"
            
        default:
            break
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
            
        case (0, 0):
            break
            
        case (1, 0), (1, 1), (1, 2), (1, 3):
            break
            
        case (2, 0):
            self.navigationController!.pushViewController(SMBPurchaseCreditsViewController(), animated: true)
            
        case (2, 1), (2, 2):
            break
            
        case (2, 3):
            self.navigationController!.pushViewController(SMBTestCreditsViewController(), animated: true)
            
        default:
            break
        }
    }
}
