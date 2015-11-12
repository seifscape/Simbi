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
    let helloTextField = UITextField()
    
    
    // MARK: - ViewController Lifecycle
    convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func loadView() {
        super.loadView()
        backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        backgroundImageView.image = UIImage(named: "signin_background")
        self.view.addSubview(backgroundImageView)
        
        emailTextField.placeholder = "Enter Email"
       // emailTextField.text = "cht@cht.com"
        emailTextField.keyboardType = .EmailAddress
        emailTextField.autocorrectionType = .No
        
        passwordTextField.placeholder = "Enter Password2"
        //passwordTextField.text = "111111"
        passwordTextField.secureTextEntry = true
        
        helloTextField.placeholder = "hello"
    }
    
    
    // MARK: - SMBFormViewController
    
    override func rowsInForm() -> Int {
        return 3
    }
    
    
    override func titleForRow(row: Int) -> String {
        
        switch row {
        case 0: return "Email"
        case 1: return "Password"
        case 2: return "hello"
        default: return ""
        }
    }
    
    
    override func textFieldForRow(row: Int) -> UITextField? {
        
        switch row {
        case 0: return emailTextField
        case 1: return passwordTextField
        case 2: return helloTextField
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
        //get the info in the input field
        print("email:"+textFieldForRow(0)!.text!)
        print("pass:"+textFieldForRow(1)!.text!)
        print("email:"+textFieldForRow(2)!.text!)
        
    
        let password = self.passwordTextField.text
        let email = self.emailTextField.text
        let hello = self.helloTextField.text
        let hud = MBProgressHUD.HUDwithMessage("Logging In...", parent: self)

        SMBUser.logInWithUsernameInBackground(textFieldForRow(0)!.text!.lowercaseString, password: textFieldForRow(1)!.text!) { (user: PFUser?, error: NSError?) -> Void in
            
            if user != nil {
                
                hud.dismissQuickly()
                
                if (user as! SMBUser).isConfirmed {
                    print("aboutme:")
                    print((user as! SMBUser).aboutme)
                    print("=======")
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
                print("ERROR: \(error)")
                
                if error!.code == 0/*kPFErrorObjectNotFound*/ {//modified by zhy
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
}
