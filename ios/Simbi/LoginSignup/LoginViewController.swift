//
//  LoginViewController.swift
//  Simbi
//
//  Created by Seif Kobrosly on 3/24/16.
//  Copyright © 2016 SimbiSocial. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
//import FBSDKCoreKit
//import ParseFacebookUtilsV4


class LoginViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var backgroundImage: UIImageView?
    @IBOutlet weak var dismissBtn: UIButton?
    @IBOutlet weak var quicklyUILabel: UILabel?
    
    weak var emailField: UITextField?
    weak var passwordField: UITextField?
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint?

    var itemsString: [String] = ["Email", "Password"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0);
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.clearColor()
        quicklyUILabel?.text = "Quickly login with:"
        quicklyUILabel?.sizeToFit()



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
                let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("loginCell")!
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
        
        UIView.animateWithDuration(0, animations: {
            self.tableViewHeightConstraint!.constant = height;
            self.view.setNeedsUpdateConstraints();
            self.view.layoutIfNeeded();
        })
        
        
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

    }
    
    // MARK: - User Actions
    
    func submitAction() {

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
