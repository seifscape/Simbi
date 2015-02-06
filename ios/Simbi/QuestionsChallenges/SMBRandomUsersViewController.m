//
//  SMBRandomUsersViewController.m
//  Simbi
//
//  Created by flynn on 5/22/14.
//  Copyright (c) 2014 MaxxPotential. All rights reserved.
//

#import "SMBRandomUsersViewController.h"

#import "SMBAskQuestionViewController.h"
#import "SMBAnswerQuestionViewController.h"
#import "SMBChatButton.h"
#import "SMBHeadsUpViewController.h"
#import "SMBImageView.h"
#import "SMBQuestionViewController.h"
#import "SMBSelectChallengeViewController.h"
#import "SMBUserView.h"
#import "SMBViewChallengeViewController.h"


@interface SMBRandomUsersViewController ()

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) iCarousel *carousel;

@end


@implementation SMBRandomUsersViewController

- (id)initWithUsers:(NSArray *)users
{
    self = [super init];
    
    if (self)
        _users = users;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationItem setTitle:@"Random"];
    
    [self.navigationItem setRightBarButtonItem:[[SMBChatButton alloc] initWithTarget:self action:@selector(chatAction)]];
    
    
    // Create views
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    // Carousel - have carousel go behind the status and nav bar to allow some vertical space between its views
    
    UIView *carouselContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height/2.f+44)];
    [carouselContainerView setClipsToBounds:YES];
    
    _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(44, 0, width-88, height/2.f+44)];
    [_carousel setDataSource:self];
    [_carousel setDelegate:self];
    [_carousel setType:iCarouselTypeInvertedWheel];
    [_carousel setBounces:YES];
    [carouselContainerView addSubview:_carousel];
    
    [self.view addSubview:carouselContainerView];
    
    
    // Bottom View
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height/2.f+44, width, height/2.f-44)];
    [bottomView setBackgroundColor:[UIColor simbiLightGrayColor]];
    
    // Container view to center the buttons in bottomView
    UIView *buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, (bottomView.frame.size.height-88-8)/2.f, width, 88+8)];
    
    UIButton *questionButton = [UIButton simbiBlueButtonWithFrame:CGRectMake(44, 0, width-88, 44)];
    [questionButton setTitle:@"Answer Question" forState:UIControlStateNormal];
    [questionButton addTarget:self action:@selector(questionAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainerView addSubview:questionButton];
    
    UIButton *challengeButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, 44+8, width-88, 44)];
    [challengeButton setTitle:@"Challenge" forState:UIControlStateNormal];
    [challengeButton addTarget:self action:@selector(challengeAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainerView addSubview:challengeButton];
    
    [bottomView addSubview:buttonContainerView];
    
    [self.view addSubview:bottomView];
}


#pragma mark - User Actions

- (void)chatAction
{
    SMBHeadsUpViewController *viewController = [[SMBHeadsUpViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)questionAction
{
    SMBUser *selectedUser = [_users objectAtIndex:_carousel.currentItemIndex];
    
    SMBAnswerQuestionViewController *viewController = [[SMBAnswerQuestionViewController alloc] initWithUser:selectedUser];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)challengeAction
{
    SMBUser *selectedUser = [_users objectAtIndex:_carousel.currentItemIndex];
    
    SMBSelectChallengeViewController *viewController = [[SMBSelectChallengeViewController alloc] initWithUser:selectedUser];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - iCarouselDataSource/Delegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return _users.count;
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.width, carousel.frame.size.height)];
    
    SMBUserView *userView = [[SMBUserView alloc] initWithFrame:CGRectMake(0, 20+44, carousel.frame.size.width, carousel.frame.size.height-20-44) isRevealed:NOgit ];
    [userView setUser:[_users objectAtIndex:index]];
    [containerView addSubview:userView];
    
    return containerView;
}


@end
