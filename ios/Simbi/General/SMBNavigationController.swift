//
//  SMBNavigationController.swift
//  Simbi
//
//  Created by flynn on 10/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


// Subclass of UINavigationController that handles displaying custom menu and chat buttons
// in the navigation bar. The menu button will always be shown on the root view controller,
// and the chat button will always be shown unless the view controller has a right bar button
// item in its navigation items.

// The buttons are UIButtons instead of UIBarButtonItems because SMBChatButton subclasses from
// UIButton (to be used in places other than the navigation bar) and getting the menu button to
// flush to the left was rather hacky.


class SMBNavigationController: UINavigationController {
    
    let menuButton = UIButton()
    let chatButton = SMBChatButton()
    
    var showsMenu: Bool = false {
        didSet {
            updateNavigationBarButtons(false)
        }
    }
    var showsChat: Bool = false {
        didSet {
            updateNavigationBarButtons(false)
        }
    }
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor(red: 107/256.0, green: 167/256.0, blue: 249/256.0, alpha: 1)
        // Add buttons
        
        menuButton.frame = CGRectMake(0, 0, 44, 44)
        let menuImageView = UIImageView(frame: CGRectMake(-22, 0, 44, 44))
        menuImageView.image = UIImage(named: "menu_icon")
        menuButton.addSubview(menuImageView)
        menuButton.clipsToBounds = true
        menuButton.addTarget(self, action: "menuAction:", forControlEvents: .TouchUpInside)
        
        chatButton.frame = CGRectMake(self.view.frame.width-55, 0, 44, 44)
        chatButton.addTarget(self, action: "chatAction:", forControlEvents: .TouchUpInside)
    }
    
    
    // Pushing and Popping Stack Items
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        updateNavigationBarButtons(animated)
    }
    
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        let value = super.popViewControllerAnimated(animated)
        updateNavigationBarButtons(animated)
        return value
    }
    
    
    override func popToRootViewControllerAnimated(animated: Bool) -> [AnyObject]? {
        let value = super.popToRootViewControllerAnimated(animated)
        updateNavigationBarButtons(animated)
        return value
    }
    
    
    override func popToViewController(viewController: UIViewController, animated: Bool) -> [AnyObject]? {
        let value = super.popToViewController(viewController, animated: animated)
        updateNavigationBarButtons(animated)
        return value
    }
    
    
    // MARK: - User Actions
    
    func menuAction(sender: AnyObject) {
        
        SMBAppDelegate.instance().showMenu()
    }
    
    
    func chatAction(sender: AnyObject) {
        
        let navigationController = UINavigationController(rootViewController: SMBChatListViewController())
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    // MARK: - Private Methods
    
    func showButtons(shouldShow: Bool, animated: Bool) {
        
        if shouldShow {
            
            showsMenu ? menuButton.addToView(self.navigationBar, andAnimate: animated) : menuButton.removeFromSuperview()
            
            showsChat ? chatButton.addToView(self.navigationBar, andAnimate: animated) : chatButton.removeFromSuperview()
        }
        else {
            menuButton.removeFromViewAndAnimate(animated)
            
            if self.visibleViewController.navigationItem.rightBarButtonItem != nil || !showsChat {
                chatButton.removeFromViewAndAnimate(animated)
            }
        }
    }
    
    
    func updateNavigationBarButtons(animated: Bool) {
        
        showButtons(self.visibleViewController == self.viewControllers.first as! UIViewController, animated: animated)
    }
}
