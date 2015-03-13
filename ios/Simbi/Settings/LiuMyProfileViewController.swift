//
//  LiuMyProfileViewController.swift
//  Simbi
//
//  Created by apple on 3/9/15.
//  Copyright (c) 2015 SimbiSocial. All rights reserved.
//
import Foundation

@objc class LiuMyProfileViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate{
    weak var parent: SMBMainViewController?
    var delegate: SMBHomeViewDelegate?
    
    var currentUS:SMBUser = SMBUser()
    let genderArray = ["Male","Female"]
    let genderPickerView = UIPickerView()
    
    let ethnicityArray = ["Caucasian","African American", "Latino", "East Asian", "South Asian", "Pacific Islander", "Middle Eastern","Native American"]
    let ethnicityPickerView = UIPickerView()
    
    let ageArray = ["18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","50"]
    let agePickerView =  UIPickerView()
    
    let heightArray:NSArray = ["5’"," 5’1\""," 5’2\""," 5’3\""," 5’4\"","5’5\""," 5’6\""," 5’7\"","5’8\"","5’9\"","5’10\"","5’11\"","5’12\"","6’0\"","6’1\""," 6’2\"","6’3\"","6’4\"","6’5\"","6’6\"","6’7\"","6’8\"","6’9\"","6’10\""," 6’11\"","6’12\"",">7’"]
    let heightDoubleArray:NSArray = [5.0, 5.1, 5.2, 5.3, 5.4,5.5, 5.6, 5.7,5.8,5.9,5.10,5.11,5.12,6.0,6.1, 6.2,6.3,6.4,6.5,6.6,6.7,6.8,6.9,6.10, 6.11,6.12,7]
    
    let tagsArray = ["Foodie","Wino","Beer Connoisseur","World Trekker","Early Bird","Night Owl","Entertainer","Wizard","Wordsmith","Cinephile","Book Worm","Technologist","Disco Disco!","Sports Junkie","#iworkout","Cyclist","Beach Bum","Thrill Seeker","Outdoorsmen","Politics"," Sure.","Satirist","Health Nut","Animal Lover","Guy Fieri Fan"]
    
    var tagsSelectedArray:NSMutableArray = []
    let meetUpTimeArray = ["Morning","Noon","Lunch","Mid Afternoon","Early Dinner","Happy Hour","Late Night","Anytime"]
    var meetUpTimeSelectedArray:NSMutableArray = []
    
    let meetUpLocationsArray = ["Coffee Shop","Bar/Lounge","Restaurant","Late Night","Museum","Art Gallery","Outdoor Fun","Anytime"]
    var meetUpLocationsSelectedArray:NSMutableArray = []
    
    let degreePickerView = UIPickerView()
    let degreeArray = ["Phd","Master","MD","JD","MBA","Bachelors","Highschool","Other"]
    let heightPickerView = UIPickerView()
    
    let homeBackgroundView  = SMBHomeBackgroundView()
    let userInfoView        = UIView()
    let scrollInfoView = UIScrollView()
    let profilePictureView  = SMBImageView()
    
    let nameLabel           = UILabel()
    let locationLabel       = UILabel()
    let scrollFadeView      = UIView()
    
    let genderLabel = UILabel()
    let ageLabel = UILabel()
    
    let heightLabel = UILabel()
    let ethnicityLabel = UILabel()
    let ethnicityEditLabel = UILabel()
    let aboutmeLabel = UILabel()
    let occupationLabel = UILabel()
    let employerLabel = UILabel()
    let schoolLabel = UILabel()
    let degreeLabel = UILabel()
    let meetupLocationsLabel = UILabel()
    let meetupTimeLabel = UILabel()
    let tagsLabel = UILabel()
    
    let ageEdit = UITextField()
    let heightEdit = UITextField()
    let aboutEdit = UITextField()
    let occupationEdit = UITextField()
    let employerEdit = UITextField()
    //let employerEdit = UITextField()
    let schoolEdit = UITextField()
    
