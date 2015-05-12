//
//  SMBRandomUserItemView.swift
//  Simbi
//
//  Created by flynn on 10/30/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


protocol SMBRandomUserItemDelegate {
    // Have to use this naming convention - Swift bug~
    func itemViewDidSelectUserForQuestion(itemView: SMBRandomUserItemView, user: SMBUser)
    func itemViewDidSelectUserForChallenge(itemView: SMBRandomUserItemView, user: SMBUser)
}


class SMBRandomUserItemView: UIView {
    
    var delegate: SMBRandomUserItemDelegate?
    
    let user: SMBUser
    
    let circleView = UIView()
    let imageContainerView = UIView()
    let nameLabel = UILabel()
    let interestLabel = UILabel()
    let distanceLabel = UILabel()
    let buttonContainerView = UIView()
    
    var isFaded = true
    
    
    // MARK: - View Initialization
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(frame: CGRect, user: SMBUser) {
        self.user = user
        super.init(frame: frame)
        loadView()
    }
    
    
    private func loadView() {
                
        let backgroundLineView = UIView(frame: CGRectMake(40+110/2-1, 0, 2, self.frame.height))
        backgroundLineView.backgroundColor = UIColor.simbiGrayColor()
        //self.addSubview(backgroundLineView)
        
        
        imageContainerView.frame = CGRectMake(40, (self.frame.height-110)/2, 110, 110)
        imageContainerView.alpha = 0.5
        imageContainerView.transform = CGAffineTransformMakeScale(0.95, 0.95)
        var tapGr:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:"viewTapped:")
        tapGr.numberOfTapsRequired = 1
        self.imageContainerView.addGestureRecognizer(tapGr)
        
        let pictureImageView = UIImageView(frame: CGRectMake(0, 0, 110, 110))
        pictureImageView.backgroundColor = UIColor.simbiBlackColor()
   
        /*modified by zhy*/
        if kSMBUserGenderMale.value == self.user.genderType().value {
            pictureImageView.image = UIImage(named: "random_user")
        } else if kSMBUserGenderFemale.value == self.user.genderType().value {
            pictureImageView.image = UIImage(named: "random_user")
        } else {
            pictureImageView.image = UIImage(named: "random_user")
        }
        
        
        pictureImageView.image = UIImage(named: "random_user")
        pictureImageView.layer.cornerRadius = pictureImageView.frame.width/2
        pictureImageView.layer.masksToBounds = true
        pictureImageView.transform = CGAffineTransformMakeScale(0.95, 0.95)
        imageContainerView.addSubview(pictureImageView)
        
        let prefImageView = UIImageView(frame: CGRectMake(pictureImageView.frame.width-33, 0, 33, 33))
        prefImageView.backgroundColor = UIColor.simbiBlackColor()
        prefImageView.image = UIImage(named: "1st_pref")
        prefImageView.layer.cornerRadius = prefImageView.frame.width/2
        prefImageView.layer.masksToBounds = true
        imageContainerView.addSubview(prefImageView)
        
        self.addSubview(imageContainerView)
        
        
        circleView.frame = imageContainerView.frame
        circleView.backgroundColor = UIColor.simbiWhiteColor()
        circleView.layer.cornerRadius = circleView.frame.width/2
        circleView.transform = CGAffineTransformMakeScale(0.95, 0.95)
        self.insertSubview(circleView, belowSubview: imageContainerView)
        
        
        nameLabel.frame = CGRectMake(
            imageContainerView.frame.origin.x+imageContainerView.frame.width+16, 0,
            self.frame.width-176-20, 44
        )
        nameLabel.center = CGPointMake(nameLabel.center.x, self.frame.height/2)
        nameLabel.text = user.firstName
        nameLabel.textColor = UIColor.simbiBlackColor()
        nameLabel.font = UIFont.simbiFontWithSize(22)
        nameLabel.alpha = 1
        self.addSubview(nameLabel)
        nameLabel.frame = CGRectMake(
            imageContainerView.frame.origin.x+imageContainerView.frame.width+16, 0+22,
            self.frame.width-176-20, 44
        )
        
        interestLabel.frame = CGRectMake(
            imageContainerView.frame.origin.x+imageContainerView.frame.width+16, 0,
            self.frame.width-176-20, 44
        )
        var sharedCount = 0
        
        let currentusr = SMBUser.currentUser()
        if (currentusr != nil && currentusr.tags != nil){
            for tag in SMBUser.currentUser().tags{
                println(tag)
                if user.tags.indexOfObject(tag) != NSNotFound {
                    sharedCount++
                }
            }
        }
        interestLabel.text = NSString(format: "%d Shared Interest", sharedCount) as String
        interestLabel.textColor = UIColor.simbiBlackColor()
        interestLabel.font = UIFont.simbiFontWithSize(16)
        interestLabel.alpha = 0.5
        self.addSubview(interestLabel)
        self.interestLabel.center = CGPointMake(interestLabel.center.x, self.frame.height/2-10)
        
