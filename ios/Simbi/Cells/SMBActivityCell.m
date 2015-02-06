//
//  SMBActivityCell.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBActivityCell.h"

@implementation SMBActivityCell

+ (CGFloat)cellHeight
{
    return 66.f;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        CGFloat height = [SMBActivityCell cellHeight];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _profilePicture = [[SMBImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_profilePicture setCenter:CGPointMake(height/2.f, height/2.f)];
        [_profilePicture.layer setCornerRadius:_profilePicture.frame.size.width/2.f];
        [_profilePicture.layer setMasksToBounds:YES];
        [_profilePicture setBackgroundColor:[UIColor simbiBlackColor]];
        [self.contentView addSubview:_profilePicture];
        
        UIView *pictureBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        [pictureBackgroundView setCenter:CGPointMake(height/2.f, height/2.f)];
        [pictureBackgroundView setBackgroundColor:[UIColor simbiWhiteColor]];
        [pictureBackgroundView.layer setCornerRadius:pictureBackgroundView.frame.size.width/2.f];
        [pictureBackgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
        [pictureBackgroundView.layer setShadowOpacity:0.33f];
        [pictureBackgroundView.layer setShadowRadius:1.f];
        [pictureBackgroundView.layer setShadowOffset:CGSizeZero];
        [self.contentView insertSubview:pictureBackgroundView belowSubview:_profilePicture];
        
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, 11, self.frame.size.width-44-height, 22)];
        [_nameLabel setFont:[UIFont simbiFontWithAttributes:kFontMedium size:14.f]];
        [_nameLabel setTextColor:[UIColor simbiBlackColor]];
        [self.contentView addSubview:_nameLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, 11, self.frame.size.width-11-height, 22)];
        [_dateLabel setFont:[UIFont simbiFontWithAttributes:kFontMedium size:14.f]];
        [_dateLabel setTextColor:[UIColor simbiBlackColor]];
        [_dateLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_dateLabel];
        
        _activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, 33, self.frame.size.width-22-height, 22)];
        [_activityLabel setFont:[UIFont simbiFontWithAttributes:kFontRegular size:18.f]];
        [_activityLabel setTextColor:[UIColor simbiBlackColor]];
        [self.contentView addSubview:_activityLabel];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(66, height-0.66f, self.frame.size.width-66-6, 0.66f)];
        [bottomLine setBackgroundColor:[UIColor simbiGrayColor]];
        [self.contentView addSubview:bottomLine];
    }
    
    return self;
}


@end
