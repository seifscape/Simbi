//
//  SMBUserCell.m
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBUserCell.h"


@implementation SMBUserCell

+ (CGFloat)cellHeight
{
    return 44;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        _profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake(4, 4, 44-8, 44-8)];
        [_profilePictureView setBackgroundColor:[UIColor simbiDarkGrayColor]];
        [_profilePictureView.layer setCornerRadius:_profilePictureView.frame.size.width/2.f];
        [_profilePictureView setClipsToBounds:YES];
        [self addSubview:_profilePictureView];
        
        _firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, self.frame.size.width-88, 26)];
        [_firstNameLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_firstNameLabel setFont:[UIFont simbiFontWithSize:16.f]];
        [self addSubview:_firstNameLabel];
        
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 44-22, self.frame.size.width-88, 22)];
        [_emailLabel setTextColor:[UIColor simbiGrayColor]];
        [_emailLabel setFont:[UIFont simbiLightFontWithSize:14.f]];
        [self addSubview:_emailLabel];
    }
    
    return self;
}


@end
