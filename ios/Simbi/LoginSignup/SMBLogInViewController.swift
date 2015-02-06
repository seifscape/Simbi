//
//  SMBLogInViewController.swift
//  Simbi
//
//  Created by flynn on 10/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBLogInViewController: SMBFormViewController {
    
    let backgroundImageView = UIImageView()
    
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    
    
    // MARK: - ViewController Lifecycle
    
    override convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func loadView() {
        super.loadView()
        
        backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        backgroundImageView.image = UIImage(named: "signin_background")
        self.view.addSubview(backgroundImageView)
        
        emailTextField.placeholder = "Enter Email"
        emailTextField.keyboardType = .EmailAddress
        emailTextField.autocorrectionType = .No
        
        passwordTextField.placeholder = "Enter Password"
        passwordTextField.secureTextEntry = true
    }
    
    
    // MARK: - SMBFormViewController
    
    override func rowsInForm() -> Int {
        return 2
    }
    
    
    override func titleForRow(row: Int) -> String {
        
        switch row {
        case 0: return "Email"
        case 1: return "Password"
        default: return ""
        }
    }
    
    
    override func textFieldForRow(row: Int) -> UITextField? {
        
        switch row {
        case 0: return emailTextField
        case 1: return passwordTextField
        default: return UITextField()
        }
    }
    
    
    override func hasAlternateSubmitButton() -> Bool {
        return true
    }
    
    
    override func submitButtonTitle() -> String {
        return "Log In"
    }
    
    
    override func alternateSubmitButtonTitle() -> String {
        return "Log In with Facebook"
    }
    
    
    override func alternateSubmitButtonColor() -> UIColor {
        return UIColor.facebookColor()
    }
    
    
    // MARK: - User Actions
    
    override func submitAction() {
    
        let hud = MBProgressHUD.HUDwithMessage("Logging In...", parent: self)
        
        SMBUser.logInWithUsernameInBackground(emailTextField.text.lowercaseString, password: passwordTextField.text) { (user: PFUser?, error: NSError!) -> Void in
            
            if user != nil {
                
                hud.dismissQuickly()
                
                if (user as SMBUser).isConfirmed {
                    
                    SMBAppDelegate.instance().syncUserInstallation()
                    
                    SMBFriendsManager.sharedManager().loadObjects(nil)
                    SMBFriendRequestsManager.sharedManager().loadObjects(nil)
                    SMBChatManager.sharedManager().loadObjects(nil)
                    
                    SMBAppDelegate.instance().animateToMain()
                }
                else {
                    hud.dismissQuickly()
                    self.navigationController!.pushViewController(SMBConfirmPhoneViewController(), animated: true)
                }
            }
            else {
                println("ERROR: \(error)")
                
                if error.code == kPFErrorObjectNotFound {
                    hud.dismissWithMessage("Couldn't Log In!")
                }
                else {
                    hud.dismissWithError()
                }
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
