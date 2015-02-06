//
//  SMBChatBallView.swift
//  Simbi
//
//  Created by flynn on 9/22/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


protocol SMBChatBallDelegate {
    func chatBallShouldShow(chatBall: SMBChatBallView)
    func chatBallShouldHide(chatBall: SMBChatBallView)
    func chatBallDidSelect(chatBall: SMBChatBallView)
}


class SMBChatBallView: UIView, SMBChatManagerDelegate {
    
    // MARK: - Properties
    
    private let timerView: SMBChatCircleTimerView
    private let innerView: UIView
    private let nameLabel: UILabel
    private let profilePictureView: SMBImageView
    
    private var tapGesture: UITapGestureRecognizer?
    
    var delegate: SMBChatBallDelegate?
    
    var chat: SMBChat? {
        
        willSet {
            
            if let newChat = newValue {
                SMBChatManager.sharedManager().addChatDelegate(self, forChat: newChat)
                
                nameLabel.text = newChat.otherUser().name
                
                if newChat.otherUserHasRevealed() || newChat.forceRevealed {
                    nameLabel.hidden = true
                    profilePictureView.hidden = false
                    profilePictureView.parseImage = newChat.otherUser().profilePicture
                }
                else {
                    nameLabel.hidden = false
                    profilePictureView.hidden = true
                }
                
                delegate?.chatBallShouldShow(self)
            }
            else {
                SMBChatManager.sharedManager().cleanDelegatesForChat(chat)
                delegate?.chatBallShouldHide(self)
            }
        }
    }
    
    // MARK: - Initialization
    
    required init(coder aDecoder: NSCoder) { fatalError("Init with NSCoder is not supported") }
    
    override init(frame: CGRect) {
        
        // Set up subviews
        
        timerView = SMBChatCircleTimerView(frame: CGRectMake(1, 1, frame.width-2, frame.height-2), chat: nil)
        timerView.backgroundColor = UIColor.simbiBlackColor()
        timerView.layer.cornerRadius = timerView.frame.width/2
        timerView.layer.masksToBounds = true
        timerView.layer.borderColor = UIColor.simbiBlackColor().CGColor
        timerView.layer.borderWidth = 0.66
        timerView.userInteractionEnabled = false
        
        innerView = UIView(frame: CGRectMake(4, 4, frame.width-8, frame.height-8))
        innerView.backgroundColor = UIColor.simbiWhiteColor()
        innerView.layer.cornerRadius = innerView.frame.width/2
        innerView.userInteractionEnabled = false
        
        nameLabel = UILabel(frame: CGRectMake(0, 0, frame.width, frame.height))
        nameLabel.backgroundColor = UIColor.clearColor()
        nameLabel.textColor = UIColor.simbiBlackColor()
        nameLabel.font = UIFont.simbiFontWithSize(12)
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.userInteractionEnabled = false
        
        profilePictureView = SMBImageView(frame: CGRectMake(0, 0, innerView.frame.width, innerView.frame.height))
        profilePictureView.backgroundColor = UIColor.clearColor()
        profilePictureView.layer.cornerRadius = profilePictureView.frame.width/2
        profilePictureView.layer.masksToBounds = true
        profilePictureView.userInteractionEnabled = false
        
        // Init and add views
        
        super.init(frame: frame)
        
        self.addSubview(timerView)
        self.addSubview(innerView)
        innerView.addSubview(nameLabel)
        innerView.addSubview(profilePictureView)
        
        tapGesture = UITapGestureRecognizer(target: self, action: "tapAction:")
        tapGesture!.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture!)
    }
    
    
    deinit {
        if chat != nil {
            SMBChatManager.sharedManager().cleanDelegatesForChat(chat)
        }
    }
    
    
    // MARK: - User Actions
    
    func tapAction(tapGesture: UITapGestureRecognizer) {
        delegate?.chatBallDidSelect(self)
    }
    
    
    // MARK: - SMBChatManagerDelegate
    
    func chatManager(chatManager: SMBChatManager!, willLoadMessagesForChat chat: SMBChat!) {
        self.chat = chat
    }
    
    
    func chatManager(chatManager: SMBChatManager!, didLoadMessages messages: NSMutableArray!, gameMessages: NSMutableArray!, forChat chat: SMBChat!) {
        self.chat = chat
    }
    
    
    func chatManager(chatManager: SMBChatManager!, failedToLoadMessagesForChat chat: SMBChat!, error: NSError!) {
        self.chat = chat
    }
    
    
    func chatManager(chatManager: SMBChatManager!, didReceiveMessage message: SMBMessage!, forChat chat: SMBChat!) {
        self.chat = chat
        
        if let dateStarted = chat.dateStarted {
            self.timerView.setTime(NSDate())
        }
    }
    
    
    func chatManager(chatManager: SMBChatManager!, didReceiveGameMessage message: SMBMessage!, forChat chat: SMBChat!) {
        self.chat = chat
        
        if let dateStarted = chat.dateStarted {
            timerView.setTime(NSDate())
        }
    }
    
    
    func chatManager(chatManager: SMBChatManager!, chatDidExpire chat: SMBChat!) {
        self.chat = chat
        
        delegate?.chatBallShouldHide(self)
    }
    
    
    func chatManager(chatManager: SMBChatManager!, otherUserDidRevealWithImage image: UIImage!, inChat chat: SMBChat!) {
        self.chat = chat
        
        nameLabel.hidden = true
        profilePictureView.hidden = false
        
        profilePictureView.parseImage = chat.otherUser().profilePicture
    }
    
    
    func chatManager(chatManager: SMBChatManager!, otherUserLeftChat chat: SMBChat!) {
        self.chat = chat
    }
    
    
    func chatManager(chatManager: SMBChatManager!, didDeclineChat chat: SMBChat!) {
        self.chat = chat
        
        delegate?.chatBallShouldHide(self)
    }
    
    
    func chatManager(chatManager: SMBChatManager!, otherUserIsTyping isTyping: Bool, forChat chat: SMBChat!) {
        self.chat = chat
    }
    
    
    func chatManager(chatManager: SMBChatManager!, forcedRevealAtIndex index: Int, forChat chat: SMBChat!) {
        self.chat = chat
        
        nameLabel.hidden = true
        profilePictureView.hidden = false
        
        profilePictureView.parseImage = chat.otherUser().profilePicture
    }
}
