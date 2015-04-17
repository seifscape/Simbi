//
//  SMBEnterViewController.swift
//  Simbi
//
//  Created by flynn on 10/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBEnterViewController: UIViewController {
    
    let simbiLogoLabel = UILabel()
    let backgroundImageView = UIImageView()
    
    let signUpButton = UIButton()
    let logInButton = UIButton()
    
    // MARK: - ViewController Lifecycle
    
    convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func loadView() {
        super.loadView()
        
        backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        backgroundImageView.image = UIImage(named: "opening_background")
        self.view.addSubview(backgroundImageView)
        
        simbiLogoLabel.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height/2-20)
        simbiLogoLabel.text = "Simbi"
        simbiLogoLabel.textColor = UIColor.simbiWhiteColor()
        simbiLogoLabel.font = UIFont.simbiBoldFontWithSize(72)
        simbiLogoLabel.textAlignment = .Center
        //self.view.addSubview(simbiLogoLabel)
        
        signUpButton.frame = CGRectMake(20, self.view.frame.height-72-12-44, self.view.frame.width-40, 44)
        signUpButton.backgroundColor = UIColor.simbiBlueColor()
        signUpButton.setTitle("Sign Up", forState: .Normal)
        signUpButton.setTitleColor(UIColor.simbiWhiteColor(), forState: .Normal)
        signUpButton.titleLabel?.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 18)
        signUpButton.addTarget(self, action: "signUpAction:", forControlEvents: .TouchUpInside)
        self.view.addSubview(signUpButton)
        
        logInButton.frame = CGRectMake(20, self.view.frame.height-72, self.view.frame.width-40, 44)
        logInButton.backgroundColor = UIColor.simbiWhiteColor()
        logInButton.setTitle("Log In", forState: .Normal)
        logInButton.setTitleColor(UIColor.simbiBlackColor(), forState: .Normal)
        logInButton.titleLabel?.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 18)
        logInButton.addTarget(self, action: "logInAction:", forControlEvents: .TouchUpInside)
        self.view.addSubview(logInButton)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        SMBAppDelegate.instance().enableSideMenuGesture(false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    // MARK: - Public Methods
    
    func pushToConfirmPhone() {
        
        self.navigationController!.pushViewController(SMBLogInViewController(), animated: false)
        self.navigationController!.pushViewController(SMBConfirmPhoneViewController(), animated: false)
    }
    
    
    // MARK: - User Actions
    
    func signUpAction(sender: AnyObject) {
    
        self.navigationController?.pushViewController(SMBSignUpViewController(), animated: true)
    }
    
    
    func logInAction(sender: AnyObject) {
        
        self.navigationController?.pushViewController(SMBLogInViewController(), animated: true)
    }
}
