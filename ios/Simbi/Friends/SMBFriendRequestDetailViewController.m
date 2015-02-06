//
//  SMBFriendRequestDetailViewController.m
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendRequestDetailViewController.h"

#import "MBProgressHUD.h"

#import "_SMBChatButton.h"
#import "SMBFriendsManager.h"
#import "SMBFriendRequestsManager.h"
#import "SMBChatListViewController.h"
#import "SMBUserView.h"


@interface SMBFriendRequestDetailViewController ()

@property (nonatomic, strong) SMBFriendRequest *friendRequest;

@property (nonatomic, strong) SMBUserView *userView;
@property (nonatomic, strong) UIView *bottomView;

@end


@implementation SMBFriendRequestDetailViewController

- (id)initWithFriendRequest:(SMBFriendRequest *)request
{
    self = [super init];
    
    if (self)
        _friendRequest = request;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:[[_SMBChatButton alloc] initWithTarget:self action:@selector(chatAction)]];
    
    [self.navigationItem setTitle:@"Friend Request"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    // Create views
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    _userView = [[SMBUserView alloc] initWithFrame:CGRectMake(0, 20+44, width, height/2.f-20) isRevealed:YES];
    [_userView setUser:_friendRequest.fromUser];
    [self.view addSubview:_userView];
    
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height/2.f+44, width, height/2.f-44)];
    [_bottomView setBackgroundColor:[UIColor simbiWhiteColor]];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 66)];
    [messageLabel setText:[NSString stringWithFormat:@"%@ sent you a friend request!", _friendRequest.fromUser.name]];
    [messageLabel setTextColor:[UIColor simbiDarkGrayColor]];
    [messageLabel setFont:[UIFont simbiLightFontWithSize:18.f]];
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    [messageLabel setNumberOfLines:2];
    [_bottomView addSubview:messageLabel];
    
    UIView *buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, (_bottomView.frame.size.height-88-8)/2.f, width, 88+8)];
    
    UIButton *acceptRequestButton = [UIButton simbiBlueButtonWithFrame:CGRectMake(44, 0, width-88, 44)];
    [acceptRequestButton setTitle:@"Accept Friend Request" forState:UIControlStateNormal];
    [acceptRequestButton addTarget:self action:@selector(acceptFriendRequestAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainerView addSubview:acceptRequestButton];
    
    UIButton *declineRequestButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, 44+8, width-88, 44)];
    [declineRequestButton setTitle:@"Decline Friend Request" forState:UIControlStateNormal];
    [declineRequestButton addTarget:self action:@selector(declineFriendRequestAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainerView addSubview:declineRequestButton];
    
    [_bottomView addSubview:buttonContainerView];
    
    [self.view addSubview:_bottomView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}


#pragma mark - User Actions

- (void)dismissAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)chatAction
{
    SMBChatListViewController *viewController = [[SMBChatListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)acceptFriendRequestAction
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Accepting..." parent:self];
    [self.view setUserInteractionEnabled:NO];
    
    NSDictionary *params = @{ @"friendRequest": _friendRequest.objectId };
    
    [PFCloud callFunctionInBackground:@"acceptFriendRequest" withParameters:params block:^(id object, NSError *error) {
        
        if (object)
        {
            [[SMBFriendsManager sharedManager] addObject:_friendRequest.fromUser];
            [[SMBFriendRequestsManager sharedManager] removeObject:_friendRequest];
            
            [hud dismissWithMessage:@"Accepted!"];
            [self performSelector:@selector(dismissAction) withObject:nil afterDelay:1.f];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [hud dismissWithError];
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}


- (void)declineFriendRequestAction
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Declining..." parent:self];
    [self.view setUserInteractionEnabled:NO];
    
    NSDictionary *params = @{ @"friendRequest": _friendRequest.objectId };
    
    [PFCloud callFunctionInBackground:@"declineFriendRequest" withParameters:params block:^(id object, NSError *error) {
        
        if (object)
        {
            [[SMBFriendRequestsManager sharedManager] removeObject:_friendRequest];
            
            [hud dismissWithMessage:@"Declined"];
            [self performSelector:@selector(dismissAction) withObject:nil afterDelay:1.f];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [hud dismissWithError];
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}


@end
