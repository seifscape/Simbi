//
//  SMB360SwipeControl.swift
//  360control
//
//  Created by flynn on 9/11/14.
//  Copyright (c) 2014 mu. All rights reserved.
//

import CoreGraphics
import QuartzCore
import UIKit


class SMB360SwipeControl : UIControl
{
    let radius: CGFloat = 20.0
    let padding: CGFloat = 33.0
    var unselectedColor = UIColor.whiteColor().colorWithAlphaComponent(0.33)
    var selectedColor = UIColor.whiteColor()
    
    private var controlView: UIView?
    private var isDragging = false
    private var isClockwise = false
    private var startingAngle = 0.0
    private var currentAngle = 0.0
    private var relativeAngle = 0.0
    
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    
    override init(frame: CGRect) {
        // Increase the actual frame to allow touches to extend slightly outside where the control view is.
        super.init(frame: CGRectMake(frame.origin.x-padding, frame.origin.y-padding, frame.width+padding*2, frame.height+padding*2))

        self.backgroundColor = UIColor.clearColor()
        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2.0
        
        controlView = UIView(frame: CGRectMake(0, 0, 66, 66))
        
        let r = Double((self.frame.width-2*padding)/2.0 - radius/2.0)
        let y = r * -sin(7*M_PI/8) + Double(self.frame.width/2.0)
        let x = r *  cos(7*M_PI/8) + Double(self.frame.width/2.0)
        
        controlView!.center = CGPointMake(x.CG, y.CG)
        
        controlView!.backgroundColor = UIColor.simbiBlueColor()
        controlView!.layer.cornerRadius = controlView!.frame.width/2
        controlView!.layer.shadowColor = UIColor.whiteColor().CGColor
        controlView!.layer.shadowOpacity = 1
        controlView!.layer.shadowRadius = 16
        controlView!.layer.shadowOffset = CGSizeZero
        
        let centerView = UIView(frame: CGRectMake(22, 22, 22, 22))
        centerView.backgroundColor = UIColor.simbiWhiteColor()
        centerView.layer.cornerRadius = centerView.frame.width/2
        centerView.layer.shadowColor = UIColor.blackColor().CGColor
        centerView.layer.shadowOpacity = 0.25
        centerView.layer.shadowRadius = 4
        centerView.layer.shadowOffset = CGSizeZero
        controlView!.addSubview(centerView)
        
        self.addSubview(controlView!)
    }
    
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(context, unselectedColor.CGColor)
        let path = CGPathCreateMutable()
        CGContextSetLineWidth(context, CGFloat(radius))
        CGPathAddArc(path, nil, rect.size.width/2, rect.size.height/2, (rect.size.width-radius-2*padding)/2, 0, 2*M_PI.CG, false)
        CGContextAddPath(context, path)
        CGContextStrokePath(context)
        
        if self.isDragging {
            
            CGContextSetStrokeColorWithColor(context, selectedColor.CGColor)
            let path = CGPathCreateMutable()
            CGContextSetLineWidth(context, CGFloat(radius))
            CGPathAddArc(path, nil, rect.size.width/2, rect.size.height/2, (rect.size.width-radius-2*padding)/2, -CGFloat(startingAngle), -CGFloat(currentAngle), isClockwise)
            CGContextAddPath(context, path)
            CGContextStrokePath(context)
        }
        
        super.drawRect(rect)
    }
    
    
    // MARK: - Public Methods
    
    func setControlView(view: UIView) {
        
        let oldView = controlView
        controlView = view
        
        self.addSubview(controlView!)
        controlView!.center = oldView!.center
        oldView!.removeFromSuperview()
    }
    
    
    // MARK: - Touch Event Handling
    
    private func getAngle(point: CGPoint) -> Double {
        
        var angle = Double(atan(point.y/point.x))
        
        // Adjust the angle for quadrant (optimized)
        
        if point.x < 0 { // Q2 & Q3
            angle += M_PI
        }
        else if point.y < 0 { // Q4
            angle += 2*M_PI
        }
        
        return angle
    }
    
    /*
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touch: AnyObject? = touches.anyObject()
        var point = touch!.locationInView(self)
        
        // If touched inside the control view, begin moving
        if abs(point.x-controlView!.center.x) < controlView!.frame.width &&
            abs(point.y-controlView!.center.y) < controlView!.frame.height {
                
                self.sendActionsForControlEvents(UIControlEvents.TouchDown)
                
                // Shift coordinate space so the center of the control is (0,0)
                point.x =   point.x-self.frame.width  / 2.0
                point.y = -(point.y-self.frame.height / 2.0)
                
                startingAngle = getAngle(point)
                relativeAngle = 0.0
                isDragging = true
                
                newTouch(touches)
                
                self.layer.shadowOpacity = 0
                self.layer.shadowColor = UIColor.whiteColor().CGColor
                self.layer.shadowRadius = CGFloat(radius)
                
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    self.layer.shadowOpacity = 1
                })
        }
    }
    */
    
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if isDragging {
            newTouch(touches)
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        isDragging = false
        
        startingAngle = 0
        currentAngle = 0
        
        self.layer.shadowColor = UIColor.clearColor().CGColor
        
        self.setNeedsDisplay()

    }
    

    private func newTouch(touches: NSSet) {
        
        if isDragging {
            
            // Move the selector view
            
            var touch: AnyObject? = touches.anyObject()
            var point = touch!.locationInView(self)
            
            // Get coordinates for the point
            
            point.x =   point.x-self.frame.width  / 2.0
            point.y = -(point.y-self.frame.height / 2.0)
            
            // Get the angle of the touch
            
            currentAngle = getAngle(point)
            
            // Calculate the new location for the control according to the angle of touch
            
            var r = Double((self.frame.width-2*padding)/2.0 - radius/2.0)
            
            var y = r * -sin(currentAngle) + Double(self.frame.width/2.0)
            var x = r *  cos(currentAngle) + Double(self.frame.width/2.0)
            
            controlView!.center = CGPointMake(x.CG, y.CG)
            
            if currentAngle != startingAngle {
                
                // Determine clockwise-ness
                
                if relativeAngle < M_PI/4 {
                    
                    isClockwise = currentAngle > startingAngle
                    
                    // If close to θ=0, compensate for movements crossing to θ=2π
                    if startingAngle < M_PI/4 && currentAngle > 7*M_PI/4 {
                        isClockwise = false
                    }
                    else if startingAngle > 7*M_PI/4 && currentAngle < M_PI/4 {
                        isClockwise = true
                    }
                }
                
                // Determine relative angle
                
                func relativeAngleCalc(startingAngle: Double, currentAngle: Double, isClockwise: Bool) -> Double {
                    
                    if isClockwise {
                        if currentAngle > startingAngle {
                            return currentAngle - startingAngle
                        }
                        else {
                            return 2*M_PI - startingAngle + currentAngle
                        }
                    }
                    else {
                        if currentAngle < startingAngle {
                            return startingAngle - currentAngle
                        }
                        else {
                            return 2*M_PI - currentAngle + startingAngle
                        }
                    }
                }
                
                let lastAngle = relativeAngle
                
                relativeAngle = relativeAngleCalc(startingAngle, currentAngle: currentAngle, isClockwise: isClockwise)
                
                // Check if they made the full circle
                
                if abs(relativeAngle-lastAngle) > M_PI {
                    isDragging = false
                    self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                    self.sendActionsForControlEvents(UIControlEvents.ValueChanged) // Fire event
                }
                
                // Re-draw the view
                
                self.setNeedsDisplay()
            }
        }
    }
}
