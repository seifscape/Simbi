//
//  SMBUserDetailViewController.m
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBUserDetailViewController.h"

#import "MBProgressHUD.h"

#import "_SMBChatButton.h"
#import "SMBFriendRequestsManager.h"
#import "SMBChatListViewController.h"
#import "SMBUserView.h"


@interface SMBUserDetailViewController ()

@property (nonatomic, strong) SMBUser *user;

@property (nonatomic, strong) SMBUserView *userView;
@property (nonatomic, strong) UIView *bottomView;

@end


@implementation SMBUserDetailViewController

- (id)initWithUser:(SMBUser *)user
{
    self = [super init];
    
    if (self)
        _user = user;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:[[_SMBChatButton alloc] initWithTarget:self action:@selector(chatAction)]];
    
    [self.navigationItem setTitle:@"User"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    // Create views
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    _userView = [[SMBUserView alloc] initWithFrame:CGRectMake(0, 20+44, width, height/2.f-20) isRevealed:YES];
    [_userView setUser:_user];
    [self.view addSubview:_userView];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height/2.f+44, width, height/2.f-44)];
    [_bottomView setBackgroundColor:[UIColor simbiWhiteColor]];
    
    UIButton *friendRequestButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, (_bottomView.frame.size.height-44)/2.f, width-88, 44)];
    [friendRequestButton setTitle:@"Send Friend Request" forState:UIControlStateNormal];
    [friendRequestButton addTarget:self action:@selector(friendRequestAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:friendRequestButton];
    
    [self.view addSubview:_bottomView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}


#pragma mark - User Actions

- (void)chatAction
{
    SMBChatListViewController *viewController = [[SMBChatListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)friendRequestAction:(UIButton *)button
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Sending..." parent:self];
    
    NSDictionary *params = @{ @"toUser": _user.objectId };
    
    [PFCloud callFunctionInBackground:@"sendFriendRequest" withParameters:params block:^(id object, NSError *error) {
        
        if (object)
        {
            [hud dismissWithMessage:@"Sent!"];
            [button setEnabled:NO];
            
            [UIView animateWithDuration:0.5f animations:^{
                [button setBackgroundColor:[UIColor grayColor]];
            }];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            
            if ([[error.userInfo objectForKey:@"error"] isEqualToString:@"Friend request already exists"])
            {
                [hud dismissWithMessage:@"Friend Request Still Pending"];
                
                [button setEnabled:NO];
                
                [UIView animateWithDuration:0.5f animations:^{
                    [button setBackgroundColor:[UIColor grayColor]];
                }];
            }
            else
                [hud dismissWithError];
        }
    }];
}


@end