        distanceLabel.frame = CGRectMake(
            imageContainerView.frame.origin.x+imageContainerView.frame.width+16, 0,
            self.frame.width-176-20, 44
        )
        self.distanceLabel.center = CGPointMake(interestLabel.center.x, self.frame.height/2+22)
        //var dis = 0.0
        var dis = self.user.geoPoint.distanceInMilesTo(SMBUser.currentUser().geoPoint)
        var disText = ""
        if dis<0.01{
            disText = NSString(format: "%.2f ft",dis*5280) as String
        }else{
            disText = NSString(format: "%.2f miles",dis) as String
        }
        distanceLabel.text = disText
        distanceLabel.textColor = UIColor.simbiBlackColor()
        distanceLabel.font = UIFont.simbiFontWithSize(20)
        distanceLabel.alpha = 0.5
        self.addSubview(distanceLabel)
        
        
        buttonContainerView.frame = CGRectMake(nameLabel.frame.origin.x, 0, nameLabel.frame.width, 44)
        buttonContainerView.center = CGPointMake(self.frame.width, self.frame.height/2+22)
        buttonContainerView.alpha = 0
        
        let questionButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        questionButton.backgroundColor = UIColor.simbiLightGrayColor()
        questionButton.setImage(UIImage(named: "chat_icon"), forState: .Normal)
        questionButton.layer.cornerRadius = questionButton.frame.width/2
        questionButton.layer.borderWidth = 1
        questionButton.layer.borderColor = UIColor.simbiBlueColor().CGColor
        questionButton.addTarget(self, action: "questionAction:", forControlEvents: .TouchUpInside)
        buttonContainerView.addSubview(questionButton)
        
        let challengeButton = UIButton(frame: CGRectMake(44+12, 0, 44, 44))
        challengeButton.backgroundColor = UIColor.simbiLightGrayColor()
        challengeButton.setImage(UIImage(named: "challenge_icon"), forState: .Normal)
        challengeButton.layer.cornerRadius = questionButton.frame.width/2
        challengeButton.layer.borderWidth = 1
        challengeButton.layer.borderColor = UIColor.simbiRedColor().CGColor
        challengeButton.addTarget(self, action: "challengeAction:", forControlEvents: .TouchUpInside)
        buttonContainerView.addSubview(challengeButton)
        
        self.addSubview(buttonContainerView)
    }
    
    
    // MARK: - User Actions
    
    func questionAction(sender: AnyObject) {
        delegate?.itemViewDidSelectUserForQuestion(self, user: user)
    }
    
    
    func challengeAction(sender: AnyObject) {
        delegate?.itemViewDidSelectUserForChallenge(self, user: user)
    }
    
    
    // MARK: - Public Methods
    func viewTapped(sender: UITapGestureRecognizer?){
        println("img clicked")
    }

    func fadeIn() {
        
        if isFaded {
            isFaded = false
            
            buttonContainerView.hidden = false
        
            UIView.animateWithDuration(0.33, animations: { () -> Void in
                
                self.imageContainerView.transform = CGAffineTransformMakeScale(1, 1)
                self.circleView.transform = CGAffineTransformMakeScale(1, 1)
                
                self.imageContainerView.alpha = 1
                self.nameLabel.alpha = 1
                self.interestLabel.alpha=0
                self.distanceLabel.alpha=0
                self.buttonContainerView.alpha = 1
                
                //self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.frame.height/2-22)
                self.buttonContainerView.center = CGPointMake(self.nameLabel.center.x, self.buttonContainerView.center.y)
                
            }) { (Bool) -> Void in
                
            }
        }
    }
    
    
    func fadeOut() {
        
        if !isFaded {
            isFaded = true
            
            UIView.animateWithDuration(0.33, animations: { () -> Void in
                
                self.imageContainerView.transform = CGAffineTransformMakeScale(0.95, 0.95)
                self.circleView.transform = CGAffineTransformMakeScale(0.95, 0.95)
                
                self.imageContainerView.alpha = 0.5
                self.nameLabel.alpha = 1
                self.interestLabel.alpha=1
                self.distanceLabel.alpha=1
                self.buttonContainerView.alpha = 0
                
                //self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.frame.height/2)
                self.buttonContainerView.center = CGPointMake(self.frame.width, self.buttonContainerView.center.y)
                
            }) { (Bool) -> Void in
                
                if self.isFaded {
                    self.buttonContainerView.hidden = true
                }
            }
        }
    }
}
