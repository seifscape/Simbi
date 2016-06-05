//
//  ConversationsController.swift
//  Simbi
//
//  Created by Seif Kobrosly on 4/17/16.
//  Copyright © 2016 SimbiSocial. All rights reserved.
//

import Foundation

class ConversationsController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var userArray = ["Seif", "Milo"];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.tabBarController!.tabBar.tintColor = UIColor.whiteColor()
        self.tabBarController!.tabBar.barTintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //UIColor(red:0.78, green:0.18, blue:0.16, alpha:1)
        self.setupDataSource()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func setupDataSource() {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("convoCell")! 
        cell.textLabel?.text = userArray[indexPath.row];
        return cell
        
    }
    
}
