//
//  SMBFriendsListViewController.m
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBFriendsListViewController.h"

#import "SMBAppDelegate.h"
#import "_SMBChatButton.h"
#import "SMBChatListViewController.h"
#import "SMBFacebookFriendsViewController.h"
#import "SMBFindFriendsViewController.h"
#import "SMBFriendDetailViewController.h"
#import "SMBFriendsTableView.h"
#import "SMBFriendRequestsTableView.h"
#import "SMBFriendRequestDetailViewController.h"


@interface _SMBFriendsListViewController ()

@property (nonatomic, strong) SMBFriendsTableView *friendsTableView;
@property (nonatomic, strong) SMBFriendRequestsTableView *friendRequestsTableView;

@property (nonatomic, strong) UISegmentedControl *viewSelectorControl;

@end


@implementation _SMBFriendsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self.navigationItem setRightBarButtonItem:[[_SMBChatButton alloc] initWithTarget:self action:@selector(chatAction)]];
    
    
    // Set up views
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    _friendsTableView = [[SMBFriendsTableView alloc] initWithFrame:CGRectMake(0, 20+44, width, height-20-44)];
    [_friendsTableView setManagerDelegate:self];
    [_friendsTableView setParent:self];
    [self.view addSubview:_friendsTableView];
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    [swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_friendsTableView addGestureRecognizer:swipeLeftGesture];
    
    // Gesture to pop view controller or show menu
    UISwipeGestureRecognizer *swipeFarRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeFarRightAction:)];
    [swipeFarRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [_friendsTableView addGestureRecognizer:swipeFarRightGesture];
    
    _friendRequestsTableView = [[SMBFriendRequestsTableView alloc] initWithFrame:CGRectMake(width, 20+44, width, height-20-44)];
    [_friendRequestsTableView setManagerDelegate:self];
    [_friendRequestsTableView setParent:self];
    [self.view addSubview:_friendRequestsTableView];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightAction:)];
    [swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [_friendRequestsTableView addGestureRecognizer:swipeRightGesture];
    
    
    _viewSelectorControl = [[UISegmentedControl alloc] initWithItems:@[@"Friends", @"Requests"]];
    [_viewSelectorControl setFrame:CGRectMake(66, 6, width-132, 44-12)];
    [_viewSelectorControl setTintColor:[UIColor simbiBlueColor]];
    [_viewSelectorControl setSelectedSegmentIndex:0];
    [_viewSelectorControl addTarget:self action:@selector(viewSelectorDidChange:) forControlEvents:UIControlEventValueChanged];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
    
    [_viewSelectorControl addToView:self.navigationController.navigationBar andAnimate:YES];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[SMBAppDelegate instance] enableSideMenuGesture:NO];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_viewSelectorControl removeFromViewAndAnimate:YES];
    
    [[SMBAppDelegate instance] enableSideMenuGesture:YES];
}


#pragma mark - User Actions

- (void)chatAction
{
    SMBChatListViewController *viewController = [[SMBChatListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)viewSelectorDidChange:(UISegmentedControl *)viewSelectorControl
{
    CGFloat width  = self.view.frame.size.width;
    
    if (viewSelectorControl.selectedSegmentIndex == 0)
    {
        [UIView animateWithDuration:0.25f animations:^{
            [_friendsTableView setFrame:CGRectMake(0, _friendsTableView.frame.origin.y, width, _friendsTableView.frame.size.height)];
            [_friendRequestsTableView setFrame:CGRectMake(width, _friendRequestsTableView.frame.origin.y, width, _friendRequestsTableView.frame.size.height)];
        }];
    }
    else if (viewSelectorControl.selectedSegmentIndex == 1)
    {        
        [UIView animateWithDuration:0.25f animations:^{
            [_friendsTableView setFrame:CGRectMake(-width, _friendsTableView.frame.origin.y, width, _friendsTableView.frame.size.height)];
            [_friendRequestsTableView setFrame:CGRectMake(0, _friendRequestsTableView.frame.origin.y, width, _friendRequestsTableView.frame.size.height)];
        }];
    }
}


- (void)swipeLeftAction:(UIGestureRecognizer *)gestureRecognizer
{
    [_viewSelectorControl setSelectedSegmentIndex:1];
    [self viewSelectorDidChange:_viewSelectorControl];
}


- (void)swipeRightAction:(UIGestureRecognizer *)gestureRecognizer
{
    [_viewSelectorControl setSelectedSegmentIndex:0];
    [self viewSelectorDidChange:_viewSelectorControl];
}


- (void)swipeFarRightAction:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.navigationController.viewControllers firstObject] != self)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [[SMBAppDelegate instance] showMenu];
}


#pragma mark - PublicMethods

- (void)updateRequestCountWithNumber:(NSInteger)requestCount
{
    UISegmentedControl *oldViewSelectorControl = _viewSelectorControl;
    
    NSString *requestsTitle = @"Requests";
    
    if (requestCount > 0)
        requestsTitle = [NSString stringWithFormat:@"Requests (%ld)", (long)requestCount];
    
    _viewSelectorControl = [[UISegmentedControl alloc] initWithItems:@[@"Friends", requestsTitle]];
    [_viewSelectorControl setFrame:oldViewSelectorControl.frame];
    [_viewSelectorControl setTintColor:oldViewSelectorControl.tintColor];
    [_viewSelectorControl setSelectedSegmentIndex:oldViewSelectorControl.selectedSegmentIndex];
    [_viewSelectorControl addTarget:self action:@selector(viewSelectorDidChange:) forControlEvents:UIControlEventValueChanged];
    if (self.navigationController.visibleViewController == self)
        [_viewSelectorControl addToView:self.navigationController.navigationBar andAnimate:NO];
    
    [oldViewSelectorControl removeFromSuperview];
}


- (void)findFriendsAction
{    
    SMBFindFriendsViewController *viewController = [[SMBFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)facebookFriendsAction
{
    SMBFacebookFriendsViewController *viewController = [[SMBFacebookFriendsViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - SMBManagerTableViewDelegate

- (void)managerTableView:(SMBManagerTableView *)tableView didSelectObject:(id)object
{
    if ([object isKindOfClass:[SMBUser class]])
    {
        SMBFriendDetailViewController *viewController = [[SMBFriendDetailViewController alloc] initWithUser:(SMBUser *)object];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ([object isKindOfClass:[SMBFriendRequest class]])
    {
        SMBFriendRequestDetailViewController *viewController = [[SMBFriendRequestDetailViewController alloc] initWithFriendRequest:(SMBFriendRequest *)object];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


@end
