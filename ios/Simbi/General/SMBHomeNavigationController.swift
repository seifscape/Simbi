//
//  SMBHomeNavigationController.swift
//  Simbi
//
//  Created by zhaohy@ifeng on 7/25/15.
//  Copyright (c) 2015 SimbiSocial. All rights reserved.
//

import UIKit

protocol SMBHomeNavDelegate {
//    func toggleFiltersView()
    func switchListAndMap(sender: UIButton)
}

class SMBHomeNavigationController: UINavigationController {

    
    let menuBtn = UIButton()
    let filtersBtn = UIButton()
    var filtersView :SMBFiltersView?
    var listOrMapBtn = UIButton()
    var delegateForSwitchListAndMap :SMBHomeNavDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.viewControllers.first!.isKindOfClass(SMBRandomUsersViewController) {
            filtersView?.delegateForSearch = self.viewControllers.first as! SMBRandomUsersViewController
        } else {
            filtersView?.delegateForSearch = self.viewControllers.first as! SMBMapViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 0)

        menuBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        menuBtn.setImage(UIImage(named: "Hamburger Icon"), forState: UIControlState.Normal)
        menuBtn.addTarget(self, action: "menuAction:", forControlEvents: UIControlEvents.TouchUpInside)

        filtersBtn.frame = CGRect(x: self.view.frame.width-100, y: 0, width: 44, height: 44)
        filtersBtn.setImage(UIImage(named: "filters_btn"), forState: UIControlState.Normal)
        filtersBtn.addTarget(self, action: "filtersAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        listOrMapBtn.frame = CGRect(x: self.view.frame.width-44, y: 0, width: 44, height: 44)
        listOrMapBtn.setImage(UIImage(named: "map_btn"), forState: UIControlState.Normal)
        listOrMapBtn.addTarget(self, action: "listOrMapAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationBar.addSubview(menuBtn)
        self.navigationBar.addSubview(filtersBtn)
        self.navigationBar.addSubview(listOrMapBtn)
        
        //filters
        filtersView = NSBundle.mainBundle().loadNibNamed("SMBFiltersView", owner: nil, options: nil).first as? SMBFiltersView
        filtersView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-60, height: self.view.frame.height-140)
        filtersView?.center = self.view.center
        filtersView?.isShowing = false
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User Actions
    
    func menuAction(sender: UIButton) {
        
        SMBAppDelegate.instance().showMenu()
    }
    
    func filtersAction(sender: UIButton) {
        
        if filtersView!.isShowing == false {
            if self.viewControllers.first!.isKindOfClass(SMBRandomUsersViewController) {
                filtersView?.showSegment.selectedSegmentIndex = 1;
                filtersView?.showSegment.enabled = true
                filtersView?.makefriendsBtn.enabled = true
                filtersView?.datingBtn.enabled = true
                filtersView?.networkBtn.enabled = true
                filtersView?.genderSegment.enabled = true
                
            } else {
                filtersView?.showSegment.selectedSegmentIndex = 0;
                filtersView?.showSegment.enabled = false
                filtersView?.makefriendsBtn.enabled = false
                filtersView?.datingBtn.enabled = false
                filtersView?.networkBtn.enabled = false
                filtersView?.genderSegment.enabled = false
                
                filtersView?.makefriendsBtn.layer.opacity = 0.5
                filtersView?.datingBtn.layer.opacity = 0.5
                filtersView?.networkBtn.layer.opacity = 0.5
                
            }
            self.view.addSubview(filtersView!)
            filtersView?.isShowing = true
            
        } else {
            filtersView?.removeFromSuperview()
            filtersView?.isShowing = false
        }
    }
    
    func listOrMapAction(sender: UIButton) {
        if filtersView?.isShowing == true {
            filtersView?.removeFromSuperview()
            filtersView?.isShowing = false
        }
        delegateForSwitchListAndMap?.switchListAndMap(sender)
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
