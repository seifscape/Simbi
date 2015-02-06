//
//  SMBSelectChallengeViewController.m
//  Simbi
//
//  Created by flynn on 5/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBSelectChallengeViewController.h"

#import "MBProgressHUD.h"

#import "SMBChatManager.h"
#import "SMBChallengeViewController.h"
#import "_SMBChatButton.h"
#import "SMBChatListViewController.h"
#import "SMBFriendsManager.h"


@interface SMBSelectChallengeViewController ()

@property (nonatomic, strong) SMBUser *user;
@property (nonatomic, strong) iCarousel *carousel;

@end


@implementation SMBSelectChallengeViewController

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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    if (_user)
        [self setTitle:@"Challenge"];
    else
        [self setTitle:@"Games"];
    
    if (self.presentingViewController)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction)];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:[[_SMBChatButton alloc] initWithTarget:self action:@selector(chatAction)]];
    }
    
    
    // Create views
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat topHeight = ([UIScreen mainScreen].bounds.size.height > 480.f ? 110 : 66);

    
    if (_user)
    {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20+44+(topHeight-44)/2.f, width, 22)];
        [nameLabel setText:_user.name];
        [nameLabel setTextColor:[UIColor darkGrayColor]];
        [nameLabel setFont:[UIFont simbiBoldFontWithSize:14.f]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:nameLabel];
        
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLabel.frame.origin.y+22, width, 22)];
        [locationLabel setText:[_user cityAndState]];
        [locationLabel setTextColor:[UIColor darkGrayColor]];
        [locationLabel setFont:[UIFont simbiFontWithSize:14.f]];
        [locationLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:locationLabel];
    }
    else
        topHeight = 0;

    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 20+44+topHeight, width, height-20-44-topHeight)];
    [bottomView setBackgroundColor:[UIColor simbiWhiteColor]];
    
    if (_user)
    {
        UILabel *gameLibraryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
        [gameLibraryLabel setText:@"Game Library"];
        [gameLibraryLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [gameLibraryLabel setFont:[UIFont simbiLightFontWithSize:16.f]];
        [gameLibraryLabel setTextAlignment:NSTextAlignmentCenter];
        [bottomView addSubview:gameLibraryLabel];
    }
    
    UIView *carouselContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, bottomView.frame.size.height-(_user ? 0: 88))];
    [carouselContainerView setClipsToBounds:YES];
    
    _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0,
                                                            (_user ? 44 : 88),
                                                            width,
                                                            bottomView.frame.size.height-(_user ? 44 : 132))];
    [_carousel setDataSource:self];
    [_carousel setDelegate:self];
    [_carousel setType:iCarouselTypeCylinder];
    [carouselContainerView addSubview:_carousel];
    
    [bottomView addSubview:carouselContainerView];
    
    UIButton *challengeButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, bottomView.frame.size.height-66, width-88, 44)];
    if (_user)
        [challengeButton setTitle:@"Challenge Now" forState:UIControlStateNormal];
    else
        [challengeButton setTitle:@"Play" forState:UIControlStateNormal];
    [challengeButton addTarget:self action:@selector(challengeAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:challengeButton];
    
    [self.view addSubview:bottomView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}


#pragma mark - User Actions

- (void)dismissAction
{
    if (self.presentingViewController)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}


- (void)chatAction
{
    SMBChatListViewController *viewController = [[SMBChatListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)challengeAction
{
    [_carousel scrollToItemAtIndex:_carousel.currentItemIndex duration:0.125f];
    
    SMBChallengeType challengeType = _carousel.currentItemIndex % kSMBChallengeTypeCount;
    
    if (_user)
    {
        SMBChallenge *challenge = [[SMBChallenge alloc] init];
        [challenge setFromUser:[SMBUser currentUser]];
        [challenge setToUser:_user];
        [challenge setChallengeType:[SMBChallenge stringForChallengeType:challengeType]];
        [challenge setChallengeName:[SMBChallenge nameForChallengeType:challengeType]];
        
        MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Challenging..." parent:self];
        
        [challenge saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                BOOL isFriend = NO;
                
                for (SMBUser *existingFriend in [SMBFriendsManager sharedManager].objects)
                    if ([_user.objectId isEqualToString:existingFriend.objectId])
                        isFriend = YES;
                
                NSDictionary *params = @{ @"challengeId": challenge.objectId,
                                          @"isFriend": [NSNumber numberWithBool:isFriend] };
                
                [PFCloud callFunctionInBackground:@"createChatForChallenge" withParameters:params block:^(NSString *chatId, NSError *error) {
                    
                    if (chatId)
                    {
                        [[SMBChatManager sharedManager] addChatWithId:chatId callback:^(BOOL succeeded) {
                            [hud dismissWithSuccess];
                            [self performSelector:@selector(dismissAction) withObject:nil afterDelay:1.f];
                        }];
                    }
                    else
                    {
                        NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                        [hud dismissWithError];
                        
                        [challenge deleteEventually];
                    }
                }];
            }
            else
            {
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                [hud dismissWithError];
            }
        }];
    }
    else
    {
        // Play by yourself
        
        SMBChallenge *challenge = [[SMBChallenge alloc] init];
        [challenge setChallengeType:[SMBChallenge stringForChallengeType:challengeType]];
        [challenge setChallengeName:[SMBChallenge nameForChallengeType:challengeType]];
        
        SMBChallengeViewController *viewController = [[SMBChallengeViewController alloc] initWithChallenge:challenge];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
}


#pragma mark - iCarouselDataSource/Delegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 18;
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    CGFloat width  = carousel.frame.size.width;
    CGFloat height = carousel.frame.size.height;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width-44, height)];
    
    UIView *gameView = [SMBChallenge cardViewForIndex:index%kSMBChallengeTypeCount frame:CGRectMake(22, 0, width-88, height-88)];
    [gameView.layer setCornerRadius:10.f];
    [containerView addSubview:gameView];
    
    return containerView;
}


@end
