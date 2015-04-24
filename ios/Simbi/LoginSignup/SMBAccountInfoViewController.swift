//
//  SMBAccountInfoViewController.swift
//  Simbi
//
//  Created by flynn on 10/26/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBAccountInfoViewController: UITableViewController {
    
    let profilePictureView = SMBImageView()
    
    let userAgeLabel    = UILabel()
    let userHeightLabel = UILabel()
    
    let prefAgeLabel    = UILabel()
    let prefHeightLabel = UILabel()
    
    // MARK: - ViewController Lifecycle
    
    convenience init() { self.init(style: .Grouped) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.simbiWhiteColor()
        self.tableView.separatorColor = UIColor.clearColor()
        
        if !PFFacebookUtils.isLinkedWithUser(SMBUser.currentUser()) {
            profilePictureAction(self)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        SMBAppDelegate.instance().enableSideMenuGesture(false)
    }
    
    
    // MARK: - User Actions
    
    func profilePictureAction(sender: AnyObject) {

        let title = "Profile Picture"
        
        var alertView: UIAlertView
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alertView = UIAlertView(title: title, message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Take photo now", "Select photo")
        }
        else {
            alertView = UIAlertView(title: title, message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Select photo")
        }
        alertView.show()
    }
    
    
    func submitAction() {
        
        if SMBUser.currentUser().profilePicture == nil || SMBUser.currentUser().profilePicture.objectId == nil {
            MBProgressHUD.showMessage("Please upload a picture", parent: self)
            return
        }
        if SMBUser.currentUser().gender == nil {
            MBProgressHUD.showMessage("Please choose a gender", parent: self)
            return
        }
        if SMBUser.currentUser().age == nil {
            MBProgressHUD.showMessage("Please choose an age", parent: self)
            return
        }
        if SMBUser.currentUser().height == nil {
            MBProgressHUD.showMessage("Please choose a height", parent: self)
            return
        }
        
        let hud = MBProgressHUD.HUDwithMessage("Saving...", parent: self)
        
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            
            if geoPoint != nil {
                SMBUser.currentUser().geoPoint = geoPoint
            }
            
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(CLLocation(latitude: geoPoint!.latitude, longitude: geoPoint!.longitude), completionHandler: { (placemarks, error) -> Void in
                
                if placemarks != nil {
                    let placemark = placemarks.first as! CLPlacemark
                    SMBUser.currentUser().city = placemark.locality
                    SMBUser.currentUser().state = placemark.administrativeArea
                }
                else {
                    SMBUser.currentUser().city = "Somewhere"
                    SMBUser.currentUser().state = ""
                }
                
                SMBUser.currentUser().saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                    
                    if succeeded {
                        hud.dismissQuickly()
                        SMBAppDelegate.instance().animateToMain()
                    }
                    else {
                        println(error)
                        hud.dismissWithError()
                    }
                })
            })
        }
    }
    
    
    // "About Me" methods
    
    func userGenderDidChange(segmentedControl: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:  SMBUser.currentUser().setGenderType(kSMBUserGenderMale)
        case 1:  SMBUser.currentUser().setGenderType(kSMBUserGenderFemale)
        default: SMBUser.currentUser().setGenderType(kSMBUserGenderOther)
        }
    }
    
    
    func userAgeDidChange(slider: UISlider) {
        
        if Int(slider.value) >= Int(slider.maximumValue) {
            userAgeLabel.text = "\(Int(slider.value))+"
        }
        else {
            userAgeLabel.text = "\(Int(slider.value))"
        }
        
        SMBUser.currentUser().age = NSNumber(integer: Int(slider.value))
    }
    
    
    func userHeightDidChange(slider: UISlider) {
        
        userHeightLabel.text = heightString(Int(slider.value))
        
        SMBUser.currentUser().height = NSNumber(integer: Int(slider.value))
    }
    
    
    func userHairColorDidChange(colorSelector: SMBQuantizedColorSelector) {
        
    }
    
    
    func userEyeColorDidChange(colorSelector: SMBQuantizedColorSelector) {
        
    }
    
    
    // "Preferences" methods
    
    func genderPreferenceDidChange(segmentedControl: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:  SMBUser.currentUser().setGenderPreferenceType(kSMBUserGenderMale)
        case 1:  SMBUser.currentUser().setGenderPreferenceType(kSMBUserGenderFemale)
        default: SMBUser.currentUser().setGenderPreferenceType(kSMBUserGenderOther)
        }
    }
    
    
    func agePreferenceDidChange(slider: NMRangeSlider) {
        
        if Int(slider.upperValue) >= Int(slider.maximumValue) {
            prefAgeLabel.text = "\(Int(slider.lowerValue))-\(Int(slider.upperValue))+"
        }
        else {
            prefAgeLabel.text = "\(Int(slider.lowerValue))-\(Int(slider.upperValue))+"
        }
        
        SMBUser.currentUser().lowerAgePreference = NSNumber(integer: Int(slider.lowerValue))
        SMBUser.currentUser().upperAgePreference = NSNumber(integer: Int(slider.upperValue))
    }
    
    
    func heightPreferenceDidChange(slider: NMRangeSlider) {
        
        prefHeightLabel.text = heightString(Int(slider.lowerValue)) + "-" + heightString(Int(slider.upperValue))
        
        SMBUser.currentUser().lowerHeightPreference = NSNumber(integer: Int(slider.lowerValue))
        SMBUser.currentUser().upperHeightPreference = NSNumber(integer: Int(slider.upperValue))
    }
    
    
    func hairColorPreferenceDidChange(colorSelector: SMBQuantizedColorSelector) {
        
    }
    
    
    func eyeColorPreferenceDidChange(colorSelector: SMBQuantizedColorSelector) {
        
    }
    
    
    // MARK: - UITableViewDataSource/Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 264 : 44
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            let view = UIView()
            view.backgroundColor = UIColor.simbiWhiteColor()
            
            let topView = UIView(frame: CGRectMake(0, -660, tableView.frame.width, 660+132)) // :P
            topView.backgroundColor = UIColor.simbiBlueColor()
            view.addSubview(topView)
            
            profilePictureView.frame = CGRectMake(0, 0, 132, 132)
            profilePictureView.center = CGPointMake(tableView.frame.width/2, 132)
            profilePictureView.backgroundColor = UIColor.simbiBlackColor()
            profilePictureView.layer.cornerRadius = profilePictureView.frame.width/2
            profilePictureView.layer.masksToBounds = true
            if SMBUser.currentUser()?.profilePicture != nil {
                profilePictureView.setParseImage(SMBUser.currentUser().profilePicture, withType: kImageTypeMedium)
            }
            view.addSubview(profilePictureView)
            
            let profilePictureButton = UIButton(frame: profilePictureView.frame)
            profilePictureButton.addTarget(self, action: "profilePictureAction:", forControlEvents: .TouchUpInside)
            view.addSubview(profilePictureButton)
            
            let label = UILabel(frame: CGRectMake(12, 264-44, tableView.frame.width-12, 22))
            label.text = "About Me:"
            label.textColor = UIColor.simbiDarkGrayColor()
            label.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 16)
            view.addSubview(label)
            
            return view
        }
        else if section == 1 {
            
            let view = UIView()
            
            let label = UILabel(frame: CGRectMake(12, 0, tableView.frame.width-12, 44))
            label.text = "Preferences:"
            label.textColor = UIColor.simbiDarkGrayColor()
            label.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 16)
            view.addSubview(label)
            
            return view
        }
        else {
            return nil
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section < 2 ? 5 : 1
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 2 {
            return 44
        }
        else {
            switch indexPath.row {
            case 0:
                return 66
            case 1:
                return 110
            case 2:
                return 110
            case 3:
                return 88
            case 4:
                return 88
            default:
                return 0
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.backgroundColor = UIColor.simbiWhiteColor()
        cell.selectionStyle = .None
        
        let label = UILabel(frame: CGRectMake(22, 0, tableView.frame.width-22, 22))
        label.textColor = UIColor.simbiGrayColor()
        label.font = UIFont.simbiFontWithSize(12)
        label.userInteractionEnabled = false
        cell.contentView.addSubview(label)
        
        switch (indexPath.section, indexPath.row) {
           
        // Section 0: About Me
            
        case (0, 0):
            label.text = "Gender"
            
            let segmentedControl = UISegmentedControl(items: ["Male", "Female", "+"])
            segmentedControl.frame = CGRectMake(22, 22+(44-28)/2, tableView.frame.width-44, 28)
            segmentedControl.tintColor = UIColor.simbiBlueColor()
            segmentedControl.addTarget(self, action: "userGenderDidChange:", forControlEvents: .ValueChanged)
            
            if SMBUser.currentUser().gender != nil {
                switch SMBUser.currentUser().gender {
                case "male":
                    segmentedControl.selectedSegmentIndex = 0
                case "female":
                    segmentedControl.selectedSegmentIndex = 1
                default:
                    segmentedControl.selectedSegmentIndex = 2
                }
            }
            
            cell.contentView.addSubview(segmentedControl)
            
        case (0, 1):
            label.text = "Age"

            let slider = UISlider(frame: CGRectMake(22, 22, tableView.frame.width-44-66, 88))
            slider.minimumValue = 18
            slider.maximumValue = 55
            slider.tintColor = UIColor.simbiBlueColor()
            slider.addTarget(self, action: "userAgeDidChange:", forControlEvents: .ValueChanged)
            
            if SMBUser.currentUser().age != nil {
                slider.value = SMBUser.currentUser().age.floatValue
            }
            
            cell.contentView.addSubview(slider)
            
            userAgeLabel.frame = CGRectMake(tableView.frame.width-11-66, 22, 66, 88)
            userAgeLabel.textColor = UIColor.simbiDarkGrayColor()
            userAgeLabel.font = UIFont.simbiFontWithSize(18)
            userAgeLabel.textAlignment = .Center
            cell.contentView.addSubview(userAgeLabel)
            
        case (0, 2):
            label.text = "Height"

            let slider = UISlider(frame: CGRectMake(22, 22, tableView.frame.width-44-66, 88))
            slider.minimumValue = 48
            slider.maximumValue = 84
            slider.tintColor = UIColor.simbiBlueColor()
            slider.addTarget(self, action: "userHeightDidChange:", forControlEvents: .ValueChanged)
            
            if SMBUser.currentUser().height != nil {
                slider.value = SMBUser.currentUser().height.floatValue
            }
            
            cell.contentView.addSubview(slider)
            
            userHeightLabel.frame = CGRectMake(tableView.frame.width-11-66, 22, 66, 88)
            userHeightLabel.textColor = UIColor.simbiDarkGrayColor()
            userHeightLabel.font = UIFont.simbiFontWithSize(18)
            userHeightLabel.textAlignment = .Center
            cell.contentView.addSubview(userHeightLabel)
            
        case (0, 3):
            label.text = "Hair Color"
            
            let colors = [UIColor.yellowColor(), UIColor.redColor(), UIColor.brownColor(), UIColor.blackColor()]
            let frame = CGRectMake(22, 33, tableView.frame.width-44, 44)
            
            let colorSelector = SMBQuantizedColorSelector(frame: frame, colors: colors)
            colorSelector.setSelectedIndex( UInt(arc4random()) % UInt(colors.count) )
            colorSelector.layer.cornerRadius = 4
            colorSelector.layer.masksToBounds = true
            colorSelector.addTarget(self, action: "userHairColorDidChange:", forControlEvents: .ValueChanged)
            cell.contentView.addSubview(colorSelector)
            
        case (0, 4):
            label.text = "Eye Color"
            
            let colors = [UIColor.greenColor(), UIColor.blueColor(), UIColor.grayColor(), UIColor.brownColor()]
            let frame = CGRectMake(22, 33, tableView.frame.width-44, 44)
            
            let colorSelector = SMBQuantizedColorSelector(frame: frame, colors: colors)
            colorSelector.setSelectedIndex( UInt(arc4random()) % UInt(colors.count) )
            colorSelector.layer.cornerRadius = 4
            colorSelector.layer.masksToBounds = true
            colorSelector.addTarget(self, action: "userEyeColorDidChange:", forControlEvents: .ValueChanged)
            cell.contentView.addSubview(colorSelector)
            
        // Section 1: Preferences
            
        case (1, 0):
            label.text = "Gender"
            
            let segmentedControl = UISegmentedControl(items: ["Male", "Female", "+"])
            segmentedControl.frame = CGRectMake(22, 22+(44-28)/2, tableView.frame.width-44, 28)
            segmentedControl.tintColor = UIColor.simbiBlueColor()
            segmentedControl.addTarget(self, action: "genderPreferenceDidChange:", forControlEvents: .ValueChanged)
            
            if SMBUser.currentUser().genderPreference != nil {
                
                switch SMBUser.currentUser().genderPreference {
                case "male":
                    segmentedControl.selectedSegmentIndex = 0
                case "female":
                    segmentedControl.selectedSegmentIndex = 1
                default:
                    segmentedControl.selectedSegmentIndex = 2
                }
            }
            
            cell.contentView.addSubview(segmentedControl)
            
        case (1, 1):
            label.text = "Age"
            
            let slider = NMRangeSlider(frame: CGRectMake(22, 22, tableView.frame.width-44-66, 88))
            slider.minimumValue = 18
            slider.maximumValue = 55
            slider.minimumRange = 1
            slider.setUpperValue(slider.maximumValue, animated: false)
            slider.setLowerValue(slider.minimumValue, animated: false)
            slider.tintColor = UIColor.simbiBlueColor()
            slider.frame = CGRectMake(22, 22, tableView.frame.width-44-66, 88)
            slider.addTarget(self, action: "agePreferenceDidChange:", forControlEvents: .ValueChanged)
            
            if SMBUser.currentUser().lowerAgePreference == nil {
                SMBUser.currentUser().lowerAgePreference = NSNumber(integer: Int(slider.lowerValue))
                SMBUser.currentUser().upperAgePreference = NSNumber(integer: Int(slider.upperValue))
            }
            else {
                slider.setUpperValue(SMBUser.currentUser().upperAgePreference.floatValue, animated: false)
                slider.setLowerValue(SMBUser.currentUser().lowerAgePreference.floatValue, animated: false)
            }
            cell.contentView.addSubview(slider)
            
            prefAgeLabel.frame = CGRectMake(cell.frame.width-11-66, 22, 66, 88)
            prefAgeLabel.textColor = UIColor.simbiDarkGrayColor()
            prefAgeLabel.font = UIFont.simbiFontWithSize(18)
            prefAgeLabel.textAlignment = .Center
            cell.contentView.addSubview(prefAgeLabel)
            
            agePreferenceDidChange(slider)
            
        case (1, 2):
            label.text = "Height"
            
            let slider = NMRangeSlider(frame: CGRectMake(22, 22, tableView.frame.width-44-66, 88))
            slider.minimumValue = 48
            slider.maximumValue = 84
            slider.minimumRange = 1
            slider.setUpperValue(slider.maximumValue, animated: false)
            slider.setLowerValue(slider.minimumValue, animated: false)
            slider.tintColor = UIColor.simbiBlueColor()
            slider.frame = CGRectMake(22, 22, tableView.frame.width-44-66, 88)
            slider.addTarget(self, action: "heightPreferenceDidChange:", forControlEvents: .ValueChanged)
            
            if SMBUser.currentUser().lowerHeightPreference == nil {
                SMBUser.currentUser().lowerHeightPreference = NSNumber(integer: Int(slider.lowerValue))
                SMBUser.currentUser().upperHeightPreference = NSNumber(integer: Int(slider.upperValue))
            }
            else {
                slider.setUpperValue(SMBUser.currentUser().upperHeightPreference.floatValue, animated: false)
                slider.setLowerValue(SMBUser.currentUser().lowerHeightPreference.floatValue, animated: false)
            }
            cell.contentView.addSubview(slider)
            
            prefHeightLabel.frame = CGRectMake(cell.frame.size.width-11-66-11, 22, 66+22, 88)
            prefHeightLabel.textColor = UIColor.simbiDarkGrayColor()
            prefHeightLabel.font = UIFont.simbiFontWithSize(15)
            prefHeightLabel.textAlignment = .Center
            cell.contentView.addSubview(prefHeightLabel)
            
            heightPreferenceDidChange(slider)
            
        case (1, 3):
            label.text = "Hair Color"
            
            let colors = [UIColor.yellowColor(), UIColor.redColor(), UIColor.brownColor(), UIColor.blackColor()]
            let frame = CGRectMake(22, 33, tableView.frame.width-44, 44)
            
            let colorSelector = SMBQuantizedColorSelector(frame: frame, colors: colors)
            colorSelector.setSelectedIndex( UInt(arc4random()) % UInt(colors.count) )
            colorSelector.layer.cornerRadius = 4
            colorSelector.layer.masksToBounds = true
            colorSelector.addTarget(self, action: "hairColorPreferenceDidChange:", forControlEvents: .ValueChanged)
            cell.contentView.addSubview(colorSelector)
            
        case (1, 4):
            label.text = "Eye Color"
            
            let colors = [UIColor.greenColor(), UIColor.blueColor(), UIColor.grayColor(), UIColor.brownColor()]
            let frame = CGRectMake(22, 33, tableView.frame.width-44, 44)
            
            let colorSelector = SMBQuantizedColorSelector(frame: frame, colors: colors)
            colorSelector.setSelectedIndex( UInt(arc4random()) % UInt(colors.count) )
            colorSelector.layer.cornerRadius = 4
            colorSelector.layer.masksToBounds = true
            colorSelector.addTarget(self, action: "eyeColorPreferenceDidChange:", forControlEvents: .ValueChanged)
            cell.contentView.addSubview(colorSelector)
           
        // Section 2: Submit Button
            
        case (2, 0):
            cell.backgroundColor = UIColor.simbiBlueColor()
            cell.textLabel?.text = "Submit"
            cell.textLabel?.textColor = UIColor.simbiWhiteColor()
            cell.textLabel?.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 18)
            cell.textLabel?.textAlignment = .Center
            
        default:
            println("Invalid indexPath")
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 2 {
            submitAction()
        }
    }
}


// MARK: - UIAlertViewDelegate

extension SMBAccountInfoViewController: UIAlertViewDelegate {
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex != 0 {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            
            if alertView.numberOfButtons == 3 && buttonIndex == 1 {
                imagePicker.sourceType = .Camera
            }
            else {
                imagePicker.sourceType = .PhotoLibrary
            }
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate

extension SMBAccountInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            let image = info[UIImagePickerControllerEditedImage] as! UIImage
            
            let profileImage = SMBImage()
            profileImage.originalImage = PFFile(data: UIImageJPEGRepresentation(image, 0.8))
            
            self.profilePictureView.parseImage = profileImage
            self.profilePictureView.saveImageInBackgroundWithBlock({ (image: SMBImage!) -> Void in
                
                if image != nil {
                    SMBUser.currentUser().profilePicture = profileImage
                    SMBUser.currentUser().saveInBackgroundWithBlock(nil)
                }
            })
        })
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