    let genderButton = UIButton()
    let ageButton = UIButton()
    let heightButton = UIButton()
    let ethnicityButton = UIButton()
    let degreeButton = UIButton()
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
        self.scrollInfoView.contentSize.height = 1180
        self.scrollInfoView.contentSize.width = self.view.frame.width
        self.scrollInfoView.frame.size.width = self.view.frame.width
        self.scrollInfoView.frame.size.height = self.view.frame.height
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
        //profilePictureView.rawImage = UIImage(named: "cobe.jpg")
        self.scrollInfoView.addSubview(profilePictureView)
        profilePictureView.parseImage = SMBUser.currentUser().profilePicture
        
        let profilePictureButton = UIButton(frame: CGRectInset(profilePictureView.frame, 20, 20))
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.width/2
        profilePictureButton.addTarget(self, action: "pinLocationAction:", forControlEvents: .TouchUpInside)
        //scrollInfoView.addSubview(profilePictureButton)
        
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
        
        
        //activityDrawerView = SMBActivityDrawerView(frame: CGRectMake(0, self.view.frame.height-44, self.view.frame.width, self.view.frame.height-self.view.frame.width), delegate: self)
        //self.view.addSubview(activityDrawerView!)
        
        
        // Overlaid view that fades to black as the user swipes to the side.
        scrollFadeView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scrollFadeView.backgroundColor = UIColor.blackColor()
        scrollFadeView.alpha = 0
        scrollFadeView.userInteractionEnabled = false
        //self.view.insertSubview(scrollFadeView, belowSubview: activityDrawerView!)
        
        //add labels
        genderLabel.textColor = UIColor.simbiWhiteColor()
        ageLabel.textColor = UIColor.simbiWhiteColor()
        heightLabel.textColor = UIColor.simbiWhiteColor()
        ethnicityLabel.textColor = UIColor.simbiWhiteColor()
        aboutmeLabel.textColor = UIColor.simbiWhiteColor()
        occupationLabel.textColor = UIColor.simbiWhiteColor()
        employerLabel.textColor = UIColor.simbiWhiteColor()
        degreeLabel.textColor = UIColor.simbiWhiteColor()
        schoolLabel.textColor = UIColor.simbiWhiteColor()
        meetupLocationsLabel.textColor = UIColor.simbiWhiteColor()
        meetupTimeLabel.textColor = UIColor.simbiWhiteColor()
        tagsLabel.textColor = UIColor.simbiWhiteColor()
        
