//
//  SMBPhoneNumbeVerificationViewController.swift
//  Simbi
//
//  Created by Seif Kobrosly on 12/1/15.
//  Copyright © 2015 SimbiSocial. All rights reserved.
//

import UIKit
// blog.ios-developers.io

class SMBPhoneNumbeVerificationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var numberField: UITextField?
    @IBOutlet weak var dismissBtn: UIButton?

    var pNumber:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.numberField?.delegate = self
        self.numberField?.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)


    }
    
    @IBAction func cancel(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

/*
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        
        if (newLength == 10) {
            textField.resignFirstResponder()
            return newLength ==  10 // Bool
        }
        else {
            return true
        }
    }
*/
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text != ""){
            textField.text = ""
        }
    }

    
    func textFieldDidChange(textField: UITextField) {
        //your code
        let phoneUtil = NBPhoneNumberUtil()
        var formattedString: String = ""
        
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(numberField!.text, defaultRegion: "US")
            formattedString = try phoneUtil.format(phoneNumber, numberFormat: .E164)
            
            NSLog("[%@]", formattedString)
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        if(textField.text?.characters.count == 10){
            self.numberField?.text = formattedString
            textField.resignFirstResponder()
        }
    }
    
    
    @IBAction func sumbitPhoneNumber(){
        let phoneNumber = self.numberField!.text!.stringByReplacingOccurrencesOfString("[^0-9]*",
            withString: "",
            options: .RegularExpressionSearch,
            range: Range(start: self.numberField!.text!.startIndex, end: self.numberField!.text!.endIndex)
        )
        
        if phoneNumber.characters.count  == 11 {
            
            let hud = MBProgressHUD.HUDwithMessage("Sending Confirmation Code...", parent: self)
            
            let query = PFQuery(className: "_User")
            query.whereKey("phoneNumber", equalTo: phoneNumber)
            
            let params: [String: AnyObject] = ["phoneNumber": phoneNumber]
            
            PFCloud.callFunctionInBackground("phoneNumberExists", withParameters: params, block: { (response: AnyObject?, error: NSError?) -> Void in
                
                if response != nil {
                    if response as! String == "NO" {
                        let params = ["phoneNumber": phoneNumber]
                        PFCloud.callFunctionInBackground("sendConfirmationCode", withParameters: params, block: { (result: AnyObject?, error: NSError?) -> Void in
                            if (error == nil) {
                                hud.dismissQuickly()
                                SMBUser.currentUser().confirmingPhoneNumber = phoneNumber
                                self.performSegueWithIdentifier("validateSMS", sender: nil)
//                                self.navigationController!.pushViewController(SMBValidateSMSCodeViewController(), animated: true)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        let svc = segue.destinationViewController as! SMBValidateSMSCodeViewController;
//
//        if (segue.identifier == "validateSMS") {
//            self.navigationController?.pushViewController(svc, animated: true)
//        }
//    }
}
