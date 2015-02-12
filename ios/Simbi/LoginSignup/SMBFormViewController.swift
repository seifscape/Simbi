//
//  SMBFormViewController.swift
//  Simbi
//
//  Created by flynn on 10/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBFormViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellHeight: CGFloat = 66
    
    let contentView = UIView()
    let tableView = UITableView()
    let backButton = UIButton()
    
    var focusedTextField: UITextField?
    var keyboardHeight: CGFloat = 0
    var keyboardIsShown = false
    
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(contentView)
        
        let tapOutButton = UIButton(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        tapOutButton.addTarget(self, action: "tapOutAction:", forControlEvents: .TouchUpInside)
        contentView.addSubview(tapOutButton)
        
        let tableViewHeight = cellHeight * (rowsInForm()+1).CG
        
        tableView.frame = CGRectMake(
            20,
            (self.view.frame.height-tableViewHeight-20-44)/2,
            self.view.frame.width-40,
            tableViewHeight
        )
        tableView.center = self.view.center
        tableView.dataSource = self
        tableView.delegate = self
        tableView.scrollEnabled = false
        tableView.separatorColor = UIColor.clearColor()
        contentView.addSubview(tableView)
        
        if hasAlternateSubmitButton() {
            
            tableView.center = CGPointMake(self.view.frame.width/2, (self.view.frame.height-20-44)/2)
            
            let alternateSubmitButton = UIButton(frame: CGRectMake(
                20,
                tableView.frame.origin.y+tableView.frame.height+20,
                self.view.frame.width-40,
                44))
            alternateSubmitButton.backgroundColor = alternateSubmitButtonColor()
            alternateSubmitButton.setTitle(alternateSubmitButtonTitle(), forState: .Normal)
            alternateSubmitButton.setTitleColor(alternateSubmitTitleColor(), forState: .Normal)
            alternateSubmitButton.titleLabel?.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 18)
            alternateSubmitButton.addTarget(self, action: "alternateSubmitAction", forControlEvents: .TouchUpInside)
            contentView.addSubview(alternateSubmitButton)
        }
        
        
        if self != self.navigationController?.viewControllers.first as UIViewController {
            
            backButton.frame = CGRectMake(0, 20, 66, 44)
            backButton.setTitle("Back", forState: .Normal)
            backButton.setTitleColor(UIColor.simbiWhiteColor(), forState: .Normal)
            backButton.titleLabel?.font = UIFont.simbiFontWithSize(18)
            backButton.addTarget(self, action: "backAction:", forControlEvents: .TouchUpInside)
            self.view.addSubview(backButton)
        }
        
        
        // Subscribe to keyboard notifications
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        SMBAppDelegate.instance().enableSideMenuGesture(false)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func styleTextField(textField: UITextField) {
        
        textField.textColor = UIColor.simbiBlackColor()
        textField.font = UIFont.simbiFontWithSize(18)
    }
    
    
    // MARK: - User Actions
    
    func backAction(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    func tapOutAction(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Methods to Override
    
    func rowsInForm()                   -> Int          { return 0                         }
    func titleForRow(row: Int)          -> String       { return "Title"                   }
    func textFieldForRow(row: Int)      -> UITextField? { return UITextField()             }
    func hasAlternateSubmitButton()     -> Bool         { return true                      }
    func submitButtonTitle()            -> String       { return "Submit"                  }
    func alternateSubmitButtonTitle()   -> String       { return "Submit With ..."         }
    func alternateSubmitButtonColor()   -> UIColor      { return UIColor.simbiBlueColor()  }
    func alternateSubmitTitleColor()    -> UIColor      { return UIColor.simbiWhiteColor() }

    func submitAction()          { }
    func alternateSubmitAction() { }
    
    
    // MARK: Keyboard Handling
    
    func keyboardWillShow(notification: NSNotification) {
        keyboardIsShown = true
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        keyboardHeight = frame.height
        
        adjustForm()
        
        backButton.removeFromViewAndAnimate(true)
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        keyboardIsShown = false
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            
            self.tableView.center = self.hasAlternateSubmitButton() ?
                CGPointMake(self.view.frame.width/2, (self.view.frame.height-20-44)/2) : self.view.center
            
        }, completion: nil)
        
        backButton.addToView(self.view, andAnimate: true)
    }
    
    
    func adjustForm() {
        
        let offset = focusedTextField != nil ? focusedTextField!.tag.CG * cellHeight : 0
        
        let yPos = (self.view.frame.height-self.keyboardHeight-self.cellHeight)/2-offset
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            
            self.tableView.frame = CGRectMake(
                self.tableView.frame.origin.x,
                yPos,
                self.tableView.frame.width,
                self.tableView.frame.height
            )
        }, completion: nil)
    }
}


// MARK: - UITableViewDataSource/Delegate

extension SMBFormViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInForm()+1
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.selectionStyle = .None
        
        if indexPath.row < rowsInForm() {
            
            cell.backgroundColor = UIColor.simbiWhiteColor()
            
            let label = UILabel(frame: CGRectMake(20, 0, tableView.frame.width-40, 28))
            label.text = titleForRow(indexPath.row).uppercaseString
            label.textColor = UIColor.simbiBlackColor()
            label.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 14)
            cell.contentView.addSubview(label)
            
            if let textField = textFieldForRow(indexPath.row) {
                styleTextField(textField)
                textField.tag = indexPath.row
                textField.delegate = self
                textField.frame = CGRectMake(20, 22, tableView.frame.width-40, 44)
                cell.contentView.addSubview(textField)
            }
            
            let bottomLineView = UIView(frame: CGRectMake(0, 65, tableView.frame.width, 1))
            bottomLineView.backgroundColor = UIColor.simbiLightGrayColor()
            bottomLineView.userInteractionEnabled = false
            cell.contentView.addSubview(bottomLineView)
        }
        else {
            
            cell.backgroundColor = UIColor.simbiBlueColor()
            
            cell.textLabel.text = submitButtonTitle()
            cell.textLabel.textColor = UIColor.simbiWhiteColor()
            cell.textLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 18)
            cell.textLabel.textAlignment = .Center
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == rowsInForm() {
            submitAction()
        }
    }
}


// MARK: - UITextFieldDelegate

extension SMBFormViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        focusedTextField = textField
        
        if keyboardIsShown {
            adjustForm()
        }
        return true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

