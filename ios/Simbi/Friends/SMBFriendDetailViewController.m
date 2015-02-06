//
//  SMBFriendDetailViewController.m
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendDetailViewController.h"

#import "_SMBChatButton.h"
#import "SMBChatListViewController.h"
#import "SMBUserView.h"


@interface SMBFriendDetailViewController ()

@property (nonatomic, strong) SMBUser *user;

@property (nonatomic, strong) SMBUserView *userView;
@property (nonatomic, strong) UIView *bottomView;

@end


@implementation SMBFriendDetailViewController

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
    
    [self.navigationItem setTitle:@"Friend"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    // Create views
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    _userView = [[SMBUserView alloc] initWithFrame:CGRectMake(0, 20+44, width, height/2.f-20) isRevealed:YES];
    [_userView setUser:_user];
    [self.view addSubview:_userView];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height/2.f+44, width, height/2.f-44)];
    [_bottomView setBackgroundColor:[UIColor simbiWhiteColor]];
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


@end
