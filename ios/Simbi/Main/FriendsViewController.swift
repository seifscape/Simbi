//
//  FriendsViewController.swift
//  Simbi
//
//  Created by Seif Kobrosly on 3/28/16.
//  Copyright © 2016 SimbiSocial. All rights reserved.
//

import UIKit
//import APAddressBook

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    let addressBook = APAddressBook()
    
    struct ContactStructure {
        
        var firstname:String?
        var lastname:String?
        var didInviteContact:Bool = false
    }


    var arrayOfContacts = [ContactStructure]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        //UIColor(red:0.78, green:0.18, blue:0.16, alpha:1)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        self.tabBarController!.tabBar.tintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
        self.tabBarController!.tabBar.barTintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
        
        self.searchBar.barTintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
        self.searchBar.translucent = false
        

        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        loadContacts()
        
        
        
        //UIColor(red:0.78, green:0.18, blue:0.16, alpha:1)
        
    }

    
    
    // MARK: - private
    func loadContacts() {
        self.addressBook.loadContacts({
            (contacts: [APContact]?, error: NSError?) in
            if let unwrappedContacts = contacts {
                
                for each in unwrappedContacts {
                    
                    let firstname = each.name?.firstName
                    let lastname  =  each.name?.lastName
                    var singleContact = ContactStructure()
                    singleContact.firstname = firstname
                    singleContact.lastname = lastname
                    singleContact.didInviteContact = false
                    self.arrayOfContacts.append(singleContact)
                    
                    self.tableView.reloadData()
                }
                
            } else if let unwrappedError = error {
                let alert = UIAlertView(title: "Error", message: unwrappedError.localizedDescription,
                    delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        else
        {
            return self.arrayOfContacts.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        if section == 0
        {
            return "Contacts already using Simbi"
        }
        else
        {
            return "Invite your contacts to Simbi"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIdentifier = ""
        
        if indexPath.section == 0
        {
            cellIdentifier = "simbiUsersCell"
            let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell!
            cell.textLabel?.text = "Seif Kobrosly"
            return cell

        }
        // Contacts
        else
        {
            cellIdentifier = "inviteContactCell"
            let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell!
            cell.textLabel!.text = arrayOfContacts[indexPath.row].firstname! + " " + arrayOfContacts[indexPath.row].lastname!
            let inviteButton  = UIButton(type: .Custom)
            inviteButton.addTarget(self, action: #selector(FriendsViewController.sendInviteToContact(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            guard let isInvited:Bool = arrayOfContacts[indexPath.row].didInviteContact {
//                else {continue}
//            }
            
            
            if(!(arrayOfContacts[indexPath.row].didInviteContact)) {
                if let image = UIImage(named: "invite_contact") {
                    inviteButton.setImage(image, forState: .Normal)
                }
            }
            else {
                if let image = UIImage(named: "request_sent") {
                    inviteButton.setImage(image, forState: .Normal)
                }
            }
            
            cell.accessoryView = inviteButton
            cell.accessoryView!.frame = CGRectMake(0, 0, 40, 40)
            cell.accessoryView?.sizeToFit()

            return cell
        }
        
       
    }
    
    func sendInviteToContact(sender: AnyObject) {

        let point = tableView.convertPoint(CGPoint.zero, fromView: sender as? UIView)
        
        guard let cellIndexPath = tableView.indexPathForRowAtPoint(point) else {
            fatalError("can't find point in tableView")
        }
        
        arrayOfContacts[cellIndexPath.row].didInviteContact = true;
        
        let indexPath = NSIndexPath(forRow: (cellIndexPath.row), inSection: 1)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)

    }

    
}
