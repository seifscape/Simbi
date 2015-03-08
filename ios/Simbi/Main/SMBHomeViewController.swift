//
//  SMBHomeViewController.swift
//  Simbi
//
//  Created by flynn on 10/8/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


protocol SMBHomeViewDelegate {
    
    func homeView(homeView: SMBHomeViewController, didSelectUserFromFriendsList user:SMBUser)
}


enum SMBHomeViewAlertType: Int {
    case ProfilePicture, CheckIn
}


class SMBHomeViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate{
    weak var parent: SMBMainViewController?
    var delegate: SMBHomeViewDelegate?
    
    let ethnicityArray = ["Caucasian","African American", "Latino", "East Asian", "South Asian", "Pacific Islander", "Middle Eastern","Native American"]
    let ethnicityPickerView = UIPickerView()
    
    let ageArray = ["18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","50"]
    let agePickerView =  UIPickerView()
    
    let heightArray = ["5’"," 5’1\""," 5’2\""," 5’3\""," 5’4\"","5’5\""," 5’6\""," 5’7\"","5’8\"","5’9\"","5’10\"","5’11\"","5’12\"","6’0\"","6’1\""," 6’2\"","6’3\"","6’4\"","6’5\"","6’6\"","6’7\"","6’8\"","6’9\"","6’10\""," 6’11\"","6’12\"",">7’"]
    
    let tagsArray = ["Foodie","Wino","Beer Connoisseur","World Trekker","Early Bird","Night Owl","Entertainer","Wizard","Wordsmith","Cinephile","Book Worm","Technologist","Disco Disco!","Sports Junkie","#iworkout","Cyclist","Beach Bum","Thrill Seeker","Outdoorsmen","Politics"," Sure.","Satirist","Health Nut","Animal Lover","Guy Fieri Fan"]
    let meetUpTimeArray = ["Morning","Noon","Lunch","Mid Afternoon","Early Dinner","Happy Hour","Late Night","Anytime"]
    
    let meetUpLocationsArray = ["Coffee Shop","Bar/Lounge","Restaurant","Late Night","Museum","Art Gallery","Outdoor Fun","Anytime"]
    
    let degreeArray = ["Phd","Master","MD","JD","MBA","Bachelors","Highschool","Other"]
    let heightPickerView = UIPickerView()
    
    let homeBackgroundView  = SMBHomeBackgroundView()
    let userInfoView        = UIView()
    let scrollInfoView = UIScrollView()
    let profilePictureView  = SMBImageView()
    
    let nameLabel           = UILabel()
    let locationLabel       = UILabel()
    let scrollFadeView      = UIView()
    
    let ageLabel = UILabel()
    let heightLabel = UILabel()
    let ethnicityLabel = UILabel()
    let ethnicityEditLabel = UILabel()
    let aboutmeLabel = UILabel()
    let occupationLabel = UILabel()
    let educationLabel = UILabel()
    let meetupLocationsLabel = UILabel()
    let meetupTimeLabel = UILabel()
    let tagsLabel = UILabel()
    
    let ageEdit = UITextField()
    let heightEdit = UITextField()
    let aboutEdit = UITextField()
    let occupationEdit = UITextField()
    let educationEdit = UITextField()
    
    let ageButton = UIButton()
    let heightButton = UIButton()
    let ethnicityButton = UIButton()
    let saveButton = UIButton()
    var activityDrawerView: SMBActivityDrawerView?
    
    // MARK: - ViewController Lifecycle
    
    override convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.simbiBlueColor()
        self.view.clipsToBounds = true
        // Set up views.
        homeBackgroundView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        homeBackgroundView.userInteractionEnabled = false
        //self.view.addSubview(homeBackgroundView)
        
