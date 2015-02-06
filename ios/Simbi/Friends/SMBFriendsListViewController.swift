//
//  SMBFriendsListViewController.swift
//  Simbi
//
//  Created by flynn on 10/10/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBFriendsListViewController: UITableViewController {
    
    let menuButton = UIButton()
    let chatButton = UIButton()
    
    var objects: [SMBFriendsListModel] = []
    
    
    // MARK: - ViewController Lifecycle
    
    override convenience init() { self.init(style: .Grouped) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Friends"
        
        SMBFriendsManager.sharedManager().addDelegate(self)
        SMBFriendRequestsManager.sharedManager().addDelegate(self)
        
        self.tableView.backgroundColor = UIColor.simbiWhiteColor()
        
        self.tableView.registerClass(SMBFriendsListModel.cellClass(), forCellReuseIdentifier: SMBFriendsListModel.cellReuse())
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshAction:", forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl
        
        loadObjects()
    }
    
    
    // MARK: - User Actions
    
    func refreshAction(sender: AnyObject) {
        
        let refreshControl = sender as UIRefreshControl
        
        self.tableView.userInteractionEnabled = false
        
        SMBFriendsManager.sharedManager().loadObjects { (Bool) -> Void in
            SMBFriendRequestsManager.sharedManager().loadObjects({ (Bool) -> Void in
                self.tableView.userInteractionEnabled = true
                refreshControl.endRefreshing()
            })
        }
    }
    
    
    // MARK: - Private Methods
    
    private func loadObjects() {
        
        objects = []
        
        // Get all friends and friend requests, sort alphabetically by name
        
        var allObjects = SMBFriendsManager.sharedManager().objects + SMBFriendRequestsManager.sharedManager().objects
        
        allObjects = sorted(allObjects) { a, b in
            
            var aName: String
            var bName: String
            
            if a is SMBUser { aName = (a as SMBUser).name }
            else            { aName = (a as SMBFriendRequest).fromUser.name }
            
            if b is SMBUser { bName = (b as SMBUser).name }
            else            { bName = (b as SMBFriendRequest).fromUser.name }
            
            return aName < bName
        }
        
        // Put each item in the model object
        
        for object in allObjects {
            
            var model: SMBFriendsListModel
            
            if object is SMBUser {
                model = SMBFriendsListModel(user: object as SMBUser)
            }
            else {
                model = SMBFriendsListModel(request: object as SMBFriendRequest)
            }
            
            objects.append(model)
        }
        
        self.tableView.reloadData()
    }
    
    
    // MARK: - UITableViewDataSource/Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SMBFriendsListModel.cellHeight()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return objects[indexPath.row].cellForTable(tableView, indexPath: indexPath)
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let findFriendsButton = UIButton()
        findFriendsButton.frame = CGRectMake(0, 0, self.view.frame.width, 44)
        findFriendsButton.setTitle("Find Friends", forState: .Normal)
        findFriendsButton.setTitleColor(UIColor.simbiBlueColor(), forState: .Normal)
        findFriendsButton.titleLabel?.font = UIFont.simbiFontWithSize(14)
        findFriendsButton.addTarget(self, action: "findFriendsAction:", forControlEvents: .TouchUpInside)
        
        return findFriendsButton
    }
    
    
    // MARK: - User Actions
    
    func findFriendsAction(sender: AnyObject) {
        
        self.navigationController?.pushViewController(SMBFindFriendsViewController(), animated: true)
    }
}


// MARK: - SMBManagerDelegate

extension SMBFriendsListViewController: SMBManagerDelegate {
    
    func manager(manager: SMBManager!, didUpdateObjects objects: [AnyObject]!) {
        
        loadObjects()
    }
    
    
    func manager(manager: SMBManager!, didFailToLoadObjects error: NSError!) {
        
    }
}
