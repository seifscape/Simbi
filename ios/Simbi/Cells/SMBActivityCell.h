//
//  SMBActivityCell.h
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBImageView.h"

@interface SMBActivityCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) SMBImageView *profilePicture;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@end
