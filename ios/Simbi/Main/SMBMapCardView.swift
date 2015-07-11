//
//  SMBMapCardView.swift
//  Simbi
//
//  Created by flynn on 10/10/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit

protocol SMBMapCardViewDelegate {

    func gotoQuestionFromMapCard(#thatUser: SMBUser)
    func gotoChatFromMapCard(#thatUser: SMBUser)
}

class SMBMapCardView: UIView {
    var delegate: SMBMapCardViewDelegate?
    
    let user: SMBUser
    
    required init(coder aDecoder: NSCoder) { fatalError("Init with NSCoder is not supported") }
    
    init(frame: CGRect, user: SMBUser) {
        self.user = user
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.simbiWhiteColor()
        
        
        let pointerView = UIView(frame: CGRectMake(0, 0, 22, 22))
        pointerView.center = CGPointMake(frame.width/2, frame.height)
        pointerView.backgroundColor = UIColor.simbiWhiteColor()
        pointerView.transform = CGAffineTransformMakeRotation(M_PI_4.CG)
        self.addSubview(pointerView)
        
        
        let profilePictureView = SMBImageView(frame: CGRectMake(0, 0, frame.width, frame.height-66), parseImage: user.profilePicture)
        profilePictureView.contentMode = .ScaleAspectFill
        profilePictureView.layer.masksToBounds = true
        self.addSubview(profilePictureView)
        
        
        let fadeView = UIView(frame: CGRectMake(0, frame.height-66-44, frame.width, 44))
        fadeView.backgroundColor = UIColor(white: 0, alpha: 0.75)
        
        let gradientLayer = CAGradientLayer()
        let colors: [AnyObject] = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        gradientLayer.colors = colors
        gradientLayer.frame = CGRectMake(0, 0, fadeView.frame.width, fadeView.frame.height)
        
        fadeView.layer.mask = gradientLayer
        self.addSubview(fadeView)
        
        
        let nameLabel = UILabel(frame: CGRectMake(56, frame.height-66-44, frame.width-56*2, 44))
        nameLabel.text = user.name
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont.simbiFontWithSize(14)
        nameLabel.textAlignment = .Center
        nameLabel.numberOfLines = 2
        nameLabel.layer.shadowColor = UIColor.blackColor().CGColor
        nameLabel.layer.shadowOffset = CGSizeMake(1, 1)
        nameLabel.layer.shadowOpacity = 0.5
        self.addSubview(nameLabel)
        
        
        let locationLabel = UILabel(frame: CGRectMake(52, frame.height-66, frame.width-52*2, 66))
        locationLabel.font = UIFont.simbiFontWithSize(14)
        locationLabel.numberOfLines = 2
        locationLabel.textAlignment = .Center
        self.addSubview(locationLabel)
        
        
        let lastUpdatedLabel = UILabel(frame: CGRectMake(0, frame.height-66, frame.width-8, 22))
        lastUpdatedLabel.textColor = UIColor.simbiGrayColor()
        lastUpdatedLabel.textAlignment = .Right
        lastUpdatedLabel.font = UIFont.simbiFontWithSize(8)
        self.addSubview(lastUpdatedLabel)
        
        
        let messageButton = UIButton()
        messageButton.frame = CGRectMake(6, frame.height-66-56/2, 56, 56)
        messageButton.backgroundColor = UIColor.simbiBlueColor()
        messageButton.setImage(UIImage(named: "chat_icon_white"), forState: .Normal)
        messageButton.layer.cornerRadius = messageButton.frame.width/2
        messageButton.layer.borderColor = UIColor.simbiWhiteColor().CGColor
        messageButton.layer.borderWidth = 1
        /*
            added by zhy at 2015-07-11 for adding chat function
        */
        messageButton.addTarget(self, action: "chatAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(messageButton)
        
        
        // Get the last activity for this user
        
        let query = PFQuery(className: SMBActivity.parseClassName())
        query.whereKey("user", equalTo: user)
        query.orderByDescending("createdAt")
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicatorView.frame = locationLabel.frame
        activityIndicatorView.startAnimating()
        self.addSubview(activityIndicatorView)
        
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            
            if object != nil {
                
                let activity = object as! SMBActivity
                
                // Update date
                lastUpdatedLabel.text = activity.createdAt!.relativeDateString()
                
                // Update text
                let activityText = NSMutableAttributedString(string: "Checked in at ", attributes: [NSForegroundColorAttributeName: UIColor.simbiDarkGrayColor()])
                let highlighted = NSMutableAttributedString(string: activity.activityText, attributes: [NSForegroundColorAttributeName: UIColor.simbiBlueColor()])
                activityText.appendAttributedString(highlighted)
                
                locationLabel.attributedText = activityText
            }
            else {
                locationLabel.text = "Hasn't checked in yet!"
                locationLabel.textColor = UIColor.simbiGrayColor()
            }
        }
    }
    
    
    
    func chatAction(sender: AnyObject) {
        var friends:[SMBUser]? = SMBUser.currentUser().friends.query()?.findObjects() as? [SMBUser]
        
        for u in friends! {
            if u.objectId == user.objectId {
                delegate?.gotoChatFromMapCard(thatUser: user)

                return
            }
        }
        
        delegate?.gotoQuestionFromMapCard(thatUser: user)
    }
    
}
