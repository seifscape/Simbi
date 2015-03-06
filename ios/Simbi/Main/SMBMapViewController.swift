//
//  SMBMapViewController.swift
//  Simbi
//
//  Created by flynn on 10/10/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit


private let kFeetInMile = 5280.0
private let kMetersInMile = 1609.34

protocol SMBMapViewDelegate: class {
    func mapView(mapView: SMBMapViewController, willShowCard willShow: Bool)
    func mapViewShouldShowExitButtons(mapView: SMBMapViewController) -> (Bool, Bool)
    func mapViewShouldExitLeft(sender: AnyObject)
    func mapViewShouldExitRight(sender: AnyObject)
}


class SMBMapViewController: UIViewController {
    
    weak var delegate: SMBMapViewDelegate? {
        
        didSet {
            showExitButtons(true)
            exitLeftButton.addTarget(delegate, action: "mapViewShouldExitLeft:", forControlEvents: .TouchUpInside)
            exitRightButton.addTarget(delegate, action: "mapViewShouldExitRight:", forControlEvents: .TouchUpInside)
        }
    }
    
    var annotations: [SMBAnnotation] = []
    
    let mapView = MKMapView()
    
    let exitLeftButton = UIButton()
    let exitRightButton = UIButton()
    
    let shadeView = UIView()
    
    let locationManager = CLLocationManager()
    
    var cardView: SMBMapCardView?
    
    var didUpdateLocation = false
    
    var rangeSlider: SMBLabeledSlider?
    
    
    // MARK: - ViewController Lifecycle
    
    override convenience init() { self.init(nibName: nil, bundle: nil) }
    
