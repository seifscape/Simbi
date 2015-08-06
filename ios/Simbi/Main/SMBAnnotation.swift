//
//  SMBAnnotation.swift
//  Simbi
//
//  Created by flynn on 10/10/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import MapKit
import UIKit


protocol SMBAnnotationDelegate: class {
    func annotationDidSelectUser(annotation: SMBAnnotation, user: SMBUser)
}


class SMBAnnotation: NSObject, MKAnnotation {
    
    weak var delegate: SMBAnnotationDelegate?
    
    let user: SMBUser
    var coordinate: CLLocationCoordinate2D
    override init() {
        self.user = SMBUser.currentUser()
        self.coordinate = CLLocationCoordinate2DMake(0, 0)
        super.init()
    }
    
    init(user: SMBUser) {
        
        self.user = user
        self.coordinate = CLLocationCoordinate2DMake(user.geoPoint.latitude, user.geoPoint.longitude)
        super.init()
    }

    
    func annotationView() -> MKAnnotationView {
        
        let annotationView = MKAnnotationView(annotation: self, reuseIdentifier: "Maps")
        
        annotationView.enabled = true
        annotationView.canShowCallout = false
        annotationView.backgroundColor = UIColor.simbiDarkGrayColor()
        annotationView.layer.borderColor = UIColor.simbiBlackColor().CGColor
        annotationView.layer.borderWidth = 0.5
        annotationView.layer.cornerRadius = 16
        annotationView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "selectAction:")
        annotationView.addGestureRecognizer(tapGesture)
        
//        user.profilePicture.thumbnailImage.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
//            
//            if data != nil {
//                let image: UIImage? = UIImage(data: data!)?.imageWithSize(CGSizeMake(22, 22)).imageWithRoundedCornerSize(11)
//                annotationView.image = image?
//            }
//        }
        
        return annotationView
    }
    
    
    func selectAction(sender: AnyObject) {
        delegate?.annotationDidSelectUser(self, user: user)
    }
}
