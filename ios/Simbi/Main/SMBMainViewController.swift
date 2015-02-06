//
//  SMBMainViewController.swift
//  Simbi
//
//  Created by flynn on 10/8/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBMainViewController: SMBSplitViewController {
    
    let menuButton = UIButton()
    let chatButton = SMBChatButton()
    let menuButtonBackgroundView = UIView()
    let chatButtonBackgroundView = UIView()
    
    let mapViewController = SMBMapViewController()
    let homeViewController = SMBHomeViewController()
    let randomUsersViewController = SMBRandomUsersViewController()
    
    let btnPad: CGFloat = 11
    var firstScroll = true
    
    // MARK: - ViewController Lifecycle
    
    override convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController! is SMBNavigationController {
            (self.navigationController! as SMBNavigationController).showsMenu = false
            (self.navigationController! as SMBNavigationController).showsChat = false
        }
        
        // Set up split views
        
        self.scrollView.delaysContentTouches = false
        
        mapViewController.delegate = self
        
        homeViewController.parent = self
        homeViewController.delegate = self
        
        randomUsersViewController.delegate = self
        
        self.viewControllers = [mapViewController, homeViewController, randomUsersViewController]
        
        self.scrollToIndex(1, animated: false)
        
        
        // Add buttons
        
        menuButtonBackgroundView.frame = CGRectMake(btnPad, 20, 44, 44)
        menuButtonBackgroundView.backgroundColor = UIColor.simbiWhiteColor().colorWithAlphaComponent(0.9)
        menuButtonBackgroundView.layer.cornerRadius = 4
        menuButtonBackgroundView.layer.borderColor = UIColor.simbiWhiteColor().CGColor
        menuButtonBackgroundView.layer.borderWidth = 1
        menuButtonBackgroundView.layer.shadowOffset = CGSizeMake(1, 1)
        menuButtonBackgroundView.layer.shadowColor = UIColor.blackColor().CGColor
        menuButtonBackgroundView.layer.shadowOpacity = 0.33
        menuButtonBackgroundView.alpha = 0
        
        menuButton.frame = menuButtonBackgroundView.frame
        menuButton.setImage(UIImage(named: "menu_icon"), forState: .Normal)
        menuButton.addTarget(self, action: "menuAction:", forControlEvents: .TouchUpInside)
        menuButton.alpha = 0

        chatButtonBackgroundView.frame = CGRectMake(self.view.frame.width-44-btnPad, 20, 44, 44)
        chatButtonBackgroundView.backgroundColor = UIColor.simbiWhiteColor().colorWithAlphaComponent(0.9)
        chatButtonBackgroundView.layer.shadowOffset = CGSizeMake(1, 1)
        chatButtonBackgroundView.layer.shadowColor = UIColor.blackColor().CGColor
        chatButtonBackgroundView.layer.shadowOpacity = 0.33
        chatButtonBackgroundView.layer.cornerRadius = chatButtonBackgroundView.frame.width/2
        chatButtonBackgroundView.alpha = 0
        
        chatButton.frame = chatButtonBackgroundView.frame
        chatButton.addTarget(self, action: "chatAction:", forControlEvents: .TouchUpInside)
        chatButton.alpha = 0
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: "menuAction:")
        swipeRightGesture.direction = .Right
        menuButton.addGestureRecognizer(swipeRightGesture)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(self.currentIndex != 2, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        let mainWindow = UIApplication.sharedApplication().keyWindow!
        
        menuButtonBackgroundView.addToView(mainWindow, andAnimate: true)
        menuButton.addToView(mainWindow, andAnimate: true)
        chatButtonBackgroundView.addToView(mainWindow, andAnimate: true)
        chatButton.addToView(mainWindow, andAnimate: true)
        
        // If on the random users view, make sure that the button backgrounds are hidden
        
        if self.currentIndex == 2 {
            
            menuButtonBackgroundView.hidden = true
            chatButtonBackgroundView.hidden = true
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)/4), dispatch_get_main_queue(), { () -> Void in
                self.menuButtonBackgroundView.alpha = 0
                self.chatButtonBackgroundView.alpha = 0
                self.menuButtonBackgroundView.hidden = false
                self.chatButtonBackgroundView.hidden = false
            })
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kSMBNotificationHideChatIcon, object: nil)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        SMBAppDelegate.instance().enableSideMenuGesture(false)
        
        if SMBUser.currentUser().geoPoint == nil {
            pinLocationAction(self)
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        menuButtonBackgroundView.removeFromViewAndAnimate(animated)
        menuButton.removeFromViewAndAnimate(animated)
        chatButtonBackgroundView.removeFromViewAndAnimate(animated)
        chatButton.removeFromViewAndAnimate(animated)
        
        SMBAppDelegate.instance().enableSideMenuGesture(true)
                
        if self != self.navigationController?.visibleViewController &&
           !(self.navigationController?.visibleViewController is SMBChatViewController) &&
           !(self.navigationController?.visibleViewController is SMBPinLocationViewController) {
            
            SMBUser.currentUser().unreadMessageCount = 0
            SMBUser.currentUser().hasNewMessage = false
            SMBUser.currentUser().saveInBackgroundWithBlock(nil)
            
            NSNotificationCenter.defaultCenter().postNotificationName(kSMBNotificationHideChatIcon, object: nil)
        }
    }
    
    
    // MARK: - SMBSplitViewController
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if firstScroll {
            self.navigationController!.setNavigationBarHidden(true, animated: true)
            firstScroll = false
        }
        
        if scrollView.contentOffset.x > scrollView.frame.width {
            let relativeOffset = scrollView.contentOffset.x - scrollView.frame.width
            let ratio = max(0, 1 - relativeOffset / scrollView.frame.width)
            
            menuButtonBackgroundView.alpha = ratio
            chatButtonBackgroundView.alpha = ratio
            
            menuButton.frame = CGRectMake(
                3*(ratio-2/3)*btnPad,
                menuButton.frame.origin.y,
                menuButton.frame.width,
                menuButton.frame.height
            )
            menuButtonBackgroundView.frame = menuButton.frame
        }
        else {
            menuButtonBackgroundView.alpha = 1
            chatButtonBackgroundView.alpha = 1
            
            menuButton.frame = CGRectMake(
                btnPad,
                menuButton.frame.origin.y,
                menuButton.frame.width,
                menuButton.frame.height
            )
            menuButtonBackgroundView.frame = menuButton.frame
        }
    }
    
    
    override func readjustScrollView(scrollView: UIScrollView) {
        super.readjustScrollView(scrollView)
        
        if currentIndex == 2 { // Show nav bar for random users
            self.navigationController!.setNavigationBarHidden(false, animated: true)
        }
        else {
            self.navigationController!.setNavigationBarHidden(true, animated: true)
        }
    }
    
    
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        
        firstScroll = true
    }
    
    
    // MARK: - User Actions
    
    func menuAction(sender: AnyObject) {
        
        SMBAppDelegate.instance().showMenu()
        
        menuButtonBackgroundView.removeFromViewAndAnimate(true)
        menuButton.removeFromViewAndAnimate(true)
        chatButtonBackgroundView.removeFromViewAndAnimate(true)
        chatButton.removeFromViewAndAnimate(true)
    }
    
    
    func chatAction(sender: AnyObject) {
        
        let navigationController = UINavigationController(rootViewController: SMBChatListViewController())
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    func pinLocationAction(sender: AnyObject) {
        
        let navigationController = UINavigationController(rootViewController: SMBPinLocationViewController())
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
}


// MARK: - SMBMapViewDelegate

extension SMBMainViewController: SMBMapViewDelegate {
    
    func mapView(mapView: SMBMapViewController, willShowCard willShow: Bool) {
        
        scrollView.scrollEnabled = !willShow
        
        menuButton.hidden = !willShow
        chatButton.hidden = !willShow
        menuButtonBackgroundView.hidden = !willShow
        chatButtonBackgroundView.hidden = !willShow
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            self.menuButton.alpha = willShow ? 0 : 1
            self.chatButton.alpha = willShow ? 0 : 1
            self.menuButtonBackgroundView.alpha = willShow ? 0 : 1
            self.chatButtonBackgroundView.alpha = willShow ? 0 : 1
            
        }, completion: { (Bool) -> Void in
            
            self.menuButton.hidden = willShow
            self.chatButton.hidden = willShow
            self.menuButtonBackgroundView.hidden = willShow
            self.chatButtonBackgroundView.hidden = willShow
        })
    }
    
    
    func mapViewShouldShowExitButtons(mapView: SMBMapViewController) -> (Bool, Bool) {
        
        return (false, true)
    }
    
    
    func mapViewShouldExitLeft(sender: AnyObject) {
        
        // Do nothing
    }
    
    
    func mapViewShouldExitRight(sender: AnyObject) {
        
        self.scrollToIndex(1, animated: true)
    }
}


// MARK: - SMBHomeViewDelegate

extension SMBMainViewController: SMBHomeViewDelegate {
    
    func homeView(homeView: SMBHomeViewController, didSelectUserFromFriendsList user: SMBUser) {
        
        scrollToIndex(0, animated: true)
        
        let coordinate = CLLocationCoordinate2DMake(user.geoPoint.latitude, user.geoPoint.longitude)
        mapViewController.focusUserInMap(user, coordinate: coordinate)
    }
}


// MARK: - SMBRandomUsersViewDelegate

extension SMBMainViewController: _SMBRandomUsersViewDelegate {
    
    func randomUsersView(randomUsersView: _SMBRandomUsersView!, didSelectUserForChallenge user: SMBUser!) {
        
        let navigationController = UINavigationController(rootViewController: SMBSelectChallengeViewController(user: user))
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    func randomUsersView(randomUsersView: _SMBRandomUsersView!, didSelectUserForQuestion user: SMBUser!) {
        
        let navigationController = UINavigationController(rootViewController: SMBAnswerQuestionViewController(user))
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
}


// MARK: - SMBRandomUsersViewDeleage

extension SMBMainViewController: SMBRandomUsersViewDelegate {
    
}

