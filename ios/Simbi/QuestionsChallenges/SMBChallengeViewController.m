//
//  SMBChallengeViewController.m
//  Simbi
//
//  Created by flynn on 5/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChallengeViewController.h"

#import "SMBGameView.h"
    #import "SMBPokeORamaGameView.h"
    #import "SMBDrinkRouletteGameView.h"
#import "SMBImageView.h"


@implementation SMBChallengeViewController

- (id)initWithChallenge:(SMBChallenge *)challenge
{
    self = [super init];
    
    if (self)
        _challenge = challenge;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor simbiWhiteColor]];
    
    if (self.presentingViewController)
    {
        UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction:)];
        [self.navigationItem setLeftBarButtonItem:dismissButton];
    }
    
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    if (_challenge.accepted || !_challenge.toUser)
    {
        // If accepted or playing by themselves, show the game
        
        [self launchGameWithAnimation:NO];
    }
    else if ([[SMBUser currentUser].objectId isEqualToString:_challenge.toUser.objectId])
    {
        // If it's not accepted and this is the recipient user, show them the prompt to accept
        
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        SMBImageView *profilePictureView;
        
        if ([_challenge.chat userOneRevealed])
            profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake((width-88)/2.f, 20+44+20, 88, 88) parseImage:[_challenge otherUser].profilePicture];
        else
            profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake((width-88)/2.f, 20+44+20, 88, 88) rawImage:[UIImage imageNamed:@"Silhouette.png"]];
        [profilePictureView setBackgroundColor:[UIColor randomPreferenceColorForName:[_challenge otherUser].name]];
        [profilePictureView.layer setCornerRadius:profilePictureView.frame.size.width/2.f];
        [profilePictureView.layer setMasksToBounds:YES];
        [self.view addSubview:profilePictureView];
        
        UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20+44+88+44, width, 44)];
        [challengeLabel setText:[NSString stringWithFormat:@"%@ has challenged you to:", [_challenge otherUser].name]];
        [challengeLabel setTextColor:[UIColor simbiRedColor]];
        [challengeLabel setFont:[UIFont simbiBoldFontWithSize:15.f]];
        [challengeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:challengeLabel];
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 20+44+88+88, width, height-20-44-88-88)];
        [bottomView setBackgroundColor:[UIColor simbiWhiteColor]];
        
        UIView *cardView = [_challenge cardViewForFrame:CGRectMake(44, 20, width-88, bottomView.frame.size.height-44-20*3)];
        [bottomView addSubview:cardView];
        
        UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [acceptButton setFrame:CGRectMake(44, bottomView.frame.size.height-44-20, (width-88)/2.f, 44)];
        [acceptButton setBackgroundColor:[UIColor simbiBlueColor]];
        [acceptButton setTitle:@"✓" forState:UIControlStateNormal];
        [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [acceptButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:36.f]];
        [acceptButton addTarget:self action:@selector(acceptAction:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:acceptButton];
        
        UIButton *declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [declineButton setFrame:CGRectMake(width/2.f, bottomView.frame.size.height-44-20, (width-88)/2.f, 44)];
        [declineButton setBackgroundColor:[UIColor simbiRedColor]];
        [declineButton setTitle:@"✕" forState:UIControlStateNormal];
        [declineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [declineButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:36.f]];
        [declineButton addTarget:self action:@selector(declineAction:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:declineButton];
        
        [self.view addSubview:bottomView];
    }
    else
    {
        // If they're the sender and the game hasn't been accepted yet, keep them out
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20+44, width, height-20-44)];
        [label setText:[NSString stringWithFormat:@"Waiting for %@ to accept...", [_challenge otherUser].name]];
        [label setTextColor:[UIColor simbiDarkGrayColor]];
        [label setFont:[UIFont simbiLightFontWithSize:24.f]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setNumberOfLines:0];
        [self.view addSubview:label];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}


- (void)dismissAction:(UIBarButtonItem *)barButtonItem
{
    if (self.presentingViewController)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}


- (void)launchGameWithAnimation:(BOOL)animated
{
    CGRect frame = CGRectMake(0, 20+44, self.view.frame.size.width, self.view.frame.size.height-20-44);
    
    switch ([_challenge challengeTypeEnum])
    {
        case kSMBChallengeTypePokeORama:
            _gameView = [[SMBPokeORamaGameView alloc] initWithFrame:frame challenge:_challenge];
            break;
        
        case kSMBChallengeTypeDrinkRoulette:
            _gameView = [[SMBDrinkRouletteGameView alloc] initWithFrame:frame challenge:_challenge];
            break;
        
        default:
            NSLog(@"%s - WARNING: No challenge type for the current challenge!", __PRETTY_FUNCTION__);
            break;
    }
    
    if (_gameView)
    {
        if (animated)
        {
            [_gameView setAlpha:0.f];
            [UIView animateWithDuration:0.5f animations:^{
                [_gameView setAlpha:1.f];
            }];
        }
        
        [_gameView setDelegate:self];
        [self.view addSubview:_gameView];
        
        
    }
}


#pragma mark - User Actions

- (void)acceptAction:(UIButton *)button
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Accepting..." parent:self];
    
    [PFCloud callFunctionInBackground:@"acceptChallenge" withParameters:@{ @"challengeId" : _challenge.objectId } block:^(NSString *response, NSError *error) {
        
        if (response)
        {
            [_challenge setAccepted:YES];
            
            [hud dismissQuickly];
            
            if (_delegate)
                [_delegate challengeViewController:self didAcceptWithChatMessage:response];
            
            [self launchGameWithAnimation:YES];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [hud dismissWithError];
        }
    }];
}


- (void)declineAction:(UIButton *)button
{
    [_challenge setAccepted:NO];
    [_challenge setDeclined:YES];
    [_challenge saveInBackground];
    
    if (self.presentingViewController)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            if (_delegate)
                [_delegate challengeViewControllerDidDecline:self];
        }];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        
        if (_delegate)
            [_delegate challengeViewControllerDidDecline:self];
    }
}


#pragma mark - SMBGameViewDelegate

- (void)gameViewShouldDismiss:(SMBGameView *)gameView
{
    if (self.presentingViewController)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}


- (void)gameView:(SMBGameView *)gameView gameDidFinishWithVictory:(BOOL)didWin
{
    if (didWin)
        [_challenge setWinner:[SMBUser currentUser]];
    else
        [_challenge setWinner:[_challenge otherUser]];
    [_challenge saveInBackground];
    
    if (self.presentingViewController)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}


@end
