//
//  SMBPokeORamaGameView.m
//  Simbi
//
//  Created by flynn on 6/11/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBPokeORamaGameView.h"

#import "MBProgressHUD.h"

#import "SMBUserView.h"


@interface SMBPokeORamaGameView ()

@property (nonatomic, strong) UILabel *pokeLabel;
@property (nonatomic, strong) SMBUserView *userView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, readonly) NSInteger numberOfPokes;

@end


@implementation SMBPokeORamaGameView


#pragma mark - Definitions

static NSString *kActionType_Poke        = @"poke";
static NSString *kActionType_Surrender   = @"surrender";

static NSString *kInfoKey_PokeCount      = @"pokeCount";

- (NSInteger)numberOfPokes
{
    return (self.challengeInfo[kInfoKey_PokeCount] ? [self.challengeInfo[kInfoKey_PokeCount] integerValue] : 0);
}


#pragma mark - SMBGameView Methods

+ (UIView *)cardWithFrame:(CGRect)frame
{
    UIView *cardView = [[UIView alloc] initWithFrame:frame];
    [cardView setBackgroundColor:[UIColor simbiGreenColor]];
    
    UILabel *pokeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height-66)];
    [pokeLabel setText:@"👉"];
    [pokeLabel setFont:[UIFont systemFontOfSize:120.f]];
    [pokeLabel setTextAlignment:NSTextAlignmentCenter];
    [pokeLabel setAlpha:0.33f];
    [cardView addSubview:pokeLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 66)];
    [titleLabel setText:@"Poke-O-Rama"];
    [titleLabel setTextColor:[UIColor simbiDarkGrayColor]];
    [titleLabel setFont:[UIFont simbiBoldFontWithSize:24.f]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [cardView addSubview:titleLabel];
    
    return cardView;
}


- (void)setUpGame
{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    
    _pokeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    [_pokeLabel setText:[NSString stringWithFormat:@"Pokes: %ld", (long)self.numberOfPokes]];
    [_pokeLabel setTextColor:[UIColor simbiDarkGrayColor]];
    [_pokeLabel setFont:[UIFont simbiLightFontWithSize:18.f]];
    [_pokeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_pokeLabel];
    
    if (self.isPlayingAlone)
    {
        _userView = [[SMBUserView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height-44*2-20*2-8-44) isRevealed:NO];
        
        SMBUser *dummyUser = [[SMBUser alloc] init];
        [dummyUser setFirstName:@"No one"];
        
        [_userView setUser:dummyUser];
        [_userView.profilePictureView setBackgroundColor:[UIColor simbiRedColor]];
        [self addSubview:_userView];
    }
    else
    {
        _userView = [[SMBUserView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height-44*2-20*2-8-44) isRevealed:self.otherUserRevealed];
        [_userView setUser:self.otherUser];
        [self addSubview:_userView];
    }
    
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-44*2-20*2-8, self.frame.size.width, 44*2+20*2+8)];
    [_bottomView setBackgroundColor:[UIColor simbiWhiteColor]];
    
     UIButton *pokeButton = [UIButton simbiBlueButtonWithFrame:CGRectMake(44, 20, self.frame.size.width-88, 44)];
     [pokeButton setTitle:@"Poke" forState:UIControlStateNormal];
     [pokeButton addTarget:self action:@selector(pokeAction:) forControlEvents:UIControlEventTouchUpInside];
     [_bottomView addSubview:pokeButton];
    
     UIButton *surrenderButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, 20+44+8, self.frame.size.width-88, 44)];
     [surrenderButton setTitle:@"Surrender" forState:UIControlStateNormal];
     [surrenderButton addTarget:self action:@selector(surrenderAction:) forControlEvents:UIControlEventTouchUpInside];
     [_bottomView addSubview:surrenderButton];
    
    [self addSubview:_bottomView];
}


- (void)startGame
{
    // Do nothing
}


- (void)stopGame
{
    // Do nothing
}


- (void)challengeActionReceived:(NSString *)actionType
{
    if ([actionType isEqualToString:kActionType_Poke])
    {
        [self showPoke];
    }
    else if ([actionType isEqualToString:kActionType_Surrender])
    {
        [self.challenge setWinner:[SMBUser currentUser]];
        
        [self showSurrender];
    }
    else
        NSLog(@"%s - WARNING: Received an unrecognized actionType \"%@\"", __PRETTY_FUNCTION__, actionType);
}


