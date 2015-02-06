//
//  SMBFriendRequestCell.h
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBImageView.h"


@interface SMBFriendRequestCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) SMBImageView *profilePictureView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end
