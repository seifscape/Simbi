//
//  SMBBetaViewController.swift
//  Simbi
//
//  Created by zhaohy@ifeng on 7/25/15.
//  Copyright (c) 2015 SimbiSocial. All rights reserved.
//

import UIKit

class SMBBetaViewController: UITabBarController {

    var controllersWithList: Array<UINavigationController>?
    var controllersWithMap: Array<UINavigationController>?
    var nav0: SMBNavigationController!
    var nav1: SMBHomeNavigationController!
    var nav2: SMBHomeNavigationController!
    var isShowingList = true
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nav1.delegateForSwitchListAndMap = self
        nav2.delegateForSwitchListAndMap = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        nav1.delegateForSwitchListAndMap = nil
        nav2.delegateForSwitchListAndMap = nil
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
        nav0 = SMBNavigationController(rootViewController: chatListVC)
        nav0.showsMenu = true
        
        var randomVC = SMBRandomUsersViewController()
        var item1 = UITabBarItem(title: "Nearby", image: UIImage(named: "Search"), tag: 1)
        randomVC.tabBarItem = item1;
        nav1 = SMBHomeNavigationController(rootViewController: randomVC)

        var mapVC = SMBMapViewController()
        mapVC.tabBarItem = item1;
        nav2 = SMBHomeNavigationController(rootViewController: mapVC)

        
        controllersWithList = [nav0, nav1]
        controllersWithMap = [nav0, nav2]
        
        
        self.viewControllers = controllersWithList;
        
        self.selectedIndex = 1;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension SMBBetaViewController: SMBHomeNavDelegate {
    
    func switchListAndMap(sender: UIButton) {
        
        if isShowingList {
            
            sender.setImage(UIImage(named: "list_btn"), forState: UIControlState.Normal)
            
            self.viewControllers = self.controllersWithMap

            isShowingList = false
            
        } else {
            
            sender.setImage(UIImage(named: "map_btn"), forState: UIControlState.Normal)
            
            self.viewControllers = self.controllersWithList
            
            isShowingList = true
        }
    }
}
