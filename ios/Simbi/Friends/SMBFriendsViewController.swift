//
//  SMBFriendsViewController.swift
//  Simbi
//
//  Created by flynn on 10/10/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBFriendsViewController: SMBSplitViewController {
    
    let viewSelectorControl = UISegmentedControl(items: ["Map", "Friends"])
    
    
    // MARK: - ViewController Lifecycle
    
    override convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Set up split views
        
        let mapViewController = SMBMapViewController()
        
        let friendsListViewController = SMBFriendsListViewController()
        
        self.viewControllers = [mapViewController, friendsListViewController]
        
        
        // Add buttons
        
        viewSelectorControl.frame = CGRectMake(66, 6, self.view.frame.width-132, 32)
        viewSelectorControl.selectedSegmentIndex = 0
        viewSelectorControl.tintColor = UIColor.simbiBlueColor()
        viewSelectorControl.addTarget(self, action: "viewSelectorDidChange:", forControlEvents: .ValueChanged)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setLeftBarButtonItem(nil, animated: false)
        
        viewSelectorControl.addToView(self.navigationController?.navigationBar, andAnimate: animated)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewSelectorControl.removeFromViewAndAnimate(animated)
    }
    
    
    // MARK: - SMBSplitViewController
    
    override func readjustScrollView(scrollView: UIScrollView) {
        super.readjustScrollView(scrollView)
        
        viewSelectorControl.selectedSegmentIndex = currentIndex
    }
    
    
    // MARK: - User Actions
    
    func viewSelectorDidChange(viewSelector: UISegmentedControl) {
        
        self.scrollToIndex(viewSelector.selectedSegmentIndex)
    }
}

