//
//  SMBConfirmSMSViewController.swift
//  Simbi
//
//  Created by Seif Kobrosly on 12/4/15.
//  Copyright © 2015 SimbiSocial. All rights reserved.
//

import UIKit

class SMBConfirmSMSViewController: UIViewController {

    @IBOutlet weak var dismissBtn: UIButton?
    @IBOutlet weak var smsCodeField: UITextField?
    @IBOutlet weak var validateButton: UIButton?
    @IBOutlet weak var resendCodeButton: UIButton?



    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        if((self.presentingViewController) != nil){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func validateCode() {
        
        if smsCodeField!.text!.characters.count != 0 {
            
            self.view.endEditing(true)
            
            let hud = MBProgressHUD.HUDwithMessage("Confirming...", parent: self)
            
            let params = ["confirmationCode": smsCodeField!.text!] as [NSObject : AnyObject]
            //            let params = NSMutableDictionary()
            //            params.setObject( "confirmationCode", forKey: codeTextField.text! )
            
            
            PFCloud.callFunctionInBackground("checkConfirmationCode", withParameters: params, block: { (result: AnyObject?, error: NSError?) -> Void in
                
                if result != nil && error == nil {
                    
                    SMBUser.currentUser().removeObjectForKey("confirmingPhoneNumber")
                    SMBUser.currentUser().isConfirmed = true
                
                    hud.dismissQuickly()
//                    self.dismissViewController(self)
                    self.performSegueWithIdentifier("profileSetup", sender: nil)
//                    self.navigationController!.pushViewController(ProfileSetupViewController(), animated: true)
//                    self.navigationController!.pushViewController(ProfileSetupViewController(), animated: true)

                }
                else {
                    hud.dismissWithMessage("Try Again!")
                }
            })
        }
    }
    
    
    @IBAction func resendSMSCode() {
        
        if SMBUser.currentUser().confirmingPhoneNumber != nil {
            
            let hud = MBProgressHUD.HUDwithMessage("Resending...", parent: self)
            
            let params = ["phoneNumber": SMBUser.currentUser().confirmingPhoneNumber] as [NSObject : AnyObject]
            
            PFCloud.callFunctionInBackground("sendConfirmationCode", withParameters: params, block: { (result: AnyObject?, error: NSError?) -> Void in
                
                if error == nil {
                    hud.dismissWithMessage("Sent!")
                }
                else {
                    hud.dismissWithError()
                }
            })
        }
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

