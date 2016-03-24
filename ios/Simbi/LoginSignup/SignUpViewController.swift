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
        
        if section == 0
        {
            return 1
        }
        else
        {
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
                cell.cellTextField!.returnKeyType = .Next
                self.emailField = cell.cellTextField
                return cell
            case 1:
                cell = self.tableView.dequeueReusableCellWithIdentifier("passwordFieldCell")! as! SMBSignUpTableViewCell
                cell.cellTextField!.delegate = self
                cell.cellTextField?.tag = indexPath.row
                cell.cellTextField!.returnKeyType = .Next
                self.passwordField = cell.cellTextField
            case 2:
                cell = self.tableView.dequeueReusableCellWithIdentifier("confirmPasswordFieldCell")! as! SMBSignUpTableViewCell
                cell.cellTextField!.delegate = self
                cell.cellTextField?.tag = indexPath.row
                cell.cellTextField!.returnKeyType = .Next
                self.confirmPasswordField = cell.cellTextField
            case 3:
                cell = self.tableView.dequeueReusableCellWithIdentifier("firstNameFieldCell")! as! SMBSignUpTableViewCell
                cell.cellTextField!.delegate = self
                cell.cellTextField?.tag = indexPath.row
                cell.cellTextField!.returnKeyType = .Next
                self.firstNameField = cell.cellTextField
            case 4:
                cell = self.tableView.dequeueReusableCellWithIdentifier("lastNameFieldCell")! as! SMBSignUpTableViewCell
                cell.cellTextField!.delegate = self
                cell.cellTextField?.tag = indexPath.row
                cell.cellTextField!.returnKeyType = .Done
                self.lastNameField = cell.cellTextField
            case 5:
                let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("signUpCell")!
                return cell
            default:
                break
            }
            
            // Disable UITableViewCell Selection Color
            // Circular Array / Social Network Algo / Cycle Sort 
            // Linked List // What Makes good programmer
            // Art of programming
            cell.selectionStyle = .None
            
            return cell
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        

    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.signUpWithFacebookLogin()
        }
        else if (indexPath.section == 1 && indexPath.row == 5) {
            self.submitAction()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTage=textField.tag+1;
        // Try to find next responder
        let nextResponder=textField.superview?.superview?.superview?.viewWithTag(nextTage) as UIResponder!
        
        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    
    func signUpWithFacebookLogin() {
        let hud = MBProgressHUD.HUDwithMessage("Signing Up...", parent: self)
        
        let permissions = ["email", "public_profile", "user_friends"]
        
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user: PFUser?, error: NSError?) -> Void in
            
            if user != nil {
                
                SMBAppDelegate.instance().syncUserInstallation()
                
                SMBFriendsManager.sharedManager().loadObjects(nil)
                SMBFriendRequestsManager.sharedManager().loadObjects(nil)
                SMBChatManager.sharedManager().loadObjects(nil)
                
                // New User
                if user!.isNew || !(user as! SMBUser).isConfirmed {
                    
                    SMBUser.currentUser().syncWithFacebook({ (succeeded: Bool) -> Void in
                        
                        if succeeded {
                            
                            hud.dismissQuickly()
                            self.performSegueWithIdentifier("enterPhoneNumber", sender: nil)
                            
//                            self.navigationController?.pushViewController(SMBPhoneNumbeVerificationViewController(), animated: true)
                        }
                        else {
                            hud.dismissWithError()
                        }
                    })
                }
                else {
                    hud.dismissQuickly()
                    // Go to Home Screen
                    SMBAppDelegate.instance().animateToMain()
                }
            }
            else {
                print("ERROR: \(error)")
                hud.dismissWithError()
            }
            
        })
    }
    
    // MARK: - User Actions
    
     func submitAction() {
        
        // Validate name
        
        if self.firstNameField!.text!.characters.count < 2 {
            MBProgressHUD.showMessage("Please enter your name", parent: self)
            return
        }
        if self.lastNameField!.text!.characters.count < 2 {
            MBProgressHUD.showMessage("Please enter your name", parent: self)
            return
        }
        
        // Validate email
        
        if self.emailField!.text!.characters.count == 0 {
            MBProgressHUD.showMessage("Please enter your email", parent: self)
            return
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailTest.evaluateWithObject(self.emailField!.text) {
            MBProgressHUD.showMessage("Please enter your email", parent: self)
            return
        }
        
        // Validate password
        
        if self.passwordField!.text!.characters.count < 6 {
            MBProgressHUD.showMessage("Passwords need to be longer", parent: self)
            return
        }
        else {
            if(self.passwordField?.text != self.confirmPasswordField?.text){
                return
            }
        }
        
        // All good! Sign up and push
        
        let newUser = SMBUser()
        newUser.firstName = self.firstNameField!.text
        newUser.lastName = self.lastNameField!.text
        newUser.email = self.emailField!.text!.lowercaseString
        newUser.username = self.emailField!.text!.lowercaseString
        newUser.password = self.passwordField!.text
        
        print(newUser)
        
        let hud = MBProgressHUD.HUDwithMessage("Signing Up...", parent: self)
        
        newUser.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            
            if succeeded {
                
                SMBUser.currentUser().fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
                    
                    if object != nil {
                        
                        SMBAppDelegate.instance().syncUserInstallation()
                        
                        SMBFriendsManager.sharedManager().loadObjects(nil)
                        SMBFriendRequestsManager.sharedManager().loadObjects(nil)
                        SMBChatManager.sharedManager().loadObjects(nil)
                        
                        hud.dismissQuickly()
                        
                        self.navigationController!.pushViewController(SMBPhoneNumbeVerificationViewController(), animated: true)
                    }
                    else {
                        print("ERROR: \(error)")
                        hud.dismissWithError()
                    }
                })
            }
            else {
                print("ERROR: \(error)")
                hud.dismissWithError()
            }
        }
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

}