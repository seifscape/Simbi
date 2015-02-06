//
//  SMBFriendRequestCell.m
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendRequestCell.h"


@implementation SMBFriendRequestCell

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
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, self.frame.size.width-88, 44)];
        [_messageLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_messageLabel setFont:[UIFont simbiFontWithSize:16.f]];
        [_messageLabel setNumberOfLines:2];
        [self addSubview:_messageLabel];
        
        _acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_acceptButton setFrame:CGRectMake(self.frame.size.width-44, 0, 44, 44)];
        [_acceptButton setTitle:@"＋" forState:UIControlStateNormal];
        [_acceptButton setTitleColor:[UIColor simbiBlueColor] forState:UIControlStateNormal];
        [_acceptButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:32.f]];
        [_acceptButton setHidden:YES];
        [self addSubview:_acceptButton];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityIndicator setFrame:_acceptButton.frame];
        [_activityIndicator setHidden:YES];
        [self addSubview:_activityIndicator];
    }
    
    return self;
}


@end
