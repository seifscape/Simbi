//
//  SMBCellTextField.swift
//  Simbi
//
//  Created by Seif Kobrosly on 11/20/15.
//  Copyright © 2015 SimbiSocial. All rights reserved.
//

import UIKit

class SMBCellTextField: UITextField {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let paddingFrame : CGRect = CGRectMake(0,0,20,20)
        let paddingView : UIView = UIView(frame: paddingFrame)
        self.leftView = paddingView
        self.leftViewMode = UITextFieldViewMode.Always
    }


}
