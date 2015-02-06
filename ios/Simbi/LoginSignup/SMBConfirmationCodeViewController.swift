//
//  SMBConfirmationCodeViewController.swift
//  Simbi
//
//  Created by flynn on 10/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBConfirmationCodeViewController: SMBFormViewController {
    
    let backgroundImageView = UIImageView()
    
    let codeTextField = UITextField()
    
    
    // MARK: - ViewController Lifecycle
    
    override convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func loadView() {
        super.loadView()
        
        backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        backgroundImageView.image = UIImage(named: "exploding_phone")
        self.view.addSubview(backgroundImageView)
        
        codeTextField.placeholder = "Enter Code"
        codeTextField.keyboardType = .NumberPad
    }
    
    
    // MARK: - SMBFormViewController
    
    override func rowsInForm() -> Int {
        return 1
    }
    
    
    override func titleForRow(row: Int) -> String {
        return "Confirmation Code"
    }
    
    
    override func textFieldForRow(row: Int) -> UITextField? {
        return codeTextField
    }
    
    
    override func hasAlternateSubmitButton() -> Bool {
        return true
    }
    
    
    override func submitButtonTitle() -> String {
        return "Confirm Number"
    }
    
    
    override func alternateSubmitButtonColor() -> UIColor {
        return UIColor.simbiWhiteColor()
    }
    
    
    override func alternateSubmitTitleColor() -> UIColor {
        return UIColor.simbiBlackColor()
    }
    
    
    override func alternateSubmitButtonTitle() -> String {
        return "Resend Code"
    }
    
    
    // MARK: - User Actions
    
    override func submitAction() {
        
        if countElements(codeTextField.text) != 0 {
            
            self.view.endEditing(true)
            
            let hud = MBProgressHUD.HUDwithMessage("Confirming...", parent: self)
        
            let params = ["confirmationCode": codeTextField.text]
            
            PFCloud.callFunctionInBackground("checkConfirmationCode", withParameters: params, block: { (result: AnyObject!, error: NSError!) -> Void in
                
                if result != nil && error == nil {
                    
                    SMBUser.currentUser().removeObjectForKey("confirmingPhoneNumber")
                    SMBUser.currentUser().isConfirmed = true
                    
                    hud.dismissQuickly()
                    self.navigationController!.pushViewController(SMBAccountInfoViewController(), animated: true)
                }
                else {
                    hud.dismissWithMessage("Try Again!")
                }
            })
        }
    }
    
    
    override func alternateSubmitAction() {
        
        if SMBUser.currentUser().confirmingPhoneNumber != nil {
            
            let hud = MBProgressHUD.HUDwithMessage("Resending...", parent: self)
            
            let params = ["phoneNumber": SMBUser.currentUser().confirmingPhoneNumber]
            
            PFCloud.callFunctionInBackground("sendConfirmationCode", withParameters: params, block: { (result: AnyObject!, error: NSError!) -> Void in
                
                if error == nil {
                    hud.dismissWithMessage("Sent!")
                }
                else {
                    hud.dismissWithError()
                }
            })
        }
    }
}