    deinit {
        SMBFriendsManager.sharedManager().cleanDelegates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SMBFriendsManager.sharedManager().addDelegate(self)
        
        self.view.clipsToBounds = true
        
        // Set up subviews.
        
        mapView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        mapView.delegate = self
        
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .Authorized ||
           CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = CLLocationManager.locationServicesEnabled()
        }
        else if CLLocationManager.authorizationStatus() == .Denied ||
                CLLocationManager.authorizationStatus() == .Restricted {
                    
            let message = "Simbi needs your location to work properly! Please enable location services for Simbi in\n\nSettings → Privacy → Location Services → Simbi\n\nWe promise we're chill."
            let alertView = UIAlertView(title: "Location Services", message: message, delegate: nil, cancelButtonTitle: "Ok")
            alertView.show()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.showsPointsOfInterest = false
        self.view.addSubview(mapView)
        
        if SMBFriendsManager.sharedManager().objects.count > 0 {
            createAnnotations()
        }
        
        
        // Button to exit the map view left or right (visibility determined by delegate)
        
        exitLeftButton.frame = CGRectMake(0, self.view.frame.height-110, 66, 88)
        exitLeftButton.setTitle("<", forState: .Normal)
        exitLeftButton.setTitleColor(UIColor.simbiBlueColor(), forState: .Normal)
        exitLeftButton.titleLabel?.font = UIFont.simbiFontWithSize(96)
        exitLeftButton.layer.shadowColor = UIColor.blackColor().CGColor
        exitLeftButton.layer.shadowOffset = CGSizeMake(1, 1)
        exitLeftButton.layer.shadowOpacity = 0.33
        self.view.addSubview(exitLeftButton)
        
        exitRightButton.frame = CGRectMake(self.view.frame.width-66, self.view.frame.height-110, 66, 88)
        exitRightButton.setTitle(">", forState: .Normal)
        exitRightButton.setTitleColor(UIColor.simbiBlueColor(), forState: .Normal)
        exitRightButton.titleLabel?.font = UIFont.simbiFontWithSize(96)
        exitRightButton.layer.shadowColor = UIColor.blackColor().CGColor
        exitRightButton.layer.shadowOffset = CGSizeMake(1, 1)
        exitRightButton.layer.shadowOpacity = 0.33
        self.view.addSubview(exitRightButton)
        
        showExitButtons(true)
        
        
        // Range slider
        
        rangeSlider = SMBLabeledSlider(frame: CGRectMake(
            0,
            self.view.frame.height/2+22,
            44,
            self.view.frame.height/2-44
        ), labelSide: .Right)
        rangeSlider!.values = [
            ("500 Feet",       500/kFeetInMile),
            ("1,000 Feet",    1000/kFeetInMile),
            ("1 Mile",         1.0),
            ("5 Miles",        5.0),
            ("25 Miles",      25.0),
            ("50 Miles",      50.0),
            ("100 Miles",    100.0),
            ("250 Miles",    250.0),
            ("500 Miles",    500.0),
            ("1,000 Miles", 1000.0),
            ("The World", 10_000.0)
        ]
        rangeSlider!.slider.value = 2
        rangeSlider!.slider.addTarget(self, action: "rangeSliderDidChange:", forControlEvents: .ValueChanged)
        self.view.addSubview(rangeSlider!)
        
        
        // Shade view that darkens the screen when a user is in focus.
        
        shadeView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        shadeView.backgroundColor = UIColor.blackColor()
        shadeView.alpha = 0
        shadeView.hidden = true
        self.view.addSubview(shadeView)
        
        let shadeHideButton = UIButton()
        shadeHideButton.frame = CGRectMake(0, 0, shadeView.frame.width, shadeView.frame.height)
        shadeHideButton.addTarget(self, action: "hideCardAction:", forControlEvents: .TouchUpInside)
        shadeView.addSubview(shadeHideButton)
        
        //add visible/invisible button,this button can set whether other's can see
        //me in their map
        let switchVisibleButton = UIButton()
        switchVisibleButton.setImage(UIImage(named:"selfVisible.png"), forState: UIControlState.Normal)
        switchVisibleButton.setImage(UIImage(named:"selfInvisible.png"), forState: UIControlState.Selected)
        
        switchVisibleButton.frame = CGRectMake(0,0, 66, 88)
        switchVisibleButton.center = CGPoint(x:self.view.frame.width/2, y:self.view.frame.height-50)
        switchVisibleButton.addTarget(self, action: "switchVisibleBtnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(switchVisibleButton)
        
        //set the current user's visible or invisible
        if SMBUser.currentUser().visible {
            switchVisibleButton.selected = false
        }else{
            switchVisibleButton.selected = true
        }
        
    }
    
    
    // MARK: - User Actions
    
    func rangeSliderDidChange(slider: UISlider) {
        
        func distanceForSliderValue() -> Double {
            
            let percent = Double(slider.value - floor(slider.value))
            
            let (text, value) = rangeSlider!.selectedItem()
                        
            if Int(floor(slider.value)) == rangeSlider!.values!.count-1 {
                return value
            }
            else {
                let (nextText, nextValue) = rangeSlider!.values![ Int(floor(slider.value))+1 ]
                return value+(nextValue-value)*percent
            }
        }
        
        let distance = distanceForSliderValue()
                
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, distance*kMetersInMile, distance*kMetersInMile), animated: false)
    }
    
    
    func hideCardAction(sender: AnyObject) {
        
        delegate?.mapView(self, willShowCard: false)
        
        showExitButtons(true)
        
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            
            self.exitLeftButton.alpha = 1
            self.exitRightButton.alpha = 1
            self.shadeView.alpha = 0
            self.cardView?.alpha = 0
            
        }) { (Bool) -> Void in
            
            self.shadeView.hidden = true
            self.cardView?.removeFromSuperview()
        }
    }
    
    func switchVisibleBtnClicked(sender: UIButton) {
        let obid = SMBUser.currentUser().objectId
        if obid=="" {
            return
        }
        let query = PFQuery(className: "_User")
        query.getObjectInBackgroundWithId(obid) { (obj:PFObject!, err:NSError!) -> Void in
            if obj==nil{
            return
            }
            obj["visible"] = sender.selected
            obj.saveInBackgroundWithBlock({ (suss:Bool, err:NSError!) -> Void in
                sender.selected = !sender.selected
            })
        }
    }
    
    // MARK: - Public Methods
    
    func focusUserInMap(user: SMBUser, coordinate: CLLocationCoordinate2D) {
        
        delegate?.mapView(self, willShowCard: true)
        
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(
            coordinate,
            CLLocationDistance(kMetersInMile),
            CLLocationDistance(kMetersInMile)
            ), animated: true)
        
        shadeView.hidden = false
        
        cardView = SMBMapCardView(frame: CGRectMake(20, 20, self.view.frame.width-40, (self.view.frame.height)/2-44), user: user)
        cardView!.alpha = 0
        self.view.addSubview(cardView!)
        
        let cardHideButton = UIButton()
        cardHideButton.frame = CGRectMake(cardView!.frame.width-28-6, 6, 28, 28)
        cardHideButton.backgroundColor = UIColor.simbiWhiteColor()
        cardHideButton.setTitle("X", forState: .Normal)
        cardHideButton.setTitleColor(UIColor.simbiGrayColor(), forState: .Normal)
        cardHideButton.layer.cornerRadius = cardHideButton.frame.width/2
        cardHideButton.layer.shadowOffset = CGSizeMake(2, 2)
        cardHideButton.layer.shadowColor = UIColor.blackColor().CGColor
        cardHideButton.layer.shadowOpacity = 0.33
        cardHideButton.addTarget(self, action: "hideCardAction:", forControlEvents: .TouchUpInside)
        cardView!.addSubview(cardHideButton)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.shadeView.alpha = 0.5
            self.exitLeftButton.alpha = 0
            self.exitRightButton.alpha = 0
        }) { (Bool) -> Void in
            self.showExitButtons(false)
        }
        
        UIView.animateWithDuration(0.25, delay: 0.125, options: .CurveLinear, animations: { () -> Void in
            self.cardView!.alpha = 1
        }, completion: nil)
    }
    
    
    // MARK: - Private Methods
    
    private func createAnnotations() {

        mapView.removeAnnotations(annotations)
        annotations = []
//        println("==================================")
//        println(SMBFriendsManager.sharedManager().objects.count)
//        let friend = object as SMBUser
//        println(((SMBFriendsManager.sharedManager().objects[0]) as SMBUser).username)
//        println("==================================")
 //       return
        for object in SMBFriendsManager.sharedManager().objects {
            let friend = object as SMBUser
            println("==================================")
            print("name:")
            println(friend.username)
            print("visible:")
            println(friend.visible)
            print("lat:")
            println(friend.geoPoint.latitude)
            print("lon:")
            println(friend.geoPoint.longitude)
            print("profitpic:")
            println(friend.profilePicture)
            println("==================================")
            if friend.geoPoint != nil && friend.visible {
                
                let annotation = SMBAnnotation(user: friend)
                annotation.delegate = self
                mapView.addAnnotation(annotation)
                annotations.append(annotation)
            }
        }
    }
    
    
    private func showExitButtons(shouldShow: Bool) {
        
        let (shouldShowLeft, shouldShowRight) = delegate != nil ? delegate!.mapViewShouldShowExitButtons(self) : (false, false)
        
        exitLeftButton.hidden = !shouldShowLeft
        exitRightButton.hidden = !shouldShowRight
    }
}


