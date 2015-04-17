//
//  SMBSignUpViewController.swift
//  Simbi
//
//  Created by flynn on 10/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBSignUpViewController: SMBFormViewController {
    
    let backgroundImageView = UIImageView()
    
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    
    
    // MARK: - ViewController Lifecycle
    
    convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func loadView() {
        super.loadView()
        
        backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        backgroundImageView.image = UIImage(named: "signin_background")
        self.view.addSubview(backgroundImageView)
        
        firstNameTextField.placeholder = "Enter Name"
        lastNameTextField.placeholder = "Enter Name"
        
        emailTextField.placeholder = "Enter Email"
        emailTextField.keyboardType = .EmailAddress
        emailTextField.autocorrectionType = .No
        
        passwordTextField.placeholder = "Enter Password"
        passwordTextField.secureTextEntry = true
    }
    
    
    // MARK: - SMBFormViewController
    
    override func rowsInForm() -> Int {
        return 4
    }
    
    
    override func titleForRow(row: Int) -> String {
        
        switch row {
        case 0: return "First Name"
        case 1: return "Last Name"
        case 2: return "Email"
        case 3: return "Password"
        default: return ""
        }
    }
    
    
    override func textFieldForRow(row: Int) -> UITextField? {
        
        switch row {
        case 0: return firstNameTextField
        case 1: return lastNameTextField
        case 2: return emailTextField
        case 3: return passwordTextField
        default: return UITextField()
        }
    }
    
    
    override func hasAlternateSubmitButton() -> Bool {
        return true
    }
    
    
    override func submitButtonTitle() -> String {
        return "Sign Up"
    }
    
    
    override func alternateSubmitButtonTitle() -> String {
        return "Sign Up with Facebook"
    }
    
    
    override func alternateSubmitButtonColor() -> UIColor {
        return UIColor.facebookColor()
    }
    
    
    // MARK: - User Actions
    
    override func submitAction() {
        
        // Validate name
        
        if count(firstNameTextField.text) < 2 {
            MBProgressHUD.showMessage("Please enter your name", parent: self)
            return
        }
        if count(lastNameTextField.text) < 2 {
            MBProgressHUD.showMessage("Please enter your name", parent: self)
            return
        }
        
        // Validate email
        
        if count(emailTextField.text) == 0 {
            MBProgressHUD.showMessage("Please enter your email", parent: self)
            return
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailTest.evaluateWithObject(emailTextField.text) {
            MBProgressHUD.showMessage("Please enter your email", parent: self)
            return
        }
        
        // Validate password
        
        if count(passwordTextField.text) < 6 {
            MBProgressHUD.showMessage("Passwords need to be longer", parent: self)
            return
        }
        
        // All good! Sign up and push
        
        let newUser = SMBUser()
        newUser.firstName = firstNameTextField.text
        newUser.lastName = lastNameTextField.text
        newUser.email = emailTextField.text.lowercaseString
        newUser.username = emailTextField.text.lowercaseString
        newUser.password = passwordTextField.text
        
        let hud = MBProgressHUD.HUDwithMessage("Signing Up...", parent: self)
        
        newUser.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            
            if succeeded {
                
                SMBUser.currentUser().fetchInBackgroundWithBlock({ (object: PFObject!, error: NSError!) -> Void in
                    
                    if object != nil {
                        
                        SMBAppDelegate.instance().syncUserInstallation()
                        
                        SMBFriendsManager.sharedManager().loadObjects(nil)
                        SMBFriendRequestsManager.sharedManager().loadObjects(nil)
                        SMBChatManager.sharedManager().loadObjects(nil)
                        
                        hud.dismissQuickly()
                        
                        self.navigationController!.pushViewController(SMBConfirmPhoneViewController(), animated: true)
                    }
                    else {
                        println("ERROR: \(error)")
                        hud.dismissWithError()
                    }
                })
            }
            else {
                println("ERROR: \(error)")
                hud.dismissWithError()
            }
        }
    }
    
    
    override func alternateSubmitAction() {
        
        let hud = MBProgressHUD.HUDwithMessage("Logging In...", parent: self)
        
        let permissions = ["email", "public_profile", "user_friends"]
        
        PFFacebookUtils.logInWithPermissions(permissions, block: { (user: PFUser!, error: NSError!) -> Void in
            
            if user != nil {
                
                SMBAppDelegate.instance().syncUserInstallation()
                
                SMBFriendsManager.sharedManager().loadObjects(nil)
                SMBFriendRequestsManager.sharedManager().loadObjects(nil)
                SMBChatManager.sharedManager().loadObjects(nil)
                
                if user.isNew || !(user as SMBUser).isConfirmed {
                    
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
                println("ERROR: \(error)")
                hud.dismissWithError()
            }
        })
    }
}
