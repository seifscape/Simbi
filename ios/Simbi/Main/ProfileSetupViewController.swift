//
//  SMBNewHomeViewController.swift
//  Simbi
//
//  Created by Seif Kobrosly on 11/29/15.
//  Copyright © 2015 SimbiSocial. All rights reserved.
//

import UIKit
//import ActionSheetPicker_3_0
//import TTRangeSlider
//import Parse
//import Bolts
//import FBSDKCoreKit
//import ParseFacebookUtilsV4
//import BMASliders
//import NMRangeSlider
//import SDWebImage

class ProfileSetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var blurUIImageView: UIImageView!
    @IBOutlet var profileImageView:UIImageView!
    
    var submitButton:UIButton?
    
    var isCurrentUser = false
    var genderSegment:UISegmentedControl?
    var genderPrefSegment:UISegmentedControl?
    var ageSelector:BMALabeledRangeSlider?
    var heightPrefSelector:BMASlider?
    var ageTextField:UITextField?
    var isComplete = false
    var heightPickerView:UIPickerView?
    
    var structPref:ProfilePreferences?
    
    var feetOption = ["0","1","2","3","4","5","6","7"]
    var inchesOption = ["0","1","2","3","4","5","6","7","8","9","10","11"]
    
    
    struct Contact {
        var Gender: Int
        var Age: Int
        var Name: String
        var Height: String
        var agePref = (-1,-1)
        var genderPref: Int
        var heightPref = (-1, -1)
        var eyeColorPref: UIColor
        var hairColorPref: UIColor
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        tableView.rowHeight = UITableViewAutomaticDimension
        //        maskRoundedImage(profileImageView.image!, radius: 100)
        //        self.profileImageView.image = [ImageHelper getImage]; //retrieve image
        self.profileImageView?.layer.cornerRadius = 60
        self.profileImageView?.layer.masksToBounds = true
        self.profileImageView?.layer.borderWidth = 3
        self.profileImageView?.layer.borderColor = UIColor.whiteColor().CGColor
        self.profileImageView?.contentMode = UIViewContentMode.ScaleAspectFill
//        let btn: UIButton = UIButton(frame: self.profileImageView!.frame)
//        btn.layer.cornerRadius = 60
//        btn.layer.masksToBounds = true
//        btn.contentMode = UIViewContentMode.ScaleAspectFill
//        btn.setTitle("Upload Photo", forState: UIControlState.Normal)
//        btn.addTarget(self, action: #selector(ProfileSetupViewController.uploadImage), forControlEvents: UIControlEvents.TouchUpInside)
//        btn.tag = 99               // change tag property
//        self.profileImageView!.addSubview(btn) // add to view as subview
        
        
        // Delegates
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.initialSetup()
        // Do any additional setup after loading the view.
    }
    

    
    func initialSetup() {
        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large", parameters: nil)
        pictureRequest.startWithCompletionHandler({
            (connection, result, error: NSError!) -> Void in
            if error == nil {
//                let photo_url = result["data"]!["url"]! as? [String: AnyObject]
                let photoURL = result.objectForKey("data")?.objectForKey("url") as? String
                let url: NSURL = NSURL(string: photoURL!)!
                self.profileImageView?.contentMode = UIViewContentMode.ScaleAspectFit
                self.profileImageView?.sd_setImageWithURL(url)
                self.blurUIImageView?.image = self.profileImageView?.image
                print("\(result)")
            } else {
                print("\(error)")
            }
        })
        

        
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        //set your View. Here is an example ..
        if component == 0
        {
            let pickerviewtemp: UIView = UIView(frame: CGRectZero)
            let lbl: UILabel = UILabel(frame: CGRectMake(0, 0, 100, 50))
            lbl.backgroundColor = UIColor.clearColor()
            lbl.text = "Feet"
            lbl.font = UIFont.boldSystemFontOfSize(16)
            pickerviewtemp.addSubview(lbl)
            return pickerviewtemp
        }
        else
        {
            let pickerviewtemp: UIView = UIView(frame: CGRectZero)
            let lbl: UILabel = UILabel(frame: CGRectMake(0, 0, 100, 50))
            lbl.backgroundColor = UIColor.clearColor()
            lbl.text = "Inches"
            lbl.font = UIFont.boldSystemFontOfSize(16)
            pickerviewtemp.addSubview(lbl)
            return pickerviewtemp
        }

    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0
        {
            return self.feetOption.count
        }
        else
        {
            return self.inchesOption.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0
        {
            return self.feetOption[row];
        }
        else
        {
            return self.inchesOption[row];
        }
    }
    
    func userHeightDidChange(slider: BMASlider) {
        
        let currentCell = slider.findSuperViewWithClass(UITableViewCell) as! UITableViewCell

        currentCell.detailTextLabel!.text = heightString(Int(slider.currentValue))
        
        SMBUser.currentUser().height = NSNumber(integer: Int(slider.currentValue))
    }
    
    
    func heightPreferenceDidChange(slider: NMRangeSlider) {
        
        let currentCell = slider.findSuperViewWithClass(UITableViewCell) as! UITableViewCell

        
        currentCell.detailTextLabel!.text = heightString(Int(slider.lowerValue)) + "-" + heightString(Int(slider.upperValue))
        
        SMBUser.currentUser().lowerHeightPreference = NSNumber(integer: Int(slider.lowerValue))
        SMBUser.currentUser().upperHeightPreference = NSNumber(integer: Int(slider.upperValue))
    }
    
    func agePreferenceDidChange(slider: BMARangeSlider) {
        let currentCell = slider.findSuperViewWithClass(UITableViewCell) as! UITableViewCell
        
        if Int(slider.currentUpperValue) >= Int(slider.maximumValue) {
            currentCell.detailTextLabel!.text = "\(Int(slider.currentLowerValue))-\(Int(slider.currentUpperValue))+"
        }
        else {
            currentCell.detailTextLabel!.text = "\(Int(slider.currentLowerValue))-\(Int(slider.currentUpperValue))"
        }
        
        SMBUser.currentUser().lowerAgePreference = NSNumber(integer: Int(slider.currentLowerValue))
        SMBUser.currentUser().upperAgePreference = NSNumber(integer: Int(slider.currentUpperValue))

        
    }

    
    
    func saveProfile(){
        let hud = MBProgressHUD.HUDwithMessage("Loading", parent: self)
        let obid = SMBUser.currentUser().objectId
        
        if (obid == ""){
            hud.dismissQuickly()
            return
        }
        
        let query : PFQuery = PFUser.query()!
        query.getObjectInBackgroundWithId(obid!) { (userObject: PFObject?, error: NSError?) -> Void in
            userObject!["lookingto"] = self.genderPrefSegment?.selectedSegmentIndex
            userObject!["genderPreference"] = self.genderSegment?.selectedSegmentIndex
            userObject!["upperAgePreference"] = self.ageSelector!.maximumValue
            userObject!["lowerAgePreference"] = self.ageSelector!.minimumValue
            userObject?.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if (success){
                    hud.dismissWithMessage("Save success!")
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 3
        default:
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let shortPath = (indexPath.section, indexPath.row)

        let cell:UITableViewCell
        
        switch shortPath {
            case (0, 0):
                cell = tableView.dequeueReusableCellWithIdentifier("genderCell")! as UITableViewCell
                let items = ["Male", "Female", "+"]
                genderSegment = UISegmentedControl(items: items)
//                genderSegment!.selectedSegmentIndex = 0
                genderSegment!.addTarget(self, action: #selector(ProfileSetupViewController.userGenderDidChange(_:)), forControlEvents: .ValueChanged)
                cell.accessoryType = .None
                genderSegment!.frame = CGRectZero
                genderSegment!.sizeToFit()
                cell.accessoryView = genderSegment!
            
                if SMBUser.currentUser().gender != nil {
                    switch SMBUser.currentUser().gender {
                    case "male":
                        genderSegment!.selectedSegmentIndex = 0
                    case "female":
                        genderSegment!.selectedSegmentIndex = 1
                    default:
                        genderSegment!.selectedSegmentIndex = 2
                    }
            }
            
            case (0, 1):
                cell = tableView.dequeueReusableCellWithIdentifier("ageCell")! as UITableViewCell
                let sampleTextField = UITextField(frame: CGRectMake(20, 100, 300, 40))
                sampleTextField.placeholder = "Enter your age"
                sampleTextField.font = UIFont.systemFontOfSize(15)
                sampleTextField.borderStyle = UITextBorderStyle.RoundedRect
                sampleTextField.autocorrectionType = UITextAutocorrectionType.No
                sampleTextField.keyboardType = UIKeyboardType.Default
                sampleTextField.returnKeyType = UIReturnKeyType.Done
                sampleTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
                sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
                cell.accessoryType = .None
                sampleTextField.sizeToFit()
                self.ageTextField = sampleTextField
                self.ageTextField?.delegate = self
                cell.accessoryView = sampleTextField
            case (0, 2):
                cell = tableView.dequeueReusableCellWithIdentifier("heightCell")! as UITableViewCell
                (cell.textLabel?.frame.width)! + 40
                (cell.detailTextLabel?.frame.width)! + 30
//                let sliderView = NMRangeSlider(frame: CGRectMake(titleLableFrame,(cell.textLabel?.frame.height)!, tableView.frame.width-(titleLableFrame + detailLableFrame), 44))
//                sliderView.minimumValue = 48
//                sliderView.maximumValue = 84
//                sliderView.minimumRange = 1
//                sliderView.tag = 100
//                sliderView.frame = CGRectMake(titleLableFrame,(cell.textLabel?.frame.height)!, tableView.frame.width-(titleLableFrame + detailLableFrame), 44)
//
//                cell.addSubview(sliderView)
//
////                sliderView.clipsToBounds = true
//                sliderView.tintColor = UIColor.blueColor()
//                if(cell.contentView.viewWithTag(100) == nil){
//                    cell.addSubview(sliderView)
//                }
//                else {
//                    cell.viewWithTag(100)?.removeFromSuperview()
//                }
////                userHeightDidChange(sliderView)
//                sliderView.addTarget(self, action: "userHeightDidChange:", forControlEvents: .ValueChanged)
            case (1, 0):
                cell = tableView.dequeueReusableCellWithIdentifier("genderCellPref")! as UITableViewCell
                let items = ["Male", "Female", "Both"]
                genderPrefSegment = UISegmentedControl(items: items)
                genderPrefSegment!.addTarget(self, action: #selector(ProfileSetupViewController.userGenderPrefDidChange(_:)), forControlEvents: .ValueChanged)
//                genderPrefSegment!.selectedSegmentIndex = 0
                cell.accessoryType = .None
                genderPrefSegment!.frame = CGRectZero
                genderPrefSegment!.sizeToFit()
                cell.accessoryView = genderPrefSegment
            
            case (1,1):
                cell = tableView.dequeueReusableCellWithIdentifier("prefAges")! as UITableViewCell
//                let sliderView = BMARangeSlider(frame: CGRectMake(0, 0, 225, 40))
                let titleLableFrame = (cell.textLabel?.frame.width)! + 30
                let detailLableFrame = (cell.detailTextLabel?.frame.width)! + 30
                let sliderView = BMARangeSlider(frame: CGRectMake(titleLableFrame,(cell.textLabel?.frame.height)!, tableView.frame.width-(titleLableFrame + detailLableFrame), 44))
                sliderView.minimumValue = 18
                sliderView.maximumValue = 55
                sliderView.setUpperBound(sliderView.maximumValue, animated: true)
                sliderView.setLowerBound(sliderView.minimumValue, animated: true)
                sliderView.step = 1
                sliderView.clipsToBounds = true
                sliderView.tag = 100
                sliderView.sizeToFit()
//                sliderView.rangeFormatter = BMARangeFormatter()
                if((cell.contentView.viewWithTag(100)) != nil){
                    cell.viewWithTag(100)?.removeFromSuperview()
                }
                else {
                    cell.addSubview(sliderView)
                }

                self.agePreferenceDidChange(sliderView)
                sliderView.addTarget(self, action: #selector(ProfileSetupViewController.agePreferenceDidChange(_:)), forControlEvents: .ValueChanged)

//                self.ageSelector = sliderView
            case (1, 2):
                cell = tableView.dequeueReusableCellWithIdentifier("heightPref")! as UITableViewCell
                let titleLableFrame = (cell.textLabel?.frame.width)! + 30
                let detailLableFrame = (cell.detailTextLabel?.frame.width)! + 30
                let sliderView = NMRangeSlider(frame: CGRectMake(titleLableFrame,(cell.textLabel?.frame.height)!, tableView.frame.width-(titleLableFrame + detailLableFrame), 44))
                sliderView.minimumValue = 48
                sliderView.maximumValue = 84
                sliderView.setUpperValue(sliderView.maximumValue, animated: false)
                sliderView.setLowerValue(sliderView.minimumValue, animated: false)
                sliderView.clipsToBounds = true
                sliderView.tag = 200
                if((cell.contentView.viewWithTag(200)) == nil){
                    cell.addSubview(sliderView)
                }
                else {
                    cell.viewWithTag(200)?.removeFromSuperview()

                }

//                sliderView.sizeToFit()
                //                sliderView.rangeFormatter = BMARangeFormatter()
                heightPreferenceDidChange(sliderView)
                cell.layoutIfNeeded()
                sliderView.addTarget(self, action: #selector(ProfileSetupViewController.heightPreferenceDidChange(_:)), forControlEvents: .ValueChanged)
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("genderCell")! as UITableViewCell
                }
                return cell
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 70
//    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let  selectedCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell

        selectedCell.selectionStyle = .None

        
        if(indexPath.section == 0 && indexPath.row == 2){
//            UIView.animateWithDuration(1, animations: { () -> Void in
//                // And set final frame here
//                self.heightPickerView = UIPickerView()
//                //        self.heightPickerView?.frame = CGRectMake(100, 100, 100, 162)
//                self.heightPickerView!.delegate = self
//                self.heightPickerView?.backgroundColor = UIColor.whiteColor()
//                self.heightPickerView!.dataSource = self
//                let viewFrame: CGRect = self.view.frame
//                let pickerHeight = self.heightPickerView!.frame.size.height
//                // assume you have an outlet called picker
//                self.heightPickerView?.frame = CGRectMake(0, viewFrame.size.height - pickerHeight, viewFrame.size.width, pickerHeight)
//                self.view.addSubview(self.heightPickerView!)
////                self.heightPickerView!.superview!.bringSubviewToFront(self.heightPickerView!)
//
//
//            })
            
            self.multipleStringPickerClicked(selectedCell, completionClosure: { (value) -> () in
                selectedCell.detailTextLabel?.text = (value[0] + " " + value[1])
                self.structPref?.height = value[0] + " " + value[1]
                self.isComplete = true
                self.tableView!.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
                selectedCell.layoutIfNeeded()
                return
            })
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else if (indexPath.section == 1 && isComplete)
        {
            
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (section == 1) {
            return "Preferences"
        }
        else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        //http://stackoverflow.com/questions/12772197/what-is-the-meaning-of-the-no-index-path-for-table-cell-being-reused-message-i
        if section == 1 {
//            http://stackoverflow.com/questions/18490621/no-index-path-for-table-cell-being-reused
            let footerView = tableView.dequeueReusableCellWithIdentifier("saveCell") as UITableViewCell!
            let containerView = UIView(frame:footerView.frame)
            footerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            containerView.addSubview(footerView)
//            let btn: UIButton = UIButton(frame: footerView.frame)
//            btn.backgroundColor = UIColor.clearColor()
//            btn.setTitle("", forState: UIControlState.Normal)
//            btn.addTarget(self, action: #selector(ProfileSetupViewController.submitAction), forControlEvents: UIControlEvents.TouchUpInside)
//            btn.tag = 1               // change tag property
//            footerView.addSubview(btn) // add to view as subview

            return containerView

//            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("saveCell")!
//            return cell
        }
        else {
            let paddingFrame : CGRect = CGRectZero
            let paddingView : UIView = UIView(frame: paddingFrame)
            
            return paddingView
        }
        
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        http://stackoverflow.com/questions/22207255/hiding-uitableview-footer
        if(isComplete){
            return 45
        }
        else {
            return 0

        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {

        if(tableView?.contentOffset.y >= ((tableView?.contentSize.height)! - (tableView?.frame.size.height)!)) {
            //user has scrolled to the bottom
        }

        
    }

    func multipleStringPickerClicked(sender: AnyObject, completionClosure: (value :[String]) ->())  {//-> Array<String> {
        var returnString: [String] = []
        
        
        
//        ActionSheetMultipleStringPicker.showPickerWithTitle("Height ", rows: [
//            ["1 ft", "2 ft", "3 ft", "4 ft", "5 ft", "6 ft", "7 ft"],
//            ["0 in", "1 in", "2 in", "3 in", "4 in", "5 in", "6 in", "7 in", "8 in", "9 in", "10 in", "11 in"]
//            ], initialSelection: [2, 2], doneBlock: {
//                picker, values, indexes in
//                
//                print("values = \(values)")
//                print("indexes = \(indexes)")
//                print("picker = \(picker)")
//                
//                returnString = indexes as! [String]
//                completionClosure(value: returnString)
//
//                return
//            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender)

        return
    }
    
    func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 2
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.isEqual(self.ageTextField)){
            structPref?.age = Int(textField.text!)!
            SMBUser.currentUser().age = structPref?.age
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func userGenderDidChange(sender : UISegmentedControl) {
        
        if (sender.isEqual(self.genderSegment)){
            
            self.structPref?.gender = sender.selectedSegmentIndex
            switch sender.selectedSegmentIndex {
            case 0:  SMBUser.currentUser().setGenderType(kSMBUserGenderMale)
            case 1:  SMBUser.currentUser().setGenderType(kSMBUserGenderFemale)
            default: SMBUser.currentUser().setGenderType(kSMBUserGenderOther)
            }
        }
        else {
            self.structPref?.genderPref = sender.selectedSegmentIndex
        }
    }
    
    func userGenderPrefDidChange(sender : UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:  SMBUser.currentUser().setGenderPreferenceType(kSMBUserGenderMale)
        case 1:  SMBUser.currentUser().setGenderPreferenceType(kSMBUserGenderFemale)
        default: SMBUser.currentUser().setGenderPreferenceType(kSMBUserGenderOther)
        }
    }
    
    
    
    
    /*
    Image Resizing Techniques: http://bit.ly/1Hv0T6i
    https://gist.github.com/tomasbasham/10533743
    */
    func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    

}


extension UIView {
    
    func findSuperViewWithClass<T>(superViewClass : T.Type) -> UIView? {
        
        var xsuperView : UIView!  = self.superview!
        var foundSuperView : UIView!
        
        while (xsuperView != nil && foundSuperView == nil) {
            
            if xsuperView.self is T {
                foundSuperView = xsuperView
            } else {
                xsuperView = xsuperView.superview
            }
        }
        return foundSuperView
    }
    
}