        genderLabel.text = "Gender"
        genderLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
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
        employerLabel.text = "Employer"
        employerLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        degreeLabel.text = "degree"
        degreeLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        schoolLabel.text = "school"
        schoolLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        
        meetupLocationsLabel.text = "Meet Up Locations"
        meetupLocationsLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        meetupTimeLabel.text = "Meet Up Time"
        meetupTimeLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        tagsLabel.text = "Tags"
        tagsLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 23)
        
        genderLabel.frame.size = CGSize(width: 100, height: 30)
        genderLabel.frame.origin = CGPoint(x:20,y:260)
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
        employerLabel.frame.size = CGSize(width: 200, height: 30)
        employerLabel.frame.origin = CGPoint(x:20,y:540)
        degreeLabel.frame.size = CGSize(width: 200, height: 30)
        degreeLabel.frame.origin = CGPoint(x:20,y:580)
        schoolLabel.frame.size = CGSize(width: 200, height: 30)
        schoolLabel.frame.origin = CGPoint(x:20,y:620)
        meetupLocationsLabel.frame.size = CGSize(width: 200, height: 30)
        meetupLocationsLabel.frame.origin = CGPoint(x:20,y:660)
        meetupTimeLabel.frame.size = CGSize(width: 200, height: 30)
        meetupTimeLabel.frame.origin = CGPoint(x:20,y:760)
        tagsLabel.frame.size = CGSize(width: 200, height: 30)
        tagsLabel.frame.origin = CGPoint(x:20,y:860)
        
        
        self.scrollInfoView.addSubview(genderLabel)
        self.scrollInfoView.addSubview(ageLabel)
        self.scrollInfoView.addSubview(heightLabel)
        self.scrollInfoView.addSubview(ethnicityLabel)
        self.scrollInfoView.addSubview(aboutmeLabel)
        self.scrollInfoView.addSubview(occupationLabel)
        self.scrollInfoView.addSubview(employerLabel)
        self.scrollInfoView.addSubview(degreeLabel)
        self.scrollInfoView.addSubview(schoolLabel)
        self.scrollInfoView.addSubview(meetupLocationsLabel)
        self.scrollInfoView.addSubview(meetupTimeLabel)
        self.scrollInfoView.addSubview(tagsLabel)
        
        genderButton.tag = 149
        genderButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.allZeros)
        genderButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        genderButton.setTitle("gender",forState:UIControlState.allZeros)
        genderButton.frame.size = CGSize(width: 100,height: 30)
        genderButton.frame.origin = CGPoint(x: 110,y: 265)
        genderButton.addTarget(self, action:"selectButtonDown:", forControlEvents: UIControlEvents.TouchDown)
        
        ageButton.tag = 150
        ageButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.allZeros)
        ageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        ageButton.setTitle("age",forState:UIControlState.allZeros)
        ageButton.frame.size = CGSize(width: 50,height: 30)
        ageButton.frame.origin = CGPoint(x: ageLabel.frame.origin.x+50,y: ageLabel.frame.origin.y+5)
        ageButton.addTarget(self, action:"selectButtonDown:", forControlEvents: UIControlEvents.TouchDown)
        
        heightButton.tag = 151
        heightButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.allZeros)
        
        heightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        heightButton.setTitle("height",forState:UIControlState.allZeros)
        heightButton.frame.size = CGSize(width: 50,height: 30)
        heightButton.frame.origin = CGPoint(x: heightLabel.frame.origin.x+70,y: heightLabel.frame.origin.y+5)
        heightButton.addTarget(self, action:"selectButtonDown:", forControlEvents: UIControlEvents.TouchDown)
        
        ethnicityButton.tag = 152
        ethnicityButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.allZeros)
        ethnicityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        ethnicityButton.setTitle("ethnicity",forState:UIControlState.allZeros)
        ethnicityButton.frame.size = CGSize(width: 200,height: 30)
        ethnicityButton.frame.origin = CGPoint(x:ethnicityLabel.frame.origin.x+100,y: ethnicityLabel.frame.origin.y+5)
        ethnicityButton.addTarget(self, action:"selectButtonDown:", forControlEvents: UIControlEvents.TouchDown)
        
        degreeButton.tag = 153
        degreeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.allZeros)
        degreeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        degreeButton.setTitle("degree",forState:UIControlState.allZeros)
        degreeButton.frame.size = CGSize(width: 200,height: 30)
        degreeButton.frame.origin = CGPoint(x:degreeLabel.frame.origin.x+80,y: degreeLabel.frame.origin.y+5)
        degreeButton.addTarget(self, action:"selectButtonDown:", forControlEvents: UIControlEvents.TouchDown)
        
        aboutEdit.frame.size = CGSize(width: self.view.frame.width-40, height: 80)
        aboutEdit.frame.origin = CGPoint(x: 20, y: 410)
        aboutEdit.backgroundColor = UIColor.whiteColor()
        aboutEdit.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        aboutEdit.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        
        occupationEdit.frame.size = CGSize(width: 150, height: 30)
        occupationEdit.frame.origin = CGPoint(x: occupationLabel.frame.origin.x+130, y: occupationLabel.frame.origin.y)
        occupationEdit.backgroundColor = UIColor.whiteColor()
        occupationEdit.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        employerEdit.frame.size = CGSize(width: 150, height: 30)
        employerEdit.frame.origin = CGPoint(x: employerLabel.frame.origin.x+130, y: employerLabel.frame.origin.y)
        employerEdit.backgroundColor = UIColor.whiteColor()
        employerEdit.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        schoolEdit.frame.size = CGSize(width: 150, height: 30)
        schoolEdit.frame.origin = CGPoint(x: schoolLabel.frame.origin.x+80, y: schoolLabel.frame.origin.y)
        schoolEdit.backgroundColor = UIColor.whiteColor()
        schoolEdit.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        //add meet up location
        var locationIndex:Int = 0
        var locationButtonWidth:Int = 80
        var locationButtonHeight:Int = 20
        var numberperRow:Int = (Int(self.view.frame.width)-40)/(locationButtonWidth+10)
        for location in self.meetUpLocationsArray{
            let button = UIButton()
            button.tag = 190
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            button.frame.size = CGSize(width: locationButtonWidth, height: locationButtonHeight)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            var buttonX = (locationIndex)%numberperRow*(locationButtonWidth+10)+20
            var buttonY = Int(meetupLocationsLabel.frame.origin.y+meetupLocationsLabel.frame.size.height)+(locationButtonHeight+5)*((locationIndex)/numberperRow)
            button.frame.origin = CGPoint(x: buttonX, y: buttonY)
            button.setTitle(location, forState:UIControlState.allZeros)
            button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
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
            button.tag = 191
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            button.frame.size = CGSize(width: timeButtonWidth, height: timeButtonHeight)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            var buttonX = (timeIndex)%timeNumberperRow*(timeButtonWidth+10)+20
            var buttonY = Int(meetupTimeLabel.frame.origin.y+meetupTimeLabel.frame.size.height)+(timeButtonHeight+5)*((timeIndex)/timeNumberperRow)
            button.frame.origin = CGPoint(x: buttonX, y: buttonY)
            button.setTitle(location, forState:UIControlState.allZeros)
            button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
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
            button.tag = 192
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            button.frame.size = CGSize(width: tagsButtonWidth, height: tagsButtonHeight)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            var buttonX = (tagsIndex)%tagsNumberperRow*(tagsButtonWidth+10)+20
            var buttonY = Int(tagsLabel.frame.origin.y+tagsLabel.frame.size.height)+(tagsButtonHeight+5)*((tagsIndex)/tagsNumberperRow)
            button.frame.origin = CGPoint(x: buttonX, y: buttonY)
            button.setTitle(location, forState:UIControlState.allZeros)
            button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
            button.backgroundColor = UIColor.whiteColor()
            self.scrollInfoView.addSubview(button)
            button.addTarget(self, action: "blockButtonDown:", forControlEvents: UIControlEvents.TouchDown)
            tagsIndex++
        }
        genderPickerView.delegate = self
        genderPickerView.frame.size = CGSize(width: 300, height: 500)
        genderPickerView.center = self.view.center
        genderPickerView.tag = 99
        genderPickerView.hidden = true
        genderPickerView.backgroundColor = UIColor.whiteColor()
        
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
        
        degreePickerView.delegate = self
        degreePickerView.frame.size = CGSize(width: 300, height: 500)
        degreePickerView.center = self.view.center
        degreePickerView.tag = 103
        degreePickerView.hidden = true
        degreePickerView.backgroundColor = UIColor.whiteColor()
        
        self.scrollInfoView.addSubview(genderButton)
        self.scrollInfoView.addSubview(ageButton)
        self.scrollInfoView.addSubview(heightButton)
        self.scrollInfoView.addSubview(degreeButton)
        self.scrollInfoView.addSubview(ethnicityButton)
        self.scrollInfoView.addSubview(aboutEdit)
        self.scrollInfoView.addSubview(occupationEdit)
        self.scrollInfoView.addSubview(employerEdit)
        self.scrollInfoView.addSubview(schoolEdit)
        self.scrollInfoView.addSubview(saveButton)
        
        self.view.addSubview(ethnicityPickerView)
        self.view.addSubview(agePickerView)
        self.view.addSubview(heightPickerView)
        self.view.addSubview(genderPickerView)
        self.view.addSubview(degreePickerView)

        //add save button
        saveButton.setTitle("Save", forState: UIControlState.allZeros)
        saveButton.frame.size = CGSize(width: 70, height: 30)
        saveButton.center = CGPoint(x: self.scrollInfoView.frame.size.width/2, y: self.scrollInfoView.contentSize.height - 50)
        saveButton.backgroundColor = UIColor.greenColor()

        saveButton.addTarget(self, action: "saveButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        //add tap gesture
        var tapGr:UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:"viewTapped:")
        tapGr.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGr)
    }
    func saveButtonClicked(sender:UIButton){
        let obid = SMBUser.currentUser().objectId
        if obid=="" {
            return
        }
        let hud = MBProgressHUD.HUDwithMessage("Saving ....", parent: self)
        let query = PFQuery(className: "_User")
        query.getObjectInBackgroundWithId(obid) { (obj:PFObject!, err:NSError!) -> Void in
            if obj==nil{
                return
            }
            obj["gender"] = self.genderButton.titleLabel?.text
            obj["age"] = self.ageButton.titleLabel?.text?.toInt()
            let heightStr = self.heightButton.titleLabel?.text
            obj["height"] = self.heightDoubleArray[self.heightArray.indexOfObject(heightStr!)]
            obj["ethnicity"] = self.ethnicityButton.titleLabel?.text
            obj["aboutme"] = self.aboutEdit.text
            obj["degree"] = self.degreeButton.titleLabel?.text
            obj["school"] = self.schoolEdit.text
            obj["occupation"] = self.occupationEdit.text
            obj["employer"] = self.employerEdit.text
            obj["tags"] = self.tagsSelectedArray
            obj["MeetUpLocations"] = self.meetUpLocationsSelectedArray
            obj["MeetUpTimes"] = self.meetUpTimeSelectedArray
            
            obj.saveInBackgroundWithBlock({ (succ:Bool, err:NSError!) -> Void in
//                let alert = UIAlertView()
//                alert.title = "Tip"
//                alert.message = succ ? "save success!":"save failed!"
//                alert.addButtonWithTitle("Ok")
//                alert.show()
                if succ == true{
                 hud.dismissWithMessage("save success!")
                }else{
                 hud.dismissWithMessage("save failed!")
                }
             })
        }
    }
    func selectButtonDown(sender:UIButton){
        //age set button
        if sender.tag == 149{
            self.genderPickerView.hidden = false
        }
        if sender.tag == 150{
            self.agePickerView.hidden = false
        }
        if sender.tag == 151{
            self.heightPickerView.hidden = false
        }
        if sender.tag == 152{
            self.ethnicityPickerView.hidden = false
        }
        if sender.tag == 153{
            self.degreePickerView.hidden = false
        }
        
    }
    func blockButtonDown(sender:UIButton){
        sender.selected = !sender.selected
        if sender.tag == 190{
            let str = sender.titleLabel?.text
            if sender.selected{
                meetUpLocationsSelectedArray.addObject(str!)
            }else{
                meetUpLocationsSelectedArray.removeObject(str!)
            }
        }
        if sender.tag == 191{
            let str = sender.titleLabel?.text
            if sender.selected{
                meetUpTimeSelectedArray.addObject(str!)
            }else{
                meetUpTimeSelectedArray.removeObject(str!)
            }
        }
        if sender.tag == 192{
            let str = sender.titleLabel?.text
            if sender.selected{
                tagsSelectedArray.addObject(str!)
            }else{
                tagsSelectedArray.removeObject(str!)
            }
        }
    }
    func viewTapped(sender: UITapGestureRecognizer?){
        self.view.endEditing(true)
        self.agePickerView.hidden = true
        self.heightPickerView.hidden = true
        self.ethnicityPickerView.hidden = true
        self.genderPickerView.hidden = true
        self.degreePickerView.hidden = true
        
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 99{
            return genderArray.count
        }
        if pickerView.tag == 100{
            return ethnicityArray.count
        }
        if pickerView.tag == 101{
            return ageArray.count
        }
        if pickerView.tag == 102 {
            return heightArray.count
        }
        if pickerView.tag == 103 {
            return degreeArray.count
        }
        return 0
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 99{
            return genderArray[row]
        }
        if pickerView.tag == 100{
            return ethnicityArray[row]
        }
        if pickerView.tag == 101{
            return ageArray[row]
        }
        if pickerView.tag == 102{
            return heightArray[row] as String
        }
        if pickerView.tag == 103{
            return degreeArray[row]
        }
        return ""
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 99{
            genderButton.setTitle(genderArray[row], forState: UIControlState.allZeros)
        }
        if pickerView.tag == 100{
            ethnicityButton.setTitle(ethnicityArray[row], forState: UIControlState.allZeros)
        }
        if pickerView.tag == 101{
            ageButton.setTitle(ageArray[row], forState: UIControlState.allZeros)
        }
        if pickerView.tag == 102{
            heightButton.setTitle(heightArray[row] as String, forState: UIControlState.allZeros)
        }
        if pickerView.tag == 103{
            degreeButton.setTitle(degreeArray[row], forState: UIControlState.allZeros)
        }
        
    }

    
    // MARK: - User Actions
    func swipeControlDidBeginTouch(sender: AnyObject) {
        parent!.scrollView.scrollEnabled = false
    }
    
    
    func swipeControlDidEndTouch(sender: AnyObject) {
        parent!.scrollView.scrollEnabled = true
    }
    func updateViewData(){
        
        //self.tagsSelectedArray.addObjectsFromArray(self.currentUS.tags)
        if !(self.currentUS.tags==nil){
            for obj in self.currentUS.tags{
                tagsSelectedArray.addObject(obj)
                }
        }
        if !(self.currentUS.MeetUpLocations==nil){
            for obj in self.currentUS.MeetUpTimes!{
                meetUpTimeSelectedArray.addObject(obj)
            }
        }
        if !(self.currentUS.MeetUpLocations==nil){
            for obj in self.currentUS.MeetUpLocations!{
                meetUpLocationsSelectedArray.addObject(obj)
            }
        }
        self.genderButton.setTitle(self.currentUS.gender, forState: UIControlState.allZeros)
        self.ageButton.setTitle(self.currentUS.age.stringValue, forState: UIControlState.allZeros)
    self.heightButton.setTitle(self.heightArray[self.heightDoubleArray.indexOfObject(self.currentUS.height)] as String, forState: UIControlState.allZeros)
        self.ethnicityButton.setTitle(self.currentUS.ethnicity, forState: UIControlState.allZeros)
        self.aboutEdit.text = self.currentUS.aboutme
        self.occupationEdit.text = self.currentUS.occupation
        self.employerEdit.text = self.currentUS.employer
        self.degreeButton.setTitle(self.currentUS.degree, forState: UIControlState.allZeros)
        self.schoolEdit.text = self.currentUS.school
        for object in self.scrollInfoView.subviews{
            if object.tag == 190{
                let str = (object as UIButton).titleLabel?.text
                if self.meetUpLocationsSelectedArray.indexOfObject(str!) != NSNotFound{
                    (object as UIButton).selected = true
                }
                           }
            if object.tag == 191{
                let str = (object as UIButton).titleLabel?.text
                if self.meetUpTimeSelectedArray.indexOfObject(str!) != NSNotFound{
                    (object as UIButton).selected = true
                }
                           }
            if object.tag == 192{
                let str = (object as UIButton).titleLabel?.text
                if self.tagsSelectedArray.indexOfObject(str!) != NSNotFound{
                    (object as UIButton).selected = true
                }
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        //updateViewData()
        let hud = MBProgressHUD.HUDwithMessage("Loading ....", parent: self)
        
        let obid = SMBUser.currentUser().objectId
        if obid=="" {
            hud.dismissQuickly()
            return
        }
        let query = PFQuery(className: "_User")
        query.getObjectInBackgroundWithId(obid) { (obj:PFObject!, err:NSError!) -> Void in
            self.currentUS = obj as SMBUser
            self.updateViewData()
            hud.dismissQuickly()
        }

    }
    
}