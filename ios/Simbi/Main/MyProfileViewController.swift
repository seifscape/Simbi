//
//  MyProfileViewController.swift
//  Simbi
//
//  Created by Seif Kobrosly on 3/28/16.
//  Copyright © 2016 SimbiSocial. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileImageView : UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
        //UIColor(red:0.78, green:0.18, blue:0.16, alpha:1)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        self.tabBarController!.tabBar.tintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1) //UIColor.whiteColor()
//        self.tabBarController!.tabBar.barTintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Profile Image
        self.profileImageView.layer.borderWidth = 1
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.blackColor().CGColor
        self.profileImageView.layer.cornerRadius = 50
        self.profileImageView.clipsToBounds = true

        
        //UIColor(red:0.78, green:0.18, blue:0.16, alpha:1)
    
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cellIdentifier = ""
        
        if indexPath.row == 0 && indexPath.section == 0 {
            cellIdentifier = "editProfileCell"
            let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell!
            cell.accessoryView = UIImageView(image: UIImage(named: "profile_cell_icon"))
            cell.accessoryView!.frame = CGRectMake(0, 0, 25, 25)
            return cell
        }
        else if indexPath.row == 1 && indexPath.section == 0 {
            cellIdentifier = "friendsCell"
            let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell!
            cell.accessoryView = UIImageView(image: UIImage(named: "friends"))
            cell.accessoryView!.frame = CGRectMake(0, 0, 25, 25)
            return cell
        }
        else {
            cellIdentifier = "conversationsCell"
            let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell!
            cell.accessoryView = UIImageView(image: UIImage(named: "conversations"))
            cell.accessoryView!.frame = CGRectMake(0, 0, 25, 25)
            

            return cell
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
