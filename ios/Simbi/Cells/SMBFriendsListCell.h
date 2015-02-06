//
//  SMBFriendsListCell.h
//  Simbi
//
//  Created by flynn on 8/12/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBImageView.h"

@interface SMBFriendsListCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) SMBImageView *profilePictureView;
@property (nonatomic, strong) UILabel *nameLabel;

@end
