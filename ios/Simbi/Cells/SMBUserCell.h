//
//  SMBUserCell.h
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBImageView.h"


@interface SMBUserCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) SMBImageView *profilePictureView;
@property (nonatomic, strong) UILabel *firstNameLabel;
@property (nonatomic, strong) UILabel *emailLabel;

@end