        //set the scroll view
        self.scrollInfoView.contentSize.height = 2000
        self.scrollInfoView.contentSize.width = self.view.frame.width
        self.scrollInfoView.frame.size.width = self.view.frame.width
        self.scrollInfoView.frame.size.height = self.view.frame.height-20
        self.scrollInfoView.frame.origin.x = 0
        self.scrollInfoView.frame.origin.y = 0
        self.view.addSubview(self.scrollInfoView)

//        userInfoView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.width-88)
//        userInfoView.center = self.view.center
//        userInfoView.autoresizingMask = .FlexibleTopMargin
        
        
        profilePictureView.frame = CGRectMake(66, 50, self.view.frame.width-132, self.view.frame.width-132)
        profilePictureView.backgroundColor = UIColor.simbiBlackColor()
        profilePictureView.userInteractionEnabled = false
        profilePictureView.layer.cornerRadius = profilePictureView.frame.width/2
        profilePictureView.layer.masksToBounds = true
        profilePictureView.layer.borderWidth = 1
        profilePictureView.layer.borderColor = UIColor.simbiWhiteColor().CGColor
        profilePictureView.layer.shadowColor = UIColor.blackColor().CGColor
        profilePictureView.layer.shadowRadius = 2
        profilePictureView.layer.shadowOpacity = 0.5
        self.scrollInfoView.addSubview(profilePictureView)
        
        let profilePictureButton = UIButton(frame: CGRectInset(profilePictureView.frame, 20, 20))
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.width/2
        profilePictureButton.addTarget(self, action: "pinLocationAction:", forControlEvents: .TouchUpInside)
        scrollInfoView.addSubview(profilePictureButton)
        
        let profilePictureRingView = UIView(frame: CGRectMake(0, 0, self.view.frame.width-110, self.view.frame.width-110))
        profilePictureRingView.center = profilePictureView.center
        profilePictureRingView.backgroundColor = UIColor(white: 1, alpha: 0.33)
        profilePictureRingView.layer.cornerRadius = profilePictureRingView.frame.width/2
        profilePictureRingView.userInteractionEnabled = false
        scrollInfoView.insertSubview(profilePictureRingView, belowSubview: profilePictureView)

        
        nameLabel.frame = CGRectMake(0, profilePictureView.frame.height+58, self.view.frame.width, 44)
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont.simbiFontWithAttributes(kFontLight, size: 32)
        nameLabel.textAlignment = .Center
        nameLabel.layer.shadowColor = UIColor.blackColor().CGColor
        nameLabel.layer.shadowOpacity = 0.25
        nameLabel.layer.shadowRadius = 1
        nameLabel.layer.shadowOffset = CGSizeMake(1, 1)
        nameLabel.userInteractionEnabled = false
        scrollInfoView.addSubview(nameLabel)
        
        nameLabel.textColor = UIColor.redColor()
        
