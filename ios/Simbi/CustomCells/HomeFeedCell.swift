//
//  HomeFeedCell.swift
//  Simbi
//
//  Created by Seif Kobrosly on 3/25/16.
//  Copyright © 2016 SimbiSocial. All rights reserved.
//

import UIKit
//import IBCircularImageView

class HomeFeedCell: UITableViewCell {
    
    @IBOutlet var profileImage:UIImageView!
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var interestLabel:UILabel!
    @IBOutlet var distanceLabel:UILabel!
    var innerView:UIView?
    
//    override func prepareForReuse() {
//        
//    }
//    
//    override func prepareForInterfaceBuilder() {
//        
//    }
    
    
    func configureBackgroundView(){
        
        let bgView: UIView = UIView(frame: self.bounds)
        let whiteRect: CGRect = CGRectInset(bgView.bounds, 10, 10)
        innerView = UIView(frame: whiteRect)
        innerView!.autoresizingMask = .FlexibleHeight
        innerView!.autoresizingMask = .FlexibleWidth
        innerView!.backgroundColor = UIColor.whiteColor()
        bgView.addSubview(innerView!)
        bgView.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.00)
        
        
        self.profileImage.layer.borderWidth = 1
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.borderColor = UIColor.blackColor().CGColor
        self.profileImage.layer.cornerRadius = 30
        self.profileImage.clipsToBounds = true

        
        innerView!.layer.shadowColor = UIColor.blackColor().CGColor;
        innerView!.layer.shadowRadius = 2.0
        innerView!.layer.shadowOpacity = 0.2
        innerView!.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        innerView!.layer.cornerRadius = 4
        
//        innerView!.layer.shadowPath = UIBezierPath(rect: innerView!.bounds).CGPath

        
        self.backgroundView = bgView
        self.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.configureBackgroundView()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.configureBackgroundView()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
       super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
