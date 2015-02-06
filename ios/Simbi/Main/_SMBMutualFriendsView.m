//
//  SMBMutualFriendsView.m
//  Simbi
//
//  Created by flynn on 6/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBMutualFriendsView.h"

#import "SMBFriendsManager.h"
#import "SMBImageView.h"


@interface _SMBMutualFriendsView ()

@property (nonatomic, strong) UILabel *mutualFriendsLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *views;
@property (nonatomic, strong) SMBUser *user;

@end


@implementation _SMBMutualFriendsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _mutualFriendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, -20, frame.size.width, 20)];
        [_mutualFriendsLabel setText:@"Mutual Friends:"];
        [_mutualFriendsLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_mutualFriendsLabel setFont:[UIFont simbiFontWithSize:12.f]];
        [_mutualFriendsLabel setAlpha:0.f];
        [self addSubview:_mutualFriendsLabel];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
        [_scrollView setClipsToBounds:YES];
        [self addSubview:_scrollView];
        [self setUserInteractionEnabled:NO];
    }
    
    return self;
}


- (void)loadFriendsForUser:(SMBUser *)user
{
    _user = user;
    
    [self hideFriends];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView setFrame:CGRectMake(0, -20, self.frame.size.width, self.frame.size.height+20)];
    [activityIndicatorView startAnimating];
    [activityIndicatorView setAlpha:0.33f];
    [self addSubview:activityIndicatorView];
    
    PFQuery *query = user.friends.query;
    [query whereKey:@"objectId" containedIn:[[SMBFriendsManager sharedManager] friendsObjectIds]];
    [query selectKeys:@[@"profilePicture"]];
    [query includeKey:@"profilePicture"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [activityIndicatorView stopAnimating];
        [activityIndicatorView removeFromSuperview];
        
        if (objects && objects.count > 0)
        {
            NSMutableArray *views = [NSMutableArray new];
            
            CGFloat height = self.frame.size.height;
            int i = 0;
            
            for (SMBUser *user in objects)
            {
                SMBImageView *imageView = [[SMBImageView alloc] initWithFrame:CGRectMake(8+height*i,
                                                                                         2,
                                                                                         height-4,
                                                                                         height-4)];
                [imageView setParseImage:user.profilePicture withType:kImageTypeThumbnail];
                [imageView setBackgroundColor:[UIColor simbiDarkGrayColor]];
                [imageView.layer setCornerRadius:imageView.frame.size.width/2.f];
                [imageView.layer setMasksToBounds:YES];
                [imageView setTransform:CGAffineTransformMakeRotation(i*M_PI_2/(float)objects.count+M_PI_2)];
                [imageView setAlpha:0.f];
                [_scrollView addSubview:imageView];
                
                [views addObject:imageView];
                
                i++;
            }
            
            _views = [NSArray arrayWithArray:views];
                        
            [_scrollView setContentSize:CGSizeMake(i*height+12, _scrollView.frame.size.height)];
            
            [self animateInForUser:user];
        }
    }];
}


- (void)animateInForUser:(SMBUser *)user;
{
    [_scrollView setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    
    if ([user.objectId isEqualToString:_user.objectId] && _views.count > 0)
    {
        for (SMBImageView *imageView in _views)
            [imageView setAlpha:0.f];
        
        [self setUserInteractionEnabled:YES];
        
        [UIView animateWithDuration:1.f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                                [_mutualFriendsLabel setAlpha:1.f];
                             [_scrollView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                             
                             for (SMBImageView *imageView in _views)
                             {
                                 [imageView setAlpha:1.f];
                                 [imageView setTransform:CGAffineTransformMakeRotation(0)];
                             }
                         }
                         completion:nil];
    }
}


- (void)hideFriends
{
    for (SMBImageView *imageView in _views)
        [imageView setAlpha:1.f];
    
    [self setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:0.25f animations:^{
        [_mutualFriendsLabel setAlpha:0.f];
        [_scrollView setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        for (SMBImageView *imageView in _views)
            [imageView setAlpha:0.f];
    } completion:^(BOOL finished) {
        if (_views)
        {
            for (SMBImageView *imageView in _views)
                [imageView removeFromSuperview];
            _views = nil;
        }
    }];
}


@end
