//
//  SMBBetaViewController.swift
//  Simbi
//
//  Created by zhaohy@ifeng on 7/25/15.
//  Copyright (c) 2015 SimbiSocial. All rights reserved.
//

import UIKit

class SMBBetaViewController: UITabBarController {

    var controllersWithList: Array<UIViewController>?
    var controllersWithMap: Array<UIViewController>?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as! SMBHomeNavigationController).delegateForSwitchListAndMap = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //background
        var blackView = UIView(frame: self.tabBar.bounds)
        blackView.backgroundColor = UIColor(red: 40/256, green: 40/256, blue: 40/256, alpha: 1)
        self.tabBar.insertSubview(blackView, atIndex: 0)
        
     
        // viewcontrollers
        var chatListVC = SMBChatListViewController();
        var item0 = UITabBarItem(title: "Chat", image: UIImage(named: "chat_item"), tag: 0)
        chatListVC.tabBarItem = item0;
        
        
        var randomVC = SMBRandomUsersViewController()
        var item1 = UITabBarItem(title: "Nearby", image: UIImage(named: "Search"), tag: 1)
        randomVC.tabBarItem = item1;
        
        var mapVC = SMBMapViewController()
        mapVC.tabBarItem = item1;
        
        
        controllersWithList = [chatListVC, randomVC]
        controllersWithMap = [chatListVC, mapVC]
        
        
        self.viewControllers = controllersWithList;
        
        self.selectedIndex = 1;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SMBBetaViewController: SMBHomeNavDelegate {
    
    func switchListAndMap(sender: UIButton) {
        
        if self.selectedViewController!.isKindOfClass(SMBRandomUsersViewController) {
            
            sender.setImage(UIImage(named: "list_btn"), forState: UIControlState.Normal)
            
            self.viewControllers = self.controllersWithMap
        } else {
            
            sender.setImage(UIImage(named: "map_btn"), forState: UIControlState.Normal)
            
            self.viewControllers = self.controllersWithList
        }
    }
}
