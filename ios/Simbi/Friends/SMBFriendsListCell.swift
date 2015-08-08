//
//  SMBFriendsListCell.swift
//  Simbi
//
//  Created by flynn on 10/12/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBFriendsListCell: UITableViewCell {
    
    class func cellHeight() -> CGFloat { return 44 }
    
    
    let profilePicture      = SMBImageView()
    let nameLabel           = UILabel()
    let emailLabel          = UILabel()
    let acceptButton        = UIButton()
    let activityIndicator   = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let requesetButton      = UIButton()
    let inviteButton        = UIButton()
    let chatButton          = UIButton()
    var user: SMBUser?
    
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profilePicture.frame = CGRectMake(4, 4, 36, 36)
        profilePicture.backgroundColor = UIColor.simbiBlackColor()
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        profilePicture.clipsToBounds = true
        self.addSubview(profilePicture)
        
        nameLabel.frame = CGRectMake(44, 0, self.frame.width-88, 26)
        nameLabel.textColor = UIColor.simbiBlackColor()
        nameLabel.font = UIFont.simbiFontWithSize(16)
        self.addSubview(nameLabel)
        
        emailLabel.frame = CGRectMake(44, 22, self.frame.width-88, 22)
        emailLabel.textColor = UIColor.simbiGrayColor()
        emailLabel.font = UIFont.simbiLightFontWithSize(14)
        self.addSubview(emailLabel)
        
        acceptButton.frame = CGRectMake(self.frame.width-44, 0, 44, 44)
        acceptButton.setTitle("＋", forState: .Normal)
        acceptButton.setTitleColor(UIColor.simbiBlueColor(), forState: .Normal)
        acceptButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 32)
        acceptButton.hidden = true
        self.addSubview(acceptButton)
        
        requesetButton.frame = CGRectMake(self.frame.width-80, 0, 75, 44)
        requesetButton.setTitle("Add Friend", forState: .Normal)
        requesetButton.setTitleColor(UIColor.simbiBlueColor(), forState: .Normal)
        requesetButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        requesetButton.hidden = true
        self.addSubview(requesetButton)
        
        inviteButton.frame = CGRectMake(self.frame.width-60, 0, 55, 44)
        inviteButton.setTitle("Invite", forState: .Normal)
        inviteButton.setTitleColor(UIColor.simbiBlueColor(), forState: .Normal)
        inviteButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        inviteButton.hidden = true
        self.addSubview(inviteButton)
        
        chatButton.frame = CGRectMake(self.frame.width-60, 0, 55, 44)
        chatButton.setTitle("Chat", forState: .Normal)
        chatButton.setTitleColor(UIColor.simbiBlueColor(), forState: .Normal)
        chatButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        chatButton.hidden = true
        self.addSubview(chatButton)
        
        activityIndicator.frame = acceptButton.frame
        activityIndicator.hidden = true
        self.addSubview(activityIndicator)
    }
    
    
    func animateAcceptButton() {
        
        acceptButton.alpha = 1
        acceptButton.hidden = false
        acceptButton.transform = CGAffineTransformMakeRotation(0)
        
        activityIndicator.alpha = 0
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.acceptButton.alpha = 0
            self.acceptButton.transform = CGAffineTransformMakeRotation(M_PI.CG)
            
            self.activityIndicator.alpha = 1
            
        }) { (Bool) -> Void in
            
            self.acceptButton.hidden = true
            self.acceptButton.alpha = 1
            self.acceptButton.transform = CGAffineTransformMakeRotation(0)
        }
    }
}
