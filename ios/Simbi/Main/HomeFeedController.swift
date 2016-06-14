//
//  HomeFeedController.swift
//  Simbi
//
//  Created by Seif Kobrosly on 3/27/16.
//  Copyright © 2016 SimbiSocial. All rights reserved.
//

import UIKit
//import GPUImage
//import FXBlurView
//import ActionButton
//import KCFloatingActionButton

// AppCoda PFSubclassing
//Bolts-Swift BoltsExtra

class HomeFeedController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var userArray = [SimbiUser]()
    var testList = [SMBUser]()
//    var actionButton:ActionButton!
    var DynamicView = UIView(frame: CGRectZero)
//    var fab = KCFloatingActionButton()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
        //UIColor(red:0.78, green:0.18, blue:0.16, alpha:1)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.tabBarController!.tabBar.tintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1) //UIColor.whiteColor()
//        self.tabBarController!.tabBar.barTintColor = UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)
            //UIColor(red:0.78, green:0.18, blue:0.16, alpha:1)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState:.Normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:0.17, green:0.56, blue:0.85, alpha:1)], forState:.Selected)
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        self.setupDataSource()
        
        
    }
    
    
//    func loadUsers() {
//        
//  
//        let users = []
//        
//        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//        activityIndicatorView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
//        activityIndicatorView.startAnimating()
//        self.view.addSubview(activityIndicatorView)
//        
//        let query = PFQuery(className: "_User")
//        //        query.cachePolicy = kPFCachePolicyNetworkOnly
//        query.whereKey("objectId", notEqualTo: SMBUser.currentUser().objectId!)
//        query.includeKey("profilePicture")
//        query.includeKey("hairColor")
//        
//        
//        if SMBUser.currentUser().geoPoint != nil {
//            query.whereKey("geoPoint", nearGeoPoint: SMBUser.currentUser().geoPoint, withinMiles: value)
//        }
//        else {
//            //            print("\(#function) - Warning: Current user does not have geoPoint")
//            print(" - Warning: Current user does not have geoPoint")
//            
//        }
//        
//        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            
//            activityIndicatorView.stopAnimating()
//            activityIndicatorView.removeFromSuperview()
//            
//            if let users = objects {
//                
//                self.users = users as! [SMBUser]
//                self.carousel.reloadData()
//                // v Causes crashes
//                //self.carousel.scrollToItemAtIndex(Int(arc4random())%self.carousel.numberOfItems, animated: true)
//                UIView.animateWithDuration(0.33, animations: { () -> Void in
//                    self.lineView.alpha = 1
//                })
//            }
//            else {
//                self.showError()
//            }
//        }
//    }
  
    
    /*
    func changeTabBar(hidden:Bool, animated: Bool){
        let tabBar = self.tabBarController?.tabBar
        if tabBar!.hidden == hidden{ return }
        let frame = tabBar?.frame
        let offset = (hidden ? (frame?.size.height)! : -(frame?.size.height)!)
        let duration:NSTimeInterval = (animated ? 0.5 : 0.0)
        tabBar?.hidden = false
        if frame != nil
        {
            UIView.animateWithDuration(duration,
                                       animations: {tabBar!.frame = CGRectOffset(frame!, 0, offset)},
                                       completion: {
                                        print($0)
                                        if $0 {tabBar?.hidden = hidden}
            })
        }
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translationInView(scrollView).y < 0{
            changeTabBar(true, animated: true)
        }
        else{
            changeTabBar(false, animated: true)
        }
    }
    */
    
    
    // http://stackoverflow.com/questions/14689805/how-to-put-buttons-over-uitableview-which-wont-scroll-with-table-in-ios
     func scrollViewDidScroll(scrollView: UIScrollView){


//        var frame: CGRect = self.fab.frame
//        frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.fab.frame.size.height - 15
//        fab.frame = frame
//        print(scrollView.contentOffset.y)
//        tableView.bringSubviewToFront(fab)
//        self.fab.layoutIfNeeded()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        fab.addItem("Filter", icon: UIImage(named: "filter_icon")!)
//        fab.plusColor = UIColor.whiteColor()
//        self.tableView.addSubview(fab)
        

//        let filter = ActionButtonItem(title: "filter", image: (UIImage (named: "filter_icon")))
//        filter.action = { item in print("Sharing...") }
        
        
        
//        actionButton = ActionButton(attachedToView: (self.navigationController?.view.subviews[0])!, items: [filter])
//        actionButton.action = { button in button.toggleMenu() }
//        
        
        self.navigationController!.hidesBarsOnSwipe = true;

//        print(actionButton)
        
    }
    

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
        
    func setupDataSource() {
        let user1 = SimbiUser()
        user1.name = "Seif"
        user1.age = "29"
        user1.numberOfInterests = "4"
        user1.locationDistance = "0.04"
        user1.image = UIImage(named: "profile_test");
        user1.isFriends = true
        userArray.append(user1)
        
        let user2 = SimbiUser()
        user2.name = "Mil"
        user2.age = "25"
        user2.numberOfInterests = "10"
        user2.locationDistance = "1.10"
        user2.image = UIImage(named: "profile_test_1");
        user2.isFriends = true
        userArray.append(user2)

        
        let user3 = SimbiUser()
        user3.name = "Anna"
        user3.age = "21"
        user3.numberOfInterests = "2"
        user3.locationDistance = "2.5"
        user3.image = UIImage(named: "profile_test_2");
        user3.isFriends = true
        userArray.append(user3)

        
        let user4 = SimbiUser()
        user4.name = "Seth"
        user4.age = "24"
        user4.numberOfInterests = "0"
        user4.locationDistance = "0.05"
        user4.image = UIImage(named: "profile_test_3");
        user4.isFriends = true
        userArray.append(user4)
        
        
        userArray.append(user1)
        userArray.append(user2)
        userArray.append(user3)
        userArray.append(user4)


        
        
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return userArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
//        let cell = HomeFeedCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "userProfileCell")

        
            let cell:HomeFeedCell = self.tableView.dequeueReusableCellWithIdentifier("userProfileCell")! as! HomeFeedCell
            cell.profileImage.image = userArray[indexPath.row].image
            cell.nameLabel.text = userArray[indexPath.row].name! + ", " + userArray[indexPath.row].age!
            cell.nameLabel.sizeToFit()
            cell.nameLabel.layoutIfNeeded()
            cell.distanceLabel.text =  userArray[indexPath.row].locationDistance! + " Miles Away";
            cell.interestLabel.text =  userArray[indexPath.row].numberOfInterests! + " Shared Interest"
        
            
        
        
            if(userArray[indexPath.row].isFriends!)
            {
                cell.profileImage.image = cell.profileImage.image?.blurredImageWithRadius(26, iterations: 2, tintColor: nil)
                // MEMORY ISSUE
//                let gpuBlurFilter = GPUImageGaussianBlurFilter()
//                gpuBlurFilter.blurRadiusInPixels = CGFloat(36)
//                let blurredImage = gpuBlurFilter.imageByFilteringImage(cell.profileImage.image)
//                cell.profileImage.image = blurredImage
            }
        
        return cell

    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func applyBlurEffect(image: UIImage) -> UIImage {
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        let blurredImage = UIImage(CIImage: resultImage)
        
        return blurredImage
    }
}

extension UIImageView
{
    
    func makeBlurImage(targetImageView:UIImageView?)
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = targetImageView!.bounds
        
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        targetImageView?.addSubview(blurEffectView)
    }
}

