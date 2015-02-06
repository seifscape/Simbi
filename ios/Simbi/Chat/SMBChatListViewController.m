//
//  SMBChatListViewController.m
//  Simbi
//
//  Created by flynn on 5/22/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChatListViewController.h"

#import "SMBAppDelegate.h"
#import "SMBChallengeChatListTableView.h"
#import "SMBChatViewController.h"
#import "SMBQuestionChatListTableView.h"


@interface SMBChatListViewController ()

@property (nonatomic, strong) SMBQuestionChatListTableView *chatTableView;
@property (nonatomic, strong) SMBChallengeChatListTableView *challengeTableView;

@property (nonatomic, strong) UISegmentedControl *viewSelectorControl;

@end


@implementation SMBChatListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.view setClipsToBounds:YES];
    
    if (self.presentingViewController)
    {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction:)];
        [self.navigationItem setLeftBarButtonItem:backButton];
    }
    

    // Set up views
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    _chatTableView = [[SMBQuestionChatListTableView alloc] initWithFrame:CGRectMake(0, 20+44, width, height-44)];
    [_chatTableView setManagerDelegate:self];
    [self.view addSubview:_chatTableView];
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    [swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_chatTableView addGestureRecognizer:swipeLeftGesture];
    
    // Gesture to pop view controller or show menu
    UISwipeGestureRecognizer *swipeFarRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeFarRightAction:)];
    [swipeFarRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [_chatTableView addGestureRecognizer:swipeFarRightGesture];
    
    _challengeTableView = [[SMBChallengeChatListTableView alloc] initWithFrame:CGRectMake(width, 20+44, width, height-44)];
    [_challengeTableView setManagerDelegate:self];
    [self.view addSubview:_challengeTableView];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightAction:)];
    [swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [_challengeTableView addGestureRecognizer:swipeRightGesture];
    
    
    _viewSelectorControl = [[UISegmentedControl alloc] initWithItems:@[@"Chats", @"Games"]];
    [_viewSelectorControl setFrame:CGRectMake(66, 6, width-132, 44-12)];
    [_viewSelectorControl setTintColor:[UIColor simbiBlueColor]];
    [_viewSelectorControl setSelectedSegmentIndex:0];
    [_viewSelectorControl addTarget:self action:@selector(viewSelectorDidChange:) forControlEvents:UIControlEventValueChanged];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES];
    [[SMBAppDelegate instance] enableSideMenuGesture:NO];
    
    [_viewSelectorControl addToView:self.navigationController.navigationBar andAnimate:YES];
    
    [_chatTableView sortChats];
    [_challengeTableView sortChats];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationHideChatIcon object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[SMBAppDelegate instance] enableSideMenuGesture:YES];
    
    if (!([self.navigationController.visibleViewController class] == [SMBChatViewController class] || [self.navigationController.visibleViewController class] == [SMBChallengeViewController class]))
    {        
        [[SMBUser currentUser] setUnreadMessageCount:@0];
        [[SMBUser currentUser] setHasNewMessage:NO];
        [[SMBUser currentUser] saveInBackground];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationHideChatIcon object:nil];
    }
    
    [_viewSelectorControl removeFromViewAndAnimate:YES];
}


- (void)dismissAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - User Actions

- (void)viewSelectorDidChange:(UISegmentedControl *)viewSelectorControl
{
    CGFloat width  = self.view.frame.size.width;
    
    if (viewSelectorControl.selectedSegmentIndex == 0)
    {
        [UIView animateWithDuration:0.25f animations:^{
            [_chatTableView setFrame:CGRectMake(0, _chatTableView.frame.origin.y, width, _chatTableView.frame.size.height)];
            [_challengeTableView setFrame:CGRectMake(width, _challengeTableView.frame.origin.y, width, _challengeTableView.frame.size.height)];
        }];
    }
    else if (viewSelectorControl.selectedSegmentIndex == 1)
    {
        [UIView animateWithDuration:0.25f animations:^{
            [_chatTableView setFrame:CGRectMake(-width, _chatTableView.frame.origin.y, width, _chatTableView.frame.size.height)];
            [_challengeTableView setFrame:CGRectMake(0, _challengeTableView.frame.origin.y, width, _challengeTableView.frame.size.height)];
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


#pragma mark - SMBManagerTableViewDeleagate

- (void)managerTableView:(SMBManagerTableView *)tableView didSelectObject:(id)object
{
    if ([object isKindOfClass:[SMBChat class]])
    {
        BOOL isViewingChat = [tableView isKindOfClass:[SMBQuestionChatListTableView class]];
        
        SMBChatViewController *viewController = [SMBChatViewController messagesViewControllerWithChat:(SMBChat *)object isViewingChat:isViewingChat];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


@end
