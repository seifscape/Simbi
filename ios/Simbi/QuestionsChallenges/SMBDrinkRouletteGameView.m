//
//  SMBDrinkRouletteGameView.m
//  Simbi
//
//  Created by flynn on 6/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBDrinkRouletteGameView.h"


@interface SMBDrinkRouletteGameView ()

@property (nonatomic, strong) SMBDrinkWheelView *drinkWheelView;
@property (nonatomic, strong) UIImageView *pinView;

@property (nonatomic, strong) UIButton *spinButton;

@end


@implementation SMBDrinkRouletteGameView

#pragma mark - Definitions

static NSString *kActionType_Spin = @"spin";


#pragma mark - SMBGameView Methods

+ (UIView *)cardWithFrame:(CGRect)frame
{
    UIView *cardView = [[UIView alloc] initWithFrame:frame];
    [cardView setBackgroundColor:[UIColor simbiPinkColor]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wheel_temp"]];
    [imageView setFrame:CGRectMake((frame.size.width  - MIN(frame.size.width, frame.size.height)+40)/2.f,
                                   (frame.size.height - MIN(frame.size.width, frame.size.height))+20,
                                   MIN(frame.size.width, frame.size.height)-40,
                                   MIN(frame.size.width, frame.size.height)-40)];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView.layer setCornerRadius:imageView.frame.size.width/2.f];
    [imageView.layer setMasksToBounds:YES];
    [cardView addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 66)];
    [titleLabel setText:@"Drink Roulette"];
    [titleLabel setTextColor:[UIColor simbiDarkGrayColor]];
    [titleLabel setFont:[UIFont simbiBoldFontWithSize:24.f]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [cardView addSubview:titleLabel];
    
    return cardView;
}


- (void)setUpGame
{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    _drinkWheelView = [[SMBDrinkWheelView alloc] initWithFrame:CGRectMake(20, 44, self.frame.size.width-40, self.frame.size.width-40)];
    [_drinkWheelView setDelegate:self];
    [self addSubview:_drinkWheelView];
    [self bringSubviewToFront:_drinkWheelView];
    
    _spinButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, self.frame.size.height-88, self.frame.size.width-88, 44)];
    [_spinButton setTitle:@"Spin" forState:UIControlStateNormal];
    [_spinButton addTarget:self action:@selector(spinAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_spinButton];
}


- (void)startGame
{

}


- (void)stopGame
{

}


- (void)challengeActionReceived:(NSString *)actionType
{

}


- (void)otherUserDidReveal
{

}


#pragma mark - User Actions

- (void)spinAction:(UIButton *)button
{
    [button setEnabled:NO];
    [button setBackgroundColor:[UIColor simbiGrayColor]];
    
    [_drinkWheelView spin];
}


#pragma mark - SMBDrinkWheelDelegate

- (void)drinkWheelView:(SMBDrinkWheelView *)drinkWheelView didStopAtDrink:(NSString *)drink
{
    UILabel *drinkLabel = [[UILabel alloc] initWithFrame:CGRectMake(-self.frame.size.width, 88, self.frame.size.width, 88)];
    [drinkLabel setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.5f]];
    [drinkLabel setText:[NSString stringWithFormat:@"You got %@!", drink]];
    [drinkLabel setTextColor:[UIColor simbiDarkGrayColor]];
    [drinkLabel setFont:[UIFont simbiFontWithSize:18.f]];
    [drinkLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:drinkLabel];
    
    [UIView animateWithDuration:0.33f
                     animations:^{
                         [drinkLabel setFrame:CGRectOffset(drinkLabel.frame, self.frame.size.width, 0)];
                     }
                     completion:^(BOOL finished) {
                         
                         if (!self.isPlayingAlone)
                         {
                             MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Sending..." parent:(UIViewController *)self.delegate];
                             
                             [self executeChallengeAction:kActionType_Spin parameters:@{@"drink": drink} withCallback:^(NSString *response, NSError *error) {
                                 if (error)
                                     [hud dismissWithError];
                                 else
                                     [hud dismissQuickly];
                             }];
                         }
                         
                         [UIView animateWithDuration:0.33f
                                               delay:1.f
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              [drinkLabel setFrame:CGRectOffset(drinkLabel.frame, self.frame.size.width, 0)];
                                          }
                                          completion:^(BOOL finished) {
                                              [_spinButton setBackgroundColor:[UIColor simbiRedColor]];
                                              [_spinButton setEnabled:YES];
                                          }];
                     }];
}


@end
