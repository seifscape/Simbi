//
//  SignUpViewController.swift
//  Simbi
//
//  Created by Seif Kobrosly on 11/14/15.
//  Copyright © 2015 SimbiSocial. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKCoreKit
import ParseFacebookUtilsV4


class SignUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var backgroundImage: UIImageView?
    @IBOutlet weak var dismissBtn: UIButton?
    @IBOutlet weak var quicklyUILabel: UILabel?
    
    weak var emailField: UITextField?
    weak var passwordField: UITextField?
    weak var confirmPasswordField: UITextField?
    weak var firstNameField: UITextField?
    weak var lastNameField: UITextField?


//    weak var emailField: UITextField?

    var isComplete = false
    
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint?

    
    var isSignup = Bool()
    var isLogin  = Bool()
    
    var userSigningUp = Bool()
    
    var dictionary: [String:Bool] = [
        "Email" : false,
        "Password" : false,
        "Confirm Password" : false,
        "First Name" : false,
        "Last Name"  : false
    ]
    
    var isEmptyFields: [Bool] = [false, false, false, false, false]
    var itemsString: [String] = ["Email", "Password", "Confirm Password", "First Name", "Last Name"]
    var tableSignupData = Array<(email: String, password: String, confirmPassword: String , firstName: String, lastName: String)>()
    var loginData = Array<(email: String, password: String, firstName: String, lastName: String)>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        userSigningUp  = false
        self.tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0);
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.clearColor()
        
        if isLogin {
            quicklyUILabel?.text = "Quickly log in with:"
            quicklyUILabel?.sizeToFit()
        }
        else if isSignup {
            quicklyUILabel?.text = "Quickly sign up with:"
            quicklyUILabel?.sizeToFit()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
            super.viewDidAppear(animated)
            self.adjustTableViewHeight()

            // Do any additional setup after loading the view.
//            let lightBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
//            // 2
//            let blurView = UIVisualEffectView(effect: lightBlur)
//            blurView.frame = backgroundImage!.bounds
//            // 3
//            backgroundImage!.addSubview(blurView)
//            backgroundImage?.sendSubviewToBack(backgroundImage!)

    }

    @IBAction func cancel(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return self.itemsString.count + 1

        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if indexPath.section == 0 {
            let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("facebookCell")! as UITableViewCell
            return cell
        }
        else
        {
            
            var cell:SMBSignUpTableViewCell!
            

            switch(indexPath.row)
            {
            case 0:
                cell = self.tableView.dequeueReusableCellWithIdentifier("emailFieldCell")! as! SMBSignUpTableViewCell
                cell.cellTextField!.delegate = self
                cell.cellTextField?.tag = indexPath.row
                return cell
            case 1:
                cell = self.tableView.dequeueReusableCellWithIdentifier("passwordFieldCell")! as! SMBSignUpTableViewCell
                cell.cellTextField!.delegate = self
                cell.cellTextField?.tag = indexPath.row
            case 2:
                cell = self.tableView.dequeueReusableCellWithIdentifier("confirmPasswordFieldCell")! as! SMBSignUpTableViewCell
                cell.cellTextField!.delegate = self
                cell.cellTextField?.tag = indexPath.row
            case 3:
                cell = self.tableView.dequeueReusableCellWithIdentifier("firstNameFieldCell")! as! SMBSignUpTableViewCell
                cell.cellTextField!.delegate = self
                cell.cellTextField?.tag = indexPath.row
            case 4:
                cell = self.tableView.dequeueReusableCellWithIdentifier("lastNameFieldCell")! as! SMBSignUpTableViewCell
                cell.cellTextField!.delegate = self
                cell.cellTextField?.tag = indexPath.row
            case 5:
                if(isComplete)
                {
                    let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("signUpCell")!
                    return cell
                }
                else
                {
                    let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("signUpCell")!
                    cell.hidden = true
                    return cell
                }
            default:
                break
            }
            
            return cell
        }
    }
    
    /*
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if !userSigningUp {
            userSigningUp  = true
            items = ["Email", "Password", "Confirm Password", "First Name", "Last Name"]
            self.tableView.beginUpdates()
            self.tableView?.insertRowsAtIndexPaths(
                [NSIndexPath(forRow: 1, inSection: 1),
                    NSIndexPath(forRow: 2, inSection: 1),
                    NSIndexPath(forRow: 3, inSection: 1),
                    NSIndexPath(forRow: 4, inSection: 1),
                    NSIndexPath(forRow: 4, inSection: 1)],
                withRowAnimation: .Automatic)
            // Insert or delete rows
            self.tableView.endUpdates()
            print(self.tableView.numberOfRowsInSection(1))
            self.tableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1),
                NSIndexPath(forRow: 2, inSection: 1),
                NSIndexPath(forRow: 3, inSection: 1),
                NSIndexPath(forRow: 4, inSection: 1),
                NSIndexPath(forRow: 4, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Automatic)
            return true
        }
        else {
            return false
        }
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        userSigningUp  = true
        items = ["Email", "Password", "Confirm Password", "First Name", "Last Name"]
        self.tableView.beginUpdates()
        let indexPath1 = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView?.insertRowsAtIndexPaths(
            [NSIndexPath(forRow: 0, inSection: 0),
                NSIndexPath(forRow: 1, inSection: 0),
                NSIndexPath(forRow: 2, inSection: 0),
                NSIndexPath(forRow: 3, inSection: 0),
                NSIndexPath(forRow: 4, inSection: 0)],
            withRowAnimation: .None)
        self.tableView?.deleteSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView?.deleteRowsAtIndexPaths([indexPath1], withRowAnimation: UITableViewRowAnimation.Automatic)
        // Insert or delete rows
        self.tableView.endUpdates()
        self.tableView.reloadData()
        self.adjustTableViewHeight()
    }
    */
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        switch(textField.tag){
        case 0:
            if(textField.text != nil){
                self.isEmptyFields[textField.tag] = true;
                break
            }
        case 1:
            if(textField.text != nil){
                self.isEmptyFields[textField.tag] = true;
                break
            }
        case 2:
            if(textField.text != nil){
                self.isEmptyFields[textField.tag] = true;
                break
            }
        case 3:
            if(textField.text != nil){
                self.isEmptyFields[textField.tag] = true;
                break
            }
        case 4:
            if(textField.text != nil){
                self.isEmptyFields[textField.tag] = true;
                break
            }
        default:
            break
        }
        
        var currentBoolValue = false
        for x in self.isEmptyFields {
            if (x){
                currentBoolValue = true
            }
            else
            {
                currentBoolValue = false
            }
        }
        
        let indexPath = NSIndexPath(forRow: 5, inSection: 1)
        let cellRect = tableView.rectForRowAtIndexPath(indexPath)
        let completelyVisible = tableView.bounds.contains(cellRect)
        
        if (currentBoolValue && !completelyVisible){
            self.isComplete = true
            let indexPath = NSIndexPath(forRow: 5, inSection: 1)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)

