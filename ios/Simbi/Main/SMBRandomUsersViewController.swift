//
//  SMBRandomUsersViewController.swift
//  Simbi
//
//  Created by flynn on 10/30/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


protocol SMBRandomUsersViewDelegate {
    
}


class SMBRandomUsersViewController: UIViewController {
    
    let feetInMile = 5280.0
    
    var delegate: SMBRandomUsersViewDelegate?
    
    let carousel = iCarousel()
    
    var users: [SMBUser] = []
    
    var lastSelectedView: SMBRandomUserItemView?
    var rangeSlider: SMBLabeledSlider?
    
    let lineView = UIView()
    var errorView: UIView?
    
    
    // MARK: - ViewController Lifecycle
    
    convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 65.0/255, green: 114.0/255, blue: 232.0/255, alpha: 1)
        self.view.clipsToBounds = true
        
        // Make carousel bigger than view so the views get created as they scroll.
        carousel.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height+220)
        carousel.center = self.view.center
        carousel.type = iCarouselTypeLinear
        carousel.vertical = true
        carousel.dataSource = self
        carousel.delegate = self
        self.view.addSubview(carousel)
        
        rangeSlider = SMBLabeledSlider(frame: CGRectMake(
            self.view.frame.width-44,
            self.view.frame.height/2+22,
            44,
            self.view.frame.height/2-44
        ), labelSide: .Left)
        
        rangeSlider!.values = [
            ("500 Feet",    500/feetInMile),
            ("1,000 Feet", 1000/feetInMile),
            ("1 Mile",      1.0),
            ("2.5 Miles",   2.5),
            ("5 Miles",     5.0),
            ("10 Miles",   10.0),
            ("20 Miles",   20.0)
        ]
        rangeSlider!.slider.addTarget(self, action: "sliderDidStart:", forControlEvents: .TouchDown)
        rangeSlider!.slider.addTarget(self, action: "sliderDidFinish:", forControlEvents: .TouchUpInside)
        self.view.addSubview(rangeSlider!)
        
        lineView.frame = CGRectMake(40+110/2-1, 0, 2, self.view.frame.height)
        lineView.backgroundColor = UIColor.simbiGrayColor()
        self.view.insertSubview(lineView, belowSubview: carousel)
        lineView.alpha = 0
        
        loadUsers()
    }
    
    
    // MARK: - User Actions
    
    func sliderDidStart(slider: UISlider) {
        lastSelectedView?.fadeOut()
    }
    
    
    func sliderDidFinish(slider: UISlider) {
        loadUsers()
    }
    
    
    // MARK: - Private Methods
    
    func loadUsers() {
        
        if errorView != nil {
            errorView!.removeFromSuperview()
            errorView = nil
        }
        
        UIView.animateWithDuration(0.33, animations: { () -> Void in
            self.lineView.alpha = 0
        })
        
        users = []
        lastSelectedView?.fadeOut()
        carousel.userInteractionEnabled = false
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicatorView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        activityIndicatorView.startAnimating()
        self.view.addSubview(activityIndicatorView)
        
        let query = PFQuery(className: "_User")
//        query.cachePolicy = kPFCachePolicyNetworkOnly
        query.whereKey("objectId", notEqualTo: SMBUser.currentUser().objectId!)
        query.includeKey("profilePicture")
        query.includeKey("hairColor")
        
        let (text, value) = rangeSlider!.selectedItem()
        
        if SMBUser.currentUser().geoPoint != nil {
            query.whereKey("geoPoint", nearGeoPoint: SMBUser.currentUser().geoPoint, withinMiles: value)
        }
        else {
            println("\(__FUNCTION__) - Warning: Current user does not have geoPoint")
        }
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in

            self.carousel.userInteractionEnabled = true
            
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
            
            if let users = objects {
            
                self.users = users as! [SMBUser]
                self.carousel.reloadData()
                // v Causes crashes
                //self.carousel.scrollToItemAtIndex(Int(arc4random())%self.carousel.numberOfItems, animated: true)
                UIView.animateWithDuration(0.33, animations: { () -> Void in
                    self.lineView.alpha = 1
                })
            }
            else {
                self.showError()
            }
        }
    }
    
    
    private func showError() {
        users = []
        
        if errorView == nil {
            errorView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
            
            let label = UILabel(frame: CGRectMake(0, 0, errorView!.frame.width, 88))
            label.center = errorView!.center
            label.text = "No Results!"
            label.textColor = UIColor.simbiBlackColor()
            label.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 22)
            label.textAlignment = .Center
            errorView!.addSubview(label)
            
            let button = UIButton(frame: CGRectMake(44, label.frame.origin.y+label.frame.height, errorView!.frame.width, 44))
            button.setTitle("Reload", forState: .Normal)
            button.setTitleColor(UIColor.simbiDarkGrayColor(), forState: .Normal)
            button.addTarget(self, action: "loadUsers", forControlEvents: .TouchUpInside)
            errorView!.addSubview(button)
        }
        
        self.view.addSubview(errorView!)
    }
}


// MARK: - iCarouselDataSource

extension SMBRandomUsersViewController: iCarouselDataSource {
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> UInt {
        
        if users.count > 3 {
            return UInt(users.count)*2
        }
        else {
            return UInt(users.count)
        }
    }
    
    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        return option.value == iCarouselOptionWrap.value && carousel.numberOfItems > 3 ? 1 : value
    }
    
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: UInt, reusingView view: UIView!) -> UIView! {
        
        let frame = CGRectMake(0, 0, carousel.frame.width, 154)
        let user = users[Int(index) % users.count]
        
        let view = SMBRandomUserItemView(frame: frame, user: user)
        view.delegate = self
        
        return view
    }
    
    
    func carousel(carousel: iCarousel!, didSelectItemAtIndex index: Int) {
        
    }
}


// MARK: - iCarouselDelegate

extension SMBRandomUsersViewController: iCarouselDelegate {
    
    func changeCurrentView(carousel: iCarousel) { // Non-protocol method
        
        if let currentView = self.carousel.currentItemView {
            lastSelectedView = (currentView as! SMBRandomUserItemView)
        }
    }
    
    
    func carouselWillBeginDragging(carousel: iCarousel!) {
        changeCurrentView(carousel)
        lastSelectedView?.fadeOut()
    }
    
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
        lastSelectedView?.fadeOut()
        changeCurrentView(carousel)
    }
    
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel!) {
        changeCurrentView(carousel)
        lastSelectedView?.fadeIn()
    }
}


// MARK: - SMBRandomUserItemDelegate

extension SMBRandomUsersViewController: SMBRandomUserItemDelegate {
 
    func itemViewDidSelectUserForQuestion(itemView: SMBRandomUserItemView, user: SMBUser) {
        
        let navigationController = UINavigationController(rootViewController: SMBAnswerQuestionViewController(user))
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    func itemViewDidSelectUserForChallenge(itemView: SMBRandomUserItemView, user: SMBUser) {
        
        let navigationController = UINavigationController(rootViewController: SMBSelectChallengeViewController(user: user))
        self.navigationController!.presentViewController(navigationController, animated: true, completion: nil)
    }
}
