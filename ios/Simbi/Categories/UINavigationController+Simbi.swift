//
//  UINavigationController+Simbi.swift
//  animating-circle
//
//  Created by flynn on 9/15/14.
//  Copyright (c) 2014 mu. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func presentViewControllerByGrowingView(viewController: UIViewController, growingView: UIView) {
        
        var oldViewController = self.visibleViewController!
        
        var oldNavColor = self.view.backgroundColor
        var oldViewColor = growingView.backgroundColor
        
        var vcMax = max(viewController.view.frame.width, viewController.view.frame.height)
        var gvMin = min(growingView.frame.width, growingView.frame.height)
        
        var ratio = vcMax/gvMin + 1
        
        UIView.animateWithDuration(0.33, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                
            growingView.transform = CGAffineTransformMakeScale(ratio, ratio)
            growingView.backgroundColor = viewController.view.backgroundColor
                
        }, completion: { (Bool) -> Void in
            
            self.view.backgroundColor = viewController.view.backgroundColor
            
            viewController.view.alpha = 0
            
            self.presentViewController(viewController, animated: false, completion: nil)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                viewController.view.alpha = 1
                
            }, completion: { (Bool) -> Void in
                
                self.view.backgroundColor = oldNavColor
                growingView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                growingView.backgroundColor = oldViewColor
            })
        })
    }
}
