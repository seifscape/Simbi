//
//  SMBUserView.m
//  Simbi
//
//  Created by flynn on 5/22/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBUserView.h"

#import "SMBImageView.h"


@interface SMBUserView ()

@property (nonatomic) BOOL isRevealed;


@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@end


@implementation SMBUserView

- (id)initWithFrame:(CGRect)frame isRevealed:(BOOL)isRevealed
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _isRevealed = isRevealed;
        
        CGFloat width  = frame.size.width;
        CGFloat height = frame.size.height;
        
        _profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake((width-height*0.72f)/2.f, (height*(1-0.72f)-44)/2.f, height*0.72f, height*0.72f)];
        [_profilePictureView setBackgroundColor:[UIColor simbiDarkGrayColor]];
        [_profilePictureView.layer setCornerRadius:_profilePictureView.frame.size.width/2.f];
        [_profilePictureView.layer setMasksToBounds:YES];
        [self addSubview:_profilePictureView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4+_profilePictureView.frame.origin.y+_profilePictureView.frame.size.height, width, 22)];
        [_nameLabel setFont:[UIFont simbiBoldFontWithSize:14.f]];
        [_nameLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_nameLabel];
        
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _nameLabel.frame.origin.y+20, width, 22)];
        [_locationLabel setFont:[UIFont simbiFontWithSize:14.f]];
        [_locationLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_locationLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_locationLabel];
    }
    
    return self;
}


- (void)setIsRevealed:(BOOL)isRevealed
{
    _isRevealed = isRevealed;
    
    if (_isRevealed)
    {
        if (_user)
            [_profilePictureView setParseImage:_user.profilePicture];
    }
    else
    {
        [_profilePictureView setImage:[UIImage imageNamed:@"Silhouette.png"]];
    }
}


- (void)setUser:(SMBUser *)user
{
    _user = user;
    
    [_nameLabel setText:_user.name];
    [_locationLabel setText:[_user cityAndState]];
    
    if (_isRevealed)
    {
        [_profilePictureView setParseImage:_user.profilePicture];
    }
    else
    {
        [_profilePictureView setImage:[UIImage imageNamed:@"Silhouette.png"]];
        
        // Pick a random color for the preference view based on the user's name
        
        [_profilePictureView setBackgroundColor:[UIColor randomPreferenceColorForName:_user.name]];
    }
}


@end
