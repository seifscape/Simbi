//
//  SMBHomeNavigationController.swift
//  Simbi
//
//  Created by zhaohy@ifeng on 7/25/15.
//  Copyright (c) 2015 SimbiSocial. All rights reserved.
//

import UIKit

protocol SMBHomeNavDelegate {
    func switchListAndMap(sender: UIButton)
}

class SMBHomeNavigationController: UINavigationController {

    
    let menuBtn = UIButton()
    let filtersBtn = UIButton()
    var listOrMapBtn = UIButton()
    var delegateForSwitchListAndMap :SMBHomeNavDelegate?
    
    
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
        var filters = NSBundle.mainBundle().loadNibNamed("SMBFiltersView", owner: nil, options: nil).first as! SMBFiltersView
        filters.frame = CGRect(x: 0, y: 0, width: self.view.frame.width-60, height: self.view.frame.height-140)
        filters.center = self.view.center
        self.view.addSubview(filters)
    }
    
    func listOrMapAction(sender: UIButton) {
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
