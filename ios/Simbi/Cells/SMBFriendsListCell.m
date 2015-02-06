//
//  SMBFriendsListCell.m
//  Simbi
//
//  Created by flynn on 8/12/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendsListCell.h"


@implementation SMBFriendsListCell

+ (CGFloat)cellHeight
{
    return 36;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        CGFloat height = [SMBFriendsListCell cellHeight];
        
        _profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake(17, 2, 32, 32)];
        [_profilePictureView setBackgroundColor:[UIColor simbiDarkGrayColor]];
        [_profilePictureView.layer setCornerRadius:_profilePictureView.frame.size.width/2.f];
        [_profilePictureView.layer setMasksToBounds:YES];
        [self.contentView addSubview:_profilePictureView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 0, self.frame.size.width-66, height)];
        [_nameLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_nameLabel setFont:[UIFont simbiFontWithSize:14.f]];
        [self.contentView addSubview:_nameLabel];
    }
    
    return self;
}


@end