- (void)otherUserDidReveal
{
    // Replace the current userView with a new, revealed one
    
    CGRect frame = _userView.frame;
    [_userView removeFromSuperview];
    _userView = [[SMBUserView alloc] initWithFrame:frame isRevealed:YES];
    [_userView setUser:[self.challenge otherUser]];
    [self addSubview:_userView];
}


#pragma mark - ChallengeAction Handling

- (void)showPoke
{
    [MBProgressHUD showMessage:@"POKED!" parent:(UIViewController *)self.delegate];
    
    [_pokeLabel setText:[NSString stringWithFormat:@"Pokes: %ld", (long)self.numberOfPokes]]; // Update the label
    
    
    // Throw a poke across the screen
    
    UILabel *poke = [[UILabel alloc] initWithFrame:CGRectMake(-88, arc4random()%(int)self.frame.size.height, 88, 88)];
    [poke setText:@"👉"];
    [poke setFont:[UIFont systemFontOfSize:42.f]];
    [poke setTransform:CGAffineTransformMakeRotation((arc4random()%32)*M_PI/8)];
    [self addSubview:poke];
    
    [UIView animateWithDuration:1.f animations:^{
        [poke setFrame:CGRectMake(self.frame.size.width+88, arc4random()%(int)self.frame.size.height, 88, 88)];
        [poke setTransform:CGAffineTransformMakeRotation((arc4random()%32)*M_PI/8)];
    } completion:^(BOOL finished) {
        [poke removeFromSuperview];
    }];
}


- (void)showSurrender
{
    [UIView animateWithDuration:0.5f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_pokeLabel setFrame:CGRectOffset(_pokeLabel.frame, 0, -self.frame.size.height)];
                         [_userView setFrame:CGRectOffset(_userView.frame, 0, -self.frame.size.height)];
                         [_bottomView setFrame:CGRectOffset(_bottomView.frame, 0, self.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         
                         UILabel *youWinLabel = [[UILabel alloc] initWithFrame:CGRectMake(-self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
                         [youWinLabel setText:@"You Win!!!"];
                         [youWinLabel setTextColor:[UIColor simbiDarkGrayColor]];
                         [youWinLabel setFont:[UIFont simbiLightFontWithSize:32.f]];
                         [youWinLabel setTextAlignment:NSTextAlignmentCenter];
                         [self addSubview:youWinLabel];
                         
                         [UIView animateWithDuration:0.5f
                                               delay:0.f
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [youWinLabel setFrame:CGRectOffset(youWinLabel.frame, self.frame.size.width, 0)];
                                          }
                                          completion:nil];
                     }];
}


#pragma mark - User Actions

- (void)pokeAction:(UIButton *)button
{
    if (self.isPlayingAlone)
    {
        [MBProgressHUD showMessage:@"Poked!" parent:(UIViewController *)self.delegate];
        if (!self.challengeInfo[kInfoKey_PokeCount])
        {
            [self.challenge setChallengeInfo:[NSMutableDictionary new]];
            [self.challengeInfo setObject:@1 forKey:kInfoKey_PokeCount];
        }
        else
            self.challengeInfo[kInfoKey_PokeCount] = [NSNumber numberWithInteger:((NSNumber *)self.challengeInfo[kInfoKey_PokeCount]).integerValue+1];
        [_pokeLabel setText:[NSString stringWithFormat:@"Pokes: %ld", (long)self.numberOfPokes]];
    }
    else
    {
        MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Poking..." parent:(UIViewController *)self.delegate];
        
        [self executeChallengeAction:kActionType_Poke parameters:@{} withCallback:^(NSString *response, NSError *error) {
            
            if (response)
            {
                [hud dismissWithSuccess];
                [_pokeLabel setText:[NSString stringWithFormat:@"Pokes: %ld", (long)self.numberOfPokes]];
                [self.delegate gameViewShouldDismiss:self];
            }
            else
            {
                [hud dismissWithError];
            }
        }];
    }
}


- (void)surrenderAction:(UIButton *)button
{
    if (self.isPlayingAlone)
    {
        [self.delegate gameViewShouldDismiss:self];
    }
    else
    {
        MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Surrendering..." parent:(UIViewController *)self.delegate];
        
        [self.challenge setWinner:self.otherUser];
        
        [self executeChallengeAction:kActionType_Surrender parameters:@{} withCallback:^(NSString *response, NSError *error) {
            
            if (response)
            {
                [hud dismissWithMessage:@"Surrendered!"];
                [self.delegate gameView:self gameDidFinishWithVictory:NO];
            }
            else
            {
                [hud dismissWithError];
            }
        }];
    }
}


@end
