//
//  SMBFriendCardView.m
//  Simbi
//
//  Created by flynn on 8/4/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBFriendCardView.h"

#import "SMBImageView.h"


@interface _SMBFriendCardView ()

@property (nonatomic, strong) SMBUser *user;

@end


@implementation _SMBFriendCardView

- (instancetype)initWithFrame:(CGRect)frame user:(SMBUser *)user
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _user = user;
        
        [self setBackgroundColor:[UIColor simbiWhiteColor]];
        
        UIView *pointerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        [pointerView setCenter:CGPointMake(frame.size.width/2.f, frame.size.height)];
        [pointerView setBackgroundColor:[UIColor simbiWhiteColor]];
        [pointerView setTransform:CGAffineTransformMakeRotation(M_PI_4)];
        [self addSubview:pointerView];
        
        SMBImageView *profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-66) parseImage:_user.profilePicture];
        [profilePictureView setContentMode:UIViewContentModeScaleAspectFill];
        [profilePictureView.layer setMasksToBounds:YES];
        [self addSubview:profilePictureView];
        
        UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-66-44, frame.size.width, 44)];
        [fadeView setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.75f]];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        [gradientLayer setColors:[NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor, nil]];
        [gradientLayer setFrame:CGRectMake(0, 0, fadeView.frame.size.width, fadeView.frame.size.height)];
        [fadeView.layer setMask:gradientLayer];
        [self addSubview:fadeView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, frame.size.height-66-44, frame.size.width-56*2, 44)];
        [nameLabel setText:_user.name];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont simbiFontWithSize:14.f]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setNumberOfLines:2];
        [nameLabel.layer setShadowColor:[UIColor blackColor].CGColor];
        [nameLabel.layer setShadowOffset:CGSizeMake(1.f, 1.f)];
        [nameLabel.layer setShadowOpacity:0.5f];
        [self addSubview:nameLabel];
        
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, frame.size.height-66, frame.size.width-52*2, 66)];
        [locationLabel setFont:[UIFont simbiFontWithSize:14.f]];
        [locationLabel setNumberOfLines:2];
        [locationLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:locationLabel];
        
        UILabel *lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-66, frame.size.width-8, 22)];
        [lastUpdatedLabel setTextColor:[UIColor simbiGrayColor]];
        [lastUpdatedLabel setTextAlignment:NSTextAlignmentRight];
        [lastUpdatedLabel setFont:[UIFont simbiFontWithSize:8.f]];
        [self addSubview:lastUpdatedLabel];
        
        UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [messageButton setFrame:CGRectMake(6, frame.size.height-66-56/2, 56, 56)];
        [messageButton setBackgroundColor:[UIColor simbiBlueColor]];
        [messageButton.layer setCornerRadius:messageButton.frame.size.width/2.f];
        [messageButton.layer setBorderColor:[UIColor simbiWhiteColor].CGColor];
        [messageButton.layer setBorderWidth:1.f];
        [self addSubview:messageButton];
        
        
        // Get the last activity for this user
        
        PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
        [query whereKey:@"user" equalTo:_user];
        [query orderByDescending:@"createdAt"];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView setFrame:locationLabel.frame];
        [self addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            [activityIndicatorView stopAnimating];
            [activityIndicatorView removeFromSuperview];
            
            if (object)
            {
                SMBActivity *activity = (SMBActivity *)object;
                
                // Update date
                [lastUpdatedLabel setText:[activity.createdAt relativeDateString]];
                
                // Update text
                NSMutableAttributedString *activityText, *highlighted;
                
                activityText = [[NSMutableAttributedString alloc] initWithString:@"Checked in at "
                                                                      attributes:@{ NSForegroundColorAttributeName: [UIColor simbiDarkGrayColor] }];
                highlighted  = [[NSMutableAttributedString alloc] initWithString:activity.activityText
                                                                      attributes:@{ NSForegroundColorAttributeName: [UIColor simbiBlueColor] }];
                [activityText appendAttributedString:highlighted];
                
                [locationLabel setAttributedText:activityText];
            }
            else
            {
                [locationLabel setText:@"Hasn't checked in yet!"];
                [locationLabel setTextColor:[UIColor simbiGrayColor]];
            }
        }];
    }
    
    return self;
}


@end
