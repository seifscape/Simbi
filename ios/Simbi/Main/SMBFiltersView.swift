//
//  CoreView.swift
//  JustaDemo
//
//  Created by zhaohy@ifeng on 7/22/15.
//  Copyright (c) 2015 ifeng. All rights reserved.
//

import UIKit

protocol SMBFiltersDelegate {
    func searchFriend()
    func searchEveryone()
}

class SMBFiltersView: UIView {

    var isShowing: Bool?
    var delegateForSearch: SMBFiltersDelegate?
    
    //MARK:
    //MARK: properties
   
    @IBOutlet weak var showSegment: UISegmentedControl!
    
    @IBOutlet weak var makefriendsBtn: UIButton!
    @IBOutlet weak var networkBtn: UIButton!
    @IBOutlet weak var datingBtn: UIButton!
   
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var ageRangeView: UIView!

    @IBOutlet weak var visibilitySegment: UISegmentedControl!

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    
    
    //MARK:
    //MARK: constraints
    
    @IBOutlet weak var makefriendsBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var networkBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var datingBtnWidth: NSLayoutConstraint!
    
    var ageRangeSlider: NMRangeSlider?
    
    
    //MARK:
    //MARK: functions
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        makeupUI()
    }
    
   
    func makeupUI() {

        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3
        
        //segment
        visibilitySegment.selectedSegmentIndex = SMBUser.currentUser().visible ? 0 : 1
        genderSegment.selectedSegmentIndex = SMBUser.currentUser().genderPreferenceType().value
    
        //buttons
        makefriendsBtn.layer.borderWidth = 1
        makefriendsBtn.layer.cornerRadius = 3
        makefriendsBtn.layer.borderColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 1).CGColor
        makefriendsBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        makefriendsBtn.addTarget(self, action: "buttonSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        
        networkBtn.layer.borderWidth = 1
        networkBtn.layer.cornerRadius = 3
        networkBtn.layer.borderColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 1).CGColor
        networkBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        networkBtn.addTarget(self, action: "buttonSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        
        datingBtn.layer.borderWidth = 1
        datingBtn.layer.cornerRadius = 0
        datingBtn.layer.borderColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 1).CGColor
        datingBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        datingBtn.addTarget(self, action: "buttonSelected:", forControlEvents: UIControlEvents.TouchUpInside)
        
        makefriendsBtnWidth.constant = (self.frame.width - 30 - 30) / 3 + 10
        networkBtnWidth.constant = (self.frame.width - 30 - 30) / 3 + 2
        datingBtnWidth.constant = (self.frame.width - 30 - 30) / 3 - 2
    
//        datingBtn.backgroundColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 1)
//        datingBtn.backgroundColor = UIColor.whiteColor()
      
        //load lookingto status
        var lookingto :[Bool]? = SMBUser.currentUser().lookingto as? [Bool]
        if lookingto != nil {
            makefriendsBtn.selected = lookingto![0]
            datingBtn.selected = lookingto![1]
            networkBtn.selected = lookingto![2]
            
            if makefriendsBtn.selected {
                makefriendsBtn.backgroundColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 1)
            } else {
                makefriendsBtn.backgroundColor = UIColor.whiteColor()
            }
            
            if datingBtn.selected {
                datingBtn.backgroundColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 1)
            } else {
                datingBtn.backgroundColor = UIColor.whiteColor()
            }
            
            if networkBtn.selected {
                networkBtn.backgroundColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 1)
            } else {
                networkBtn.backgroundColor = UIColor.whiteColor()
            }
            
        } else {
            makefriendsBtn.backgroundColor = UIColor.whiteColor()
            datingBtn.backgroundColor = UIColor.whiteColor()
            networkBtn.backgroundColor = UIColor.whiteColor()
        }
        
        
        
        //ageSliderView
        ageRangeSlider = NMRangeSlider(frame: CGRect(x: 0, y: 0, width: ageRangeView.frame.size.width, height: ageRangeView.frame.size.height))
        ageRangeSlider?.minimumValue = 18
        ageRangeSlider?.maximumValue = 55
        ageRangeSlider?.minimumRange = 1
        ageRangeSlider?.upperValue = Float(SMBUser.currentUser().upperAgePreference.intValue)
        // If lower age preference is greater than or equal to the upper, set upper as just above the lower.
        if SMBUser.currentUser().lowerAgePreference.intValue >= SMBUser.currentUser().upperAgePreference.intValue {
            ageRangeSlider?.upperValue = Float(SMBUser.currentUser().lowerAgePreference.intValue+1)
        }
        ageRangeSlider?.lowerValue = Float(SMBUser.currentUser().lowerAgePreference.intValue)
        ageRangeSlider?.tintColor = UIColor.simbiBlueColor()
//        ageRangeSlider?.addTarget(self, action: "", forControlEvents: UIControlEvents.ValueChanged)
   
        ageRangeView.addSubview(ageRangeSlider!)
        
    }

    //MARK: actions
    func buttonSelected(button: UIButton) {
        
        button.selected = !button.selected
        
        if button.selected == true {
            button.backgroundColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 1)
        } else {
            button.backgroundColor = UIColor.whiteColor()
        }
        
        
        //save
        SMBUser.currentUser().lookingto = Array(arrayLiteral: makefriendsBtn.selected, datingBtn.selected, networkBtn.selected)
        SMBUser.currentUser().saveInBackgroundWithBlock(nil)
    }
    
    
    @IBAction func showSegmentValueChanged(sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            makefriendsBtn.enabled = false
            datingBtn.enabled = false
            networkBtn.enabled = false
            genderSegment.enabled = false
            
            makefriendsBtn.layer.opacity = 0.5
            datingBtn.layer.opacity = 0.5
            networkBtn.layer.opacity = 0.5
            
        } else {
            makefriendsBtn.enabled = true
            datingBtn.enabled = true
            networkBtn.enabled = true
            genderSegment.enabled = true
            
            makefriendsBtn.layer.opacity = 1
            datingBtn.layer.opacity = 1
            networkBtn.layer.opacity = 1
        }
    }
    
    @IBAction func visibilitySegmentValueChanged(sender: AnyObject) {

        SMBUser.currentUser().visible = sender.selectedSegmentIndex == 0 ? true : false
        SMBUser.currentUser().saveInBackgroundWithBlock(nil)
    }
    
    
    @IBAction func genderSegmentValueChanged(sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            SMBUser.currentUser().setGenderPreferenceType(kSMBUserGenderMale)
        } else if sender.selectedSegmentIndex == 1 {
            SMBUser.currentUser().setGenderPreferenceType(kSMBUserGenderFemale)
        } else {
            SMBUser.currentUser().setGenderPreferenceType(kSMBUserGenderOther)
        }
        
        SMBUser.currentUser().saveInBackgroundWithBlock(nil)
    
    }
    
    
    
    @IBAction func cancelBtnAction(sender: AnyObject) {
        self.removeFromSuperview()
        isShowing = false
    }

    @IBAction func searchBtnAction(sender: AnyObject) {
        
        if showSegment.selectedSegmentIndex == 0 {
            self.delegateForSearch?.searchFriend()
        } else {
            
        }
        
        self.removeFromSuperview()
        isShowing = false
    }
    
    
}
