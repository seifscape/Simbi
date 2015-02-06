//
//  SMBLabeledSlider.swift
//  Simbi
//
//  Created by flynn on 11/9/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


enum SMBLabeledSliderSide {
    
    // Note: Top and Bottom currently unsupported
    
    //case Top
    //case Bottom
    
    case Right
    case Left
}


class SMBLabeledSlider: UIView {
    
    
    let slider = UISlider()
    let labelSide: SMBLabeledSliderSide
    let labelContainerView = UIView()
    let label = UILabel()
    
    var values: [(String, Double)]? {
        didSet {
            slider.maximumValue = values != nil ? Float(values!.count)-0.01 : 0
            slider.value = values != nil ? Float(values!.count/2) : 0
        }
    }
    
    
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(frame: CGRect, labelSide: SMBLabeledSliderSide) {
        
        self.labelSide = labelSide
        
        super.init(frame: frame)
        
        slider.frame = CGRectMake(0, 0, frame.width, frame.height)
        slider.tintColor = UIColor.simbiBlueColor()
        
        if labelSide == .Left || labelSide == .Right {
            slider.transform = CGAffineTransformMakeRotation(-M_PI_2.CG)
            slider.frame = CGRectMake(0, 0, frame.width, frame.height)
        }
        
        slider.minimumValue = 0
        slider.maximumValue = 0
        
        slider.addTarget(self, action: "sliderDidChange:", forControlEvents: .ValueChanged)
        slider.addTarget(self, action: "sliderDidFinish:", forControlEvents: .TouchUpInside)
        slider.addTarget(self, action: "sliderDidFinish:", forControlEvents: .TouchUpOutside)
        
        self.addSubview(slider)
        
        labelContainerView.frame = CGRectMake(0, 0, 88, 38)
        labelContainerView.backgroundColor = UIColor.simbiLightGrayColor()
        labelContainerView.layer.cornerRadius = 4
        labelContainerView.layer.shadowColor = UIColor.blackColor().CGColor
        labelContainerView.layer.shadowOffset = CGSizeMake(2, 2)
        labelContainerView.layer.shadowOpacity = 0.25
        labelContainerView.hidden = true
        
        label.frame = labelContainerView.frame
        label.textColor = UIColor.simbiDarkGrayColor()
        label.font = UIFont.simbiFontWithSize(14)
        label.textAlignment = .Center
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        labelContainerView.addSubview(label)
        
        let sliderPoint = UIView(frame: CGRectMake(-4, 14, 8, 8))
        if labelSide == .Left {
            sliderPoint.frame = CGRectMake(labelContainerView.frame.width-4, 14, 8, 8)
        }
        sliderPoint.backgroundColor = UIColor.simbiLightGrayColor()
        sliderPoint.transform = CGAffineTransformMakeRotation(M_PI_4.CG)
        labelContainerView.insertSubview(sliderPoint, belowSubview: label)
        
        self.addSubview(labelContainerView)
    }
    
    
    func selectedItem() -> (String, Double) {
        
        if let values = self.values {
            return values[Int(floor(slider.value))]
        }
        else {
            return ("", 0)
        }
    }

    
    func sliderDidChange(slider: UISlider) {
        
        if let values = self.values {
            
            if labelContainerView.hidden {
                labelContainerView.alpha = 0
                labelContainerView.hidden = false
                UIView.animateWithDuration(0.125, animations: { () -> Void in
                    self.labelContainerView.alpha = 1
                })
            }
            
            let percentValue = CGFloat( 1-(slider.value-slider.minimumValue)/(slider.maximumValue-slider.minimumValue) )
            
            labelContainerView.frame = CGRectMake(
                labelSide == .Left ? -labelContainerView.frame.width : self.frame.width,
                (self.frame.height-36)*percentValue,
                labelContainerView.frame.width,
                labelContainerView.frame.height
            )
            
            let (text, value) = selectedItem()
            
            label.text = text
        }
    }
    
    
    func sliderDidFinish(slider: UISlider) {
        
        UIView.animateWithDuration(0.125, animations: { () -> Void in
            self.labelContainerView.alpha = 0
        }) { (Bool) -> Void in
            self.labelContainerView.hidden = true
        }
    }
}
