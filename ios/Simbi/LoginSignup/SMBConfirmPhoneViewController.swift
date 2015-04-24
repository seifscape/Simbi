//
//  SMBConfirmPhoneViewController.swift
//  Simbi
//
//  Created by flynn on 10/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBConfirmPhoneViewController: SMBFormViewController {
    
    let backgroundImageView = UIImageView()
    
    let countryTextField = UITextField()
    let phoneNumberTextField = UITextField()
    
    let countryPickerView = UIView()
    var phoneNumber = ""
    var intCode = "1"
    
    // MARK: - ViewController Lifecycle
    
    convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func loadView() {
        super.loadView()
        
        backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        backgroundImageView.image = UIImage(named: "exploding_phone")
        self.view.addSubview(backgroundImageView)
        
        countryTextField.text = "United States (+1)"
        countryTextField.placeholder = "Select Country"
        countryTextField.clipsToBounds = true
        
        let countryButton = UIButton(frame: CGRectMake(0, 0, self.view.frame.width, 88))
        countryButton.addTarget(self, action: "selectCountryAction:", forControlEvents: .TouchUpInside)
        countryTextField.addSubview(countryButton)
        
        phoneNumberTextField.keyboardType = .NumberPad
        phoneNumberTextField.placeholder = "Enter Number"
        phoneNumberTextField.text = "+1 "
        
        
        countryPickerView.frame = CGRectMake(0, self.view.frame.height-176, self.view.frame.width, 176)
        countryPickerView.backgroundColor = UIColor.simbiWhiteColor()
        
        let countryPicker = SMBCountryPicker(frame: CGRectMake(0, 0, self.view.frame.width, 176))
        countryPicker.countryPickerDelegate = self
        countryPickerView.addSubview(countryPicker)
        
        countryPickerView.hidden = true
        UIApplication.sharedApplication().keyWindow!.addSubview(countryPickerView)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        countryPickerView.hidden = true
        UIApplication.sharedApplication().keyWindow!.addSubview(countryPickerView)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        countryPickerView.removeFromViewAndAnimate(true)
    }
    
    
    // MARK: - SMBFormViewController
    
    override func rowsInForm() -> Int {
        return 2
    }
    
    
    override func titleForRow(row: Int) -> String {
        
        switch row {
        case 0: return "Country"
        case 1: return "Phone Number"
        default: return ""
        }
    }
    
    
    override func textFieldForRow(row: Int) -> UITextField? {
        
        switch row {
        case 0: return countryTextField
        case 1: return phoneNumberTextField
        default: return UITextField()
        }
    }
    
    
    override func hasAlternateSubmitButton() -> Bool {
        return false
    }
    
    
    override func submitButtonTitle() -> String {
        return "Send Confirmation Code"
    }
    
    
    override func tapOutAction(sender: AnyObject) {
        super.tapOutAction(sender)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.countryPickerView.alpha = 0
            }) { (Bool) -> Void in
                self.countryPickerView.hidden = true
        }
    }
    
    
    override func keyboardWillShow(notification: NSNotification) {
        super.keyboardWillShow(notification)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.countryPickerView.alpha = 0
        }) { (Bool) -> Void in
            self.countryPickerView.hidden = true
        }
    }
    
    
    // MARK: - User Actions
    
    func selectCountryAction(sender: AnyObject) {

        self.view.endEditing(true)
        
        countryPickerView.alpha = 0
        countryPickerView.hidden = false
        
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.countryPickerView.alpha = 1
        })
    }
    
    
    override func backAction(sender: AnyObject) {
        super.backAction(sender)
        
        if SMBUser.currentUser().isAuthenticated() && self.navigationController!.visibleViewController is SMBSignUpViewController {
            
            SMBUser.currentUser().deleteInBackgroundWithBlock { (succeeded, error) -> Void in
                
                if !succeeded {
                    let user = SMBUser.currentUser()
                    //user.deleteEventually()
                }
                SMBUser.logOut()
            }
        }
    }
    
    
    override func submitAction() {
        
        var phoneNumber = phoneNumberTextField.text.stringByReplacingOccurrencesOfString("[^0-9]*",
            withString: "",
            options: .RegularExpressionSearch,
            range: Range(start: phoneNumberTextField.text.startIndex, end: phoneNumberTextField.text.endIndex)
        )
        
        println("phoneNumber: \(phoneNumber)")
        
        if count(phoneNumber) == 11 {
            
            self.view.endEditing(true)
            
            let hud = MBProgressHUD.HUDwithMessage("Sending Confirmation Code...", parent: self)
            
            let query = PFQuery(className: "_User")
            query.whereKey("phoneNumber", equalTo: phoneNumber)
            
            let params: [String: AnyObject] = ["phoneNumber": phoneNumber]
            
            PFCloud.callFunctionInBackground("phoneNumberExists", withParameters: params, block: { (response, error) -> Void in
                
                if response != nil {
                    
                    if response as! String == "NO" {
                        
                        let params = ["phoneNumber": phoneNumber]
                        
                        PFCloud.callFunctionInBackground("sendConfirmationCode", withParameters: params, block: { (result, error) -> Void in
                            
                            if error == nil {
                                
                                hud.dismissQuickly()
                                
                                SMBUser.currentUser().confirmingPhoneNumber = phoneNumber
                                
                                self.navigationController!.pushViewController(SMBConfirmationCodeViewController(), animated: true)
                            }
                            else {
                                hud.dismissWithError()
                            }
                        })
                    }
                    else {
                        hud.dismissWithMessage("Phone Number Registered")
                    }
                }
                else {
                    hud.dismissWithError()
                }
            })
        }
    }
    
    
    // MARK: - UITextFieldDelegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
        if textField == phoneNumberTextField {
            
            var str: String
            if count(string) > 0 {
                str = phoneNumber + string
            }
            else if count(phoneNumber) > 0 {
                str = phoneNumber.substringWithRange(Range(
                    start: phoneNumber.startIndex,
                    end: advance(phoneNumber.endIndex, -1)
                ))
            }
            else {
                str = phoneNumber
            }
            
            
            var nStr = str.stringByReplacingOccurrencesOfString("[^0-9]*",
                withString: "",
                options: .RegularExpressionSearch,
                range: Range(start: str.startIndex, end: str.endIndex)
            )
            
            if count(nStr) > 10 {
                nStr = nStr.substringWithRange(Range(
                    start: nStr.startIndex,
                    end: advance(nStr.startIndex, 10)
                ))
            }
            
            phoneNumber = nStr
            
            textField.text = formatPhoneNumber(phoneNumber, intCode: intCode)
            
            return false
        }
        else {
            return true
        }
    }
    
    
    func formatPhoneNumber(phoneNumber: String, intCode: String) -> String {
        
        var pStr = phoneNumber
        
        if count(pStr) >= 3 {
            pStr.insert(" ", atIndex: advance(pStr.startIndex, 3))
        }
        
        if count(pStr) >= 7 {
            pStr.insert(" ", atIndex: advance(pStr.startIndex, 7))
        }
        
        return "+\(intCode) \(pStr)"
    }
}


extension SMBConfirmPhoneViewController: SMBCountryPickerDelegate {
    
    func countryPickerDidSelectItem(country: String, codeNum: Int, codeStr: String) {
        
        countryTextField.text = "\(country) (+\(codeStr))"
        self.intCode = codeStr
        phoneNumberTextField.text = formatPhoneNumber(phoneNumber, intCode: codeStr)
    }
}