//            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)

        }
        
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.signUpWithFacebookLogin()
        }
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell:SMBHeaderTableViewCell = tableView.dequeueReusableCellWithIdentifier("headerCell")! as! SMBHeaderTableViewCell
        if section == 0 {
            cell.textLabel?.text = "Quickly sign up with"
        }
        else {
            cell.textLabel?.text = "Or use your email:"
        }
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()

        return cell

    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
//        if section == 1 {
//            let footerView = tableView.dequeueReusableCellWithIdentifier("signUpCell") as UITableViewCell!
//            let containerView = UIView(frame:footerView.frame)
//            footerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//            containerView.addSubview(footerView)
//            return containerView
//        }
            let paddingFrame : CGRect = CGRectZero
            let paddingView : UIView = UIView(frame: paddingFrame)
            
            return paddingView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 45
    }
    
    func adjustTableViewHeight() {
        
        var height:CGFloat = self.tableView.contentSize.height;
        let maxHeight:CGFloat = self.tableView.superview!.frame.size.height - self.tableView.frame.origin.y;
        
        // if the height of the content is greater than the maxHeight of
        // total space on the screen, limit the height to the size of the
        // superview.
        
        if (height > maxHeight) {
            height = maxHeight;
        }
        
        UIView.animateWithDuration(1, animations: {
            self.tableViewHeightConstraint!.constant = height;
            self.view.setNeedsUpdateConstraints();
        })
        
//        UIView.animateWithDuration(0.25, animations: {
//            self.tableViewHeightConstraint!.constant = height;
//            self.view.setNeedsUpdateConstraints();
//            }, completion: {
//                (value: Bool) in
//        })

    }
    
    
    func signUpWithFacebookLogin() {
        let hud = MBProgressHUD.HUDwithMessage("Logging In...", parent: self)
        
        let permissions = ["email", "public_profile", "user_friends"]
        
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user: PFUser?, error: NSError?) -> Void in
            
            if user != nil {
                
                SMBAppDelegate.instance().syncUserInstallation()
                
                SMBFriendsManager.sharedManager().loadObjects(nil)
                SMBFriendRequestsManager.sharedManager().loadObjects(nil)
                SMBChatManager.sharedManager().loadObjects(nil)
                
                if user!.isNew || !(user as! SMBUser).isConfirmed {
                    
                    SMBUser.currentUser().syncWithFacebook({ (succeeded: Bool) -> Void in
                        
                        if succeeded {
                            
                            hud.dismissQuickly()
                            
                            self.navigationController!.pushViewController(SMBConfirmPhoneViewController(), animated: true)
                        }
                        else {
                            hud.dismissWithError()
                        }
                    })
                }
                else {
                    hud.dismissQuickly()
                    SMBAppDelegate.instance().animateToMain()
                }
            }
            else {
                print("ERROR: \(error)")
                hud.dismissWithError()
            }
            
        })
    }
    
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        tableViewHeightConstraint?.constant = tableView.contentSize.height
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}