// MARK: - CLLocationManagerDelegate

extension SMBMapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .Authorized || status == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
}


// MARK: - MKMapViewDelegate

extension SMBMapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        if !didUpdateLocation {
        
            mapView.region = MKCoordinateRegionMakeWithDistance(
                mapView.userLocation.coordinate,
                CLLocationDistance(kMetersInMile.CG),
                CLLocationDistance(kMetersInMile.CG)
            )
            didUpdateLocation = true
        }
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is SMBAnnotation {
            
            let smbAnnotation = annotation as SMBAnnotation
            
            var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier("Maps")
            if annotationView == nil {
                annotationView = smbAnnotation.annotationView()
            }
            annotationView?.annotation = smbAnnotation
            annotationView?.image = UIImage(named: "friendsearchicon")
            annotationView?.backgroundColor = UIColor.whiteColor()
            
            return annotationView!
        }
        else {
            return nil
        }
    }
}


// MARK: SMBAnnotationDelegate

extension SMBMapViewController: SMBAnnotationDelegate {
    
    func annotationDidSelectUser(annotation: SMBAnnotation, user: SMBUser) {
        
        focusUserInMap(user, coordinate: annotation.coordinate)
    }
}


// MARK: SMBManagerDelegate

extension SMBMapViewController: SMBManagerDelegate {
    
    func manager(manager: SMBManager!, didUpdateObjects objects: [AnyObject]!) {
        
        createAnnotations()
    }
    
    
    func manager(manager: SMBManager!, didFailToLoadObjects error: NSError!) {
        
        // Do nothing.
    }
}
