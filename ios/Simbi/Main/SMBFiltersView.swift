//
//  CoreView.swift
//  JustaDemo
//
//  Created by zhaohy@ifeng on 7/22/15.
//  Copyright (c) 2015 ifeng. All rights reserved.
//

import UIKit


class SMBFiltersView: UIView {

    //MARK:
    //MARK: properties
   
    @IBOutlet weak var showSegment: UISegmentedControl!
    @IBOutlet weak var visibilitySegment: UISegmentedControl!

    @IBOutlet weak var makefriendsBtn: UIButton!
    @IBOutlet weak var networkBtn: UIButton!
    @IBOutlet weak var datingBtn: UIButton!
   
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var ageRangeView: UIView!

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
        showSegment.selectedSegmentIndex = 1
        
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
        
        makefriendsBtnWidth.constant = (self.frame.width - 32 - 29) / 3 + 10
        networkBtnWidth.constant = (self.frame.width - 32 - 29) / 3 + 2
        datingBtnWidth.constant = (self.frame.width - 32 - 29) / 3 - 2
    
        datingBtn.backgroundColor = UIColor(red: 107/256, green: 167/256, blue: 249/256, alpha: 1)
        datingBtn.backgroundColor = UIColor.whiteColor()
        
        
        //ageSliderView
        println(ageRangeView.frame)
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
    }
    
    
    @IBAction func showSegmentValueChanged(sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            makefriendsBtn.enabled = false
            datingBtn.enabled = false
            networkBtn.enabled = false
            genderSegment.enabled = false
            
        } else {
            makefriendsBtn.enabled = true
            datingBtn.enabled = true
            networkBtn.enabled = true
            genderSegment.enabled = true
        }
    }
    

    @IBAction func cancelBtnAction(sender: AnyObject) {
        self.removeFromSuperview()
    }

    @IBAction func searchBtnAction(sender: AnyObject) {
    }
}
