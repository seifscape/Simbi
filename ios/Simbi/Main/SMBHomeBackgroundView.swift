//
//  SMBHomeBackgroundImageView.swift
//  Simbi
//
//  Created by flynn on 9/21/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBHomeBackgroundView : UIView {
    
    override var frame: CGRect {
        didSet {
            let size = max(frame.width, frame.height)
            imageView.frame = CGRectMake((frame.width-size)/2, (frame.height-size)/2, size, size)
        }
    }
    let imageView = UIImageView()
    let fadeView = UIView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     * crash here
     */
    
//    convenience init() {
//        self.init()
//        loadView()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    
    func loadView() {
        
        self.backgroundColor = UIColor.simbiBlackColor()
        
        // Set up subviews.
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(imageView)
        
        fadeView.frame = CGRectMake(0, 0, frame.width, frame.height)
        fadeView.backgroundColor = UIColor.blueColor()
        fadeView.alpha = 0.5
        fadeView.hidden = true
        self.addSubview(fadeView)
        
        // Immediately process and set image.
        
        updateFilteredProfilePicture()
    }

    
    func updateFilteredProfilePicture() {
        
        struct ImageInfo {
            static var imageId: String?
            static var filteredImage: UIImage?
        }
        
        if SMBUser.exists() {
            
            if let backgroundImage = SMBUser.currentUser().backgroundImage {
            
                // If there's already an image and it's the current image, set it.
                
                if ImageInfo.imageId != nil &&
                   ImageInfo.filteredImage != nil &&
                   ImageInfo.imageId == backgroundImage.objectId {
                    
                    imageView.image = ImageInfo.filteredImage!
                }
                else {
                    // Otherwise, fetch the image from Parse and apply the blue filter.
                    
                    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                    activityIndicatorView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
                    activityIndicatorView.autoresizingMask = UIViewAutoresizing.FlexibleWidth|UIViewAutoresizing.FlexibleHeight
                    activityIndicatorView.startAnimating()
                    self.addSubview(activityIndicatorView)
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        backgroundImage.fetchIfNeeded()
                        
                        // Get the data and apply the filter.
                        
                        if let data = backgroundImage.mediumSquareImage.getData() {
                            
                            let image = UIImage(data: data)
                            ImageInfo.filteredImage = image?.filteredBlueImage()
                            ImageInfo.imageId = backgroundImage.objectId
                            
                            // Update the UI.
                            
                            dispatch_sync(dispatch_get_main_queue()) {
                                
                                self.fadeView.hidden = !(SMBChatManager.sharedManager().objects.count > 0)
                                
                                self.imageView.image = ImageInfo.filteredImage
                                
                                activityIndicatorView.stopAnimating()
                                activityIndicatorView.removeFromSuperview()
                            }
                        }
                        else {
                            activityIndicatorView.stopAnimating()
                            activityIndicatorView.removeFromSuperview()
                        }
                    }
                }
            }
            else { // If there's no background image, use the default
                self.imageView.image = nil
            }
        }
        else {
            imageView.image = nil
        }
    }
}