        locationLabel.frame = CGRectMake(0, nameLabel.frame.origin.y+28, self.view.frame.width, 44)
        locationLabel.textColor = UIColor.whiteColor()
        locationLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 16)
        locationLabel.textAlignment = .Center
        locationLabel.layer.shadowColor = UIColor.blackColor().CGColor
        locationLabel.layer.shadowOpacity = 0.25
        locationLabel.layer.shadowRadius = 1
        locationLabel.layer.shadowOffset = CGSizeMake(1, 1)
        locationLabel.userInteractionEnabled = false
        scrollInfoView.addSubview(locationLabel)
        
        self.view.addSubview(userInfoView)
        
        
        activityDrawerView = SMBActivityDrawerView(frame: CGRectMake(0, self.view.frame.height-44, self.view.frame.width, self.view.frame.height-self.view.frame.width), delegate: self)
        self.view.addSubview(activityDrawerView!)
        
        
        // Overlaid view that fades to black as the user swipes to the side.
        scrollFadeView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scrollFadeView.backgroundColor = UIColor.blackColor()
        scrollFadeView.alpha = 0
        scrollFadeView.userInteractionEnabled = false
        self.view.insertSubview(scrollFadeView, belowSubview: activityDrawerView!)
   
        //add labels
        ageLabel.textColor = UIColor.simbiWhiteColor()
        heightLabel.textColor = UIColor.simbiWhiteColor()
        ethnicityLabel.textColor = UIColor.simbiWhiteColor()
        aboutmeLabel.textColor = UIColor.simbiWhiteColor()
        occupationLabel.textColor = UIColor.simbiWhiteColor()
        educationLabel.textColor = UIColor.simbiWhiteColor()
        meetupLocationsLabel.textColor = UIColor.simbiWhiteColor()
        meetupTimeLabel.textColor = UIColor.simbiWhiteColor()
        tagsLabel.textColor = UIColor.simbiWhiteColor()
        
        ageLabel.text = "Age"
        ageLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        heightLabel.text = "Height"
        heightLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        ethnicityLabel.text = "Ethnicity"
        ethnicityLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        aboutmeLabel.text = "About Me"
        aboutmeLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        occupationLabel.text = "Occupation"
        occupationLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        educationLabel.text = "Education"
        educationLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        meetupLocationsLabel.text = "Meet Up Locations"
        meetupLocationsLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        meetupTimeLabel.text = "Meet Up Time"
        meetupTimeLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        tagsLabel.text = "Tags"
        tagsLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        
        ageLabel.frame.size = CGSize(width: 100, height: 30)
        ageLabel.frame.origin = CGPoint(x:20,y:300)
        heightLabel.frame.size = CGSize(width: 100, height: 30)
        heightLabel.frame.origin = CGPoint(x:self.view.frame.width/2+20,y:300)
        ethnicityLabel.frame.size = CGSize(width: 200, height: 30)
        ethnicityLabel.frame.origin = CGPoint(x:20,y:340)
        aboutmeLabel.frame.size = CGSize(width: 200, height: 30)
        aboutmeLabel.frame.origin = CGPoint(x:20,y:380)
        occupationLabel.frame.size = CGSize(width: 200, height: 30)
        occupationLabel.frame.origin = CGPoint(x:20,y:500)
        educationLabel.frame.size = CGSize(width: 200, height: 30)
        educationLabel.frame.origin = CGPoint(x:20,y:540)
        meetupLocationsLabel.frame.size = CGSize(width: 200, height: 30)
        meetupLocationsLabel.frame.origin = CGPoint(x:20,y:580)
        meetupTimeLabel.frame.size = CGSize(width: 200, height: 30)
        meetupTimeLabel.frame.origin = CGPoint(x:20,y:680)
        tagsLabel.frame.size = CGSize(width: 200, height: 30)
        tagsLabel.frame.origin = CGPoint(x:20,y:780)
        
        
        
        self.scrollInfoView.addSubview(ageLabel)
        self.scrollInfoView.addSubview(heightLabel)
        self.scrollInfoView.addSubview(ethnicityLabel)
        self.scrollInfoView.addSubview(aboutmeLabel)
        self.scrollInfoView.addSubview(occupationLabel)
        self.scrollInfoView.addSubview(educationLabel)
        self.scrollInfoView.addSubview(meetupLocationsLabel)
        self.scrollInfoView.addSubview(meetupTimeLabel)
        self.scrollInfoView.addSubview(tagsLabel)
        
        ageButton.tag = 150
        ageButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.allZeros)
        ageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        ageButton.setTitle("age",forState:UIControlState.allZeros)
        ageButton.frame.size = CGSize(width: 50,height: 30)
        ageButton.frame.origin = CGPoint(x: 60,y: 305)
        ageButton.addTarget(self, action:"selectButtonDown:", forControlEvents: UIControlEvents.TouchDown)
        
        heightButton.tag = 151
        heightButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.allZeros)
        
        heightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        heightButton.setTitle("height",forState:UIControlState.allZeros)
        heightButton.frame.size = CGSize(width: 50,height: 30)
        heightButton.frame.origin = CGPoint(x: self.view.frame.width/2+88,y: 305)
        heightButton.addTarget(self, action:"selectButtonDown:", forControlEvents: UIControlEvents.TouchDown)

        ethnicityButton.tag = 152
        ethnicityButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.allZeros)
        ethnicityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        ethnicityButton.setTitle("ethnicity",forState:UIControlState.allZeros)
        ethnicityButton.frame.size = CGSize(width: 200,height: 30)
        ethnicityButton.frame.origin = CGPoint(x:125,y: 342)
        ethnicityButton.addTarget(self, action:"selectButtonDown:", forControlEvents: UIControlEvents.TouchDown)
        
        aboutEdit.frame.size = CGSize(width: self.view.frame.width-40, height: 80)
        aboutEdit.frame.origin = CGPoint(x: 20, y: 410)
        aboutEdit.backgroundColor = UIColor.whiteColor()
        aboutEdit.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        aboutEdit.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        //add meet up location
        var locationIndex:Int = 0
        var locationButtonWidth:Int = 80
        var locationButtonHeight:Int = 20
        var numberperRow:Int = (Int(self.view.frame.width)-40)/(locationButtonWidth+10)
        for location in self.meetUpLocationsArray{
            let button = UIButton()
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            button.frame.size = CGSize(width: locationButtonWidth, height: locationButtonHeight)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            var buttonX = (locationIndex)%numberperRow*(locationButtonWidth+10)+20
            var buttonY = Int(meetupLocationsLabel.frame.origin.y+meetupLocationsLabel.frame.size.height)+(locationButtonHeight+5)*((locationIndex)/numberperRow)
            button.frame.origin = CGPoint(x: buttonX, y: buttonY)
            button.setTitle(location, forState:UIControlState.allZeros)
            button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
            button.backgroundColor = UIColor.whiteColor()
            self.scrollInfoView.addSubview(button)
            button.addTarget(self, action: "blockButtonDown:", forControlEvents: UIControlEvents.TouchDown)
            locationIndex++
        }
        //add meet up time
        var timeIndex:Int = 0
        var timeButtonWidth:Int = 80
        var timeButtonHeight:Int = 20
        var timeNumberperRow:Int = (Int(self.view.frame.width)-40)/(timeButtonWidth+10)
        for location in self.meetUpTimeArray{
            let button = UIButton()
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            button.frame.size = CGSize(width: timeButtonWidth, height: timeButtonHeight)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            var buttonX = (timeIndex)%timeNumberperRow*(timeButtonWidth+10)+20
            var buttonY = Int(meetupTimeLabel.frame.origin.y+meetupTimeLabel.frame.size.height)+(timeButtonHeight+5)*((timeIndex)/timeNumberperRow)
            button.frame.origin = CGPoint(x: buttonX, y: buttonY)
            button.setTitle(location, forState:UIControlState.allZeros)
            button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
            button.backgroundColor = UIColor.whiteColor()
            self.scrollInfoView.addSubview(button)
            button.addTarget(self, action: "blockButtonDown:", forControlEvents: UIControlEvents.TouchDown)
            timeIndex++
        }
        //add tags
        var tagsIndex:Int = 0
        var tagsButtonWidth:Int = 80
        var tagsButtonHeight:Int = 20
        var tagsNumberperRow:Int = (Int(self.view.frame.width)-40)/(tagsButtonWidth+10)
        for location in self.tagsArray{
            let button = UIButton()
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            button.frame.size = CGSize(width: tagsButtonWidth, height: tagsButtonHeight)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            var buttonX = (tagsIndex)%tagsNumberperRow*(tagsButtonWidth+10)+20
            var buttonY = Int(tagsLabel.frame.origin.y+tagsLabel.frame.size.height)+(tagsButtonHeight+5)*((tagsIndex)/tagsNumberperRow)
            button.frame.origin = CGPoint(x: buttonX, y: buttonY)
            button.setTitle(location, forState:UIControlState.allZeros)
            button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
            button.backgroundColor = UIColor.whiteColor()
            self.scrollInfoView.addSubview(button)
            button.addTarget(self, action: "blockButtonDown:", forControlEvents: UIControlEvents.TouchDown)
            tagsIndex++
        }
        //ethnicity select
        ethnicityPickerView.delegate = self
        ethnicityPickerView.frame.size = CGSize(width: 300, height: 500)
        ethnicityPickerView.center = self.view.center
        ethnicityPickerView.tag = 100
        ethnicityPickerView.hidden = true
        ethnicityPickerView.backgroundColor = UIColor.whiteColor()
        
        agePickerView.delegate = self
        agePickerView.frame.size = CGSize(width: 300, height: 500)
        agePickerView.center = self.view.center
        agePickerView.tag = 101
        agePickerView.hidden = true
        agePickerView.backgroundColor = UIColor.whiteColor()
        
        heightPickerView.delegate = self
        heightPickerView.frame.size = CGSize(width: 300, height: 500)
        heightPickerView.center = self.view.center
        heightPickerView.tag = 102
        heightPickerView.hidden = true
        heightPickerView.backgroundColor = UIColor.whiteColor()
        
        
        self.scrollInfoView.addSubview(ageButton)
        self.scrollInfoView.addSubview(heightButton)
        self.scrollInfoView.addSubview(ethnicityButton)
        self.scrollInfoView.addSubview(aboutEdit)
        
        
        self.view.addSubview(ethnicityPickerView)
        self.view.addSubview(agePickerView)
        self.view.addSubview(heightPickerView)
        //add tap gesture
        var tapGr:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:"viewTapped:")
        tapGr.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGr)
    }
    func selectButtonDown(sender:UIButton){
        //age set button
        if sender.tag == 150{
            self.agePickerView.hidden = false
        }
        if sender.tag == 151{
            self.heightPickerView.hidden = false
        }
        if sender.tag == 152{
            self.ethnicityPickerView.hidden = false
        }
        
    }
    func blockButtonDown(sender:UIButton){
        sender.selected = !sender.selected
    }
    func viewTapped(sender: UITapGestureRecognizer?){
        self.view.endEditing(true)
        self.agePickerView.hidden = true
        self.heightPickerView.hidden = true
        self.ethnicityPickerView.hidden = true
        
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 100{
            return ethnicityArray.count
        }
        if pickerView.tag == 101{
            return ageArray.count
        }
        if pickerView.tag == 102 {
            return heightArray.count
        }
        return 0
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 100{
            return ethnicityArray[row]
        }
        if pickerView.tag == 101{
            return ageArray[row]
        }
        if pickerView.tag == 102{
            return heightArray[row]
        }
        return ""
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 100{
           ethnicityButton.setTitle(ethnicityArray[row], forState: UIControlState.allZeros)
        }
        if pickerView.tag == 101{
            ageButton.setTitle(ageArray[row], forState: UIControlState.allZeros)
        }
        if pickerView.tag == 102{
            heightButton.setTitle(heightArray[row], forState: UIControlState.allZeros)
        }

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityDrawerView!.frame = CGRectMake(
            0,
            self.view.frame.height-44,
            self.view.frame.width,
            self.view.frame.height-self.view.frame.width
        )
        
        if SMBUser.exists() {
            homeBackgroundView.updateFilteredProfilePicture()
            profilePictureView.setParseImage(SMBUser.currentUser().profilePicture, withType: kImageTypeMediumSquare)
            nameLabel.text = SMBUser.currentUser().name
            locationLabel.text = SMBUser.currentUser().cityAndState()
        }
        else {
            profilePictureView.image = nil
        }
    }
    
    
    // MARK: - User Actions
    
    func pinLocationAction(sender: AnyObject) {
        
        parent!.view.userInteractionEnabled = false
        
        let coverView = UIView(frame: CGRectMake(0, 0, profilePictureView.frame.width, profilePictureView.frame.height))
        coverView.backgroundColor = UIColor.simbiLightGrayColor()
        coverView.layer.cornerRadius = coverView.frame.width/2
        coverView.alpha = 0
        profilePictureView.addSubview(coverView)
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            
            self.profilePictureView.transform = CGAffineTransformMakeScale(-1, 1);
            coverView.alpha = 1
            
        }) { (Bool) -> Void in
            
            self.parent!.viewWillDisappear(true)
            
            let topLevelCoverView = UIView(frame: CGRectMake(0, 0, coverView.frame.width, coverView.frame.height))
            topLevelCoverView.center = coverView.superview!.convertPoint(coverView.center, toView: nil)
            topLevelCoverView.backgroundColor = UIColor.simbiLightGrayColor()
            topLevelCoverView.layer.cornerRadius = coverView.frame.width/2
            self.parent!.view.addSubview(topLevelCoverView)
            
            coverView.removeFromSuperview()
            
            let navigationController = UINavigationController(rootViewController: SMBPinLocationViewController())
            navigationController.view.backgroundColor = navigationController.visibleViewController.view.backgroundColor
            navigationController.setNavigationBarHidden(true, animated: false)
            
            self.parent!.navigationController!.presentViewControllerByGrowingView(navigationController, growingView: topLevelCoverView)
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 666_666_666), dispatch_get_main_queue(), { () -> Void in
                
                navigationController.setNavigationBarHidden(false, animated: true)
                topLevelCoverView.removeFromSuperview()
                self.profilePictureView.transform = CGAffineTransformMakeScale(1, 1)
                
                self.parent!.view.userInteractionEnabled = true
            })
        }
    }
    
    
    func swipeControlDidBeginTouch(sender: AnyObject) {
        parent!.scrollView.scrollEnabled = false
    }
    
    
    func swipeControlDidEndTouch(sender: AnyObject) {
        parent!.scrollView.scrollEnabled = true
    }
}


