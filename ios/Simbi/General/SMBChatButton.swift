//
//  SMBChatButton.swift
//  Simbi
//
//  Created by flynn on 10/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBChatButton: UIButton {
    
    var notificationHiddenFrame = CGRectZero
    var notificationNormalFrame = CGRectZero
    var notificationWideFrame   = CGRectZero
    
    let borderView = UIView()
    let notificationView = UIView()
    let notificationLabel = UILabel()
    
    override var frame: CGRect {
        
        didSet {
            
            self.layer.cornerRadius = frame.height/2
            
            borderView.frame = CGRectMake(0, 0, frame.width, frame.height)
            borderView.layer.cornerRadius = borderView.frame.height/2
            
            // Frames for the different notification states
            
            notificationHiddenFrame = CGRectMake(2+13/2, frame.height-13/2,  0,  0)
            notificationNormalFrame = CGRectMake(     0, frame.height-13  , 13, 13)
            notificationWideFrame   = CGRectMake(     0, frame.height-13  , 13, 13)
            //notificationWideFrame   = CGRectMake(    -2, frame.height-13  , 17, 13)
            
            // Adjust frame for subviews
            
            if (SMBUser.currentUser() != nil && SMBUser.currentUser().hasNewMessage) || SMBAppDelegate.instance().isAtHomeOrChat() {
                
                if SMBUser.currentUser().unreadMessageCount != nil {
                    
                    if SMBUser.currentUser().unreadMessageCount != nil {
                        
                        if SMBUser.currentUser().unreadMessageCount.intValue == 0 {
                            notificationView.frame = notificationHiddenFrame
                            notificationView.alpha = 0
                        }
                        else if SMBUser.currentUser().unreadMessageCount.intValue < 10 {
                            notificationView.frame = notificationNormalFrame
                        }
                        else {
                            notificationView.frame = notificationWideFrame
                        }
                    }
                    else { notificationView.frame = notificationWideFrame }
                }
                else {
                    notificationView.frame = notificationWideFrame
                }
            }
            else {
                notificationView.frame = notificationHiddenFrame
            }
            notificationView.layer.cornerRadius = notificationView.frame.height/2
            
            notificationLabel.frame = notificationWideFrame
        }
    }
    
    
    // MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//    
//    convenience init() {
//        self.init()
//        loadView()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    
    func loadView() {
        
        self.setImage(UIImage(named: "chat_icon"), forState: .Normal)
        self.tintColor = UIColor.simbiBlueColor()
        
        
        // Set up subviews
        
        borderView.layer.borderColor = UIColor.whiteColor().CGColor
        borderView.layer.borderWidth = 1
        borderView.hidden = true
        borderView.userInteractionEnabled = false
        self.addSubview(borderView)
        
        notificationView.backgroundColor = UIColor.simbiRedColor()
        notificationView.layer.cornerRadius = notificationView.frame.height/2
        notificationView.layer.masksToBounds = true
        notificationView.userInteractionEnabled = false
        self.addSubview(notificationView)
        
        if SMBUser.currentUser() != nil &&
           SMBUser.currentUser().unreadMessageCount != nil &&
           SMBUser.currentUser().unreadMessageCount.intValue > 0 {
            
            notificationLabel.text = SMBUser.currentUser().unreadMessageCount.stringValue
        }
        else {
            notificationLabel.alpha = 0
        }
        notificationLabel.textColor = UIColor.whiteColor()
        notificationLabel.font = UIFont.simbiBoldFontWithSize(9)
        notificationLabel.textAlignment = .Center
        notificationLabel.userInteractionEnabled = false
        //self.addSubview(notificationLabel)
        
        
        // Subscribe to notifications
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showChatNotification:", name: kSMBNotificationShowChatIcon, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideChatNotification:", name: kSMBNotificationHideChatIcon, object: nil)
    }

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Notification Handling
    
    func showChatNotification(notification: NSNotification) {
        
        if SMBAppDelegate.instance().isAtHomeOrChat() {
            
            notificationLabel.text = SMBUser.currentUser().unreadMessageCount.stringValue
            
            
            if (notificationLabel.text?.characters.count) > 2 {
                notificationLabel.text = "99+"
            }
            
            animateNotificationViewIn()
        }
    }
    
    
    func hideChatNotification(notification: NSNotification) {
        
        if SMBUser.currentUser().unreadMessageCount != nil {
            notificationLabel.text = SMBUser.currentUser().unreadMessageCount.stringValue
        }
        else {
            notificationLabel.text = ""
        }
        
        if (notificationLabel.text?.characters.count) > 2 {
            notificationLabel.text = "99+"
        }
        
        animateNotificationViewOut()
    }
    
    
    // MARK: Public Methods
    
    func showBackground(shouldShow: Bool) {
        
        borderView.hidden = !shouldShow
        
        if shouldShow {
            self.backgroundColor = UIColor.simbiWhiteColor().colorWithAlphaComponent(0.9)
            self.layer.shadowOffset = CGSizeMake(1, 1)
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowOpacity = 0.33
        }
        else {
            self.backgroundColor = UIColor.clearColor()
            self.layer.shadowOpacity = 0
        }
    }
    
    
    // MARK: Private Methods
    
    private func animateNotificationViewIn() {
        
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            
            self.notificationView.frame = (self.notificationLabel.text?.characters.count) > 1 ?
                self.notificationWideFrame : self.notificationNormalFrame

            self.notificationView.layer.cornerRadius = self.notificationView.frame.height/2
            
        }) { (Bool) -> Void in
            
            UIView.animateWithDuration(0.33, animations: { () -> Void in
                self.notificationLabel.alpha = 1
            })
        }
    }
    
    
    private func animateNotificationViewOut() {
        
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            
            self.notificationLabel.alpha = 0
            
        }) { (Bool) -> Void in
            
            UIView.animateWithDuration(0.33, animations: { () -> Void in
                self.notificationView.frame = self.notificationHiddenFrame
            })
        }
    }
}