// MARK: - SMBActivitiyDrawerDelegate

extension SMBHomeViewController: SMBActivityDrawerDelegate {
    
    func activityDrawerDidSelectUser(user: SMBUser!) {
        
        if let delegate = self.delegate {
            self.view.endEditing(true)
            delegate.homeView(self, didSelectUserFromFriendsList: user)
        }
    }
    
    
    func toggleActivityDrawer() {
        
        self.view.endEditing(true)
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        let activityHeight = activityDrawerView!.frame.height
        
        if activityDrawerView!.frame.origin.y < height-44 {
            
            UIView.animateWithDuration(0.33, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                
                self.activityDrawerView!.frame = CGRectMake(0, height-44, width, activityHeight)
//                self.homeBackgroundView.frame = CGRectMake(0, 0, width, height)
                self.userInfoView.center = CGPointMake(width/2, height/2)
                
            }, completion: nil)
        }
        else {
            
            UIView.animateWithDuration(0.33, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                
                self.activityDrawerView!.frame = CGRectMake(0, height-activityHeight, width, activityHeight)
//                self.homeBackgroundView.frame = CGRectMake(0, 0, width, height-activityHeight+44)
                self.userInfoView.center = CGPointMake(width/2, (height-activityHeight+44)/2)
                
            }, completion: nil)
        }
    }
}


// MARK: - SMBSplitViewChild

extension SMBHomeViewController: SMBSplitViewChild {
    
    func splitViewDidScroll(splitView: SMBSplitViewController, position: CGFloat) {
        
        homeBackgroundView.frame = CGRectMake(position/2, 0, homeBackgroundView.frame.width, homeBackgroundView.frame.height)
        scrollFadeView.alpha = abs(position)/(3*self.view.frame.width)
    }
}
