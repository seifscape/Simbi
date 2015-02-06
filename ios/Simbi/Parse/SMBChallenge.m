//
//  SMBChallenge.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChallenge.h"

#import "SMBGameView.h"
    #import "SMBPokeORamaGameView.h"
    #import "SMBDrinkRouletteGameView.h"


@implementation SMBChallenge

@dynamic challengeType;
@dynamic challengeName;
@dynamic toUser;
@dynamic fromUser;
@dynamic accepted;
@dynamic declined;
@dynamic winner;
@dynamic challengeInfo;
@dynamic chat;


static NSString *challengeType_PokeORama     = @"Poke-O-Rama";
static NSString *challengeType_DrinkRoulette = @"DrinkRoulette";


+ (NSString *)parseClassName
{
    return @"Challenge";
}


- (instancetype)init
{
    self = [super init];
    
    if (self)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAction:) name:kSMBNotificationChallengeAction object:nil];
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)updateAction:(NSNotification *)notification
{
    if ([notification.userInfo[@"challengeId"] isEqualToString:self.objectId])
        [self fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error)
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
        }];
}


- (SMBUser *)otherUser
{
    if ([[SMBUser currentUser].objectId isEqualToString:self.toUser.objectId])
        return self.fromUser;
    else if ([[SMBUser currentUser].objectId isEqualToString:self.fromUser.objectId])
        return self.toUser;
    else
        return nil;
}


#pragma mark - SMBChallengeType

+ (NSString *)stringForChallengeType:(SMBChallengeType)type
{
    switch (type)
    {
        case kSMBChallengeTypePokeORama:
            return challengeType_PokeORama;
            
        case kSMBChallengeTypeDrinkRoulette:
            return challengeType_DrinkRoulette;
            
        case kSMBChallengeTypeCount:
            return @"";
    }
}


+ (SMBChallengeType)challengeTypeForString:(NSString *)string
{
    if ([string isEqualToString:challengeType_PokeORama])
        return kSMBChallengeTypePokeORama;
    else if ([string isEqualToString:challengeType_DrinkRoulette])
        return kSMBChallengeTypeDrinkRoulette;
    else
        return kSMBChallengeTypeCount;
}


- (SMBChallengeType)challengeTypeEnum
{
    return [SMBChallenge challengeTypeForString:self.challengeType];
}


+ (NSString *)nameForChallengeType:(SMBChallengeType)type
{
    switch (type)
    {
        case kSMBChallengeTypePokeORama:
            return @"Poke-O-Rama";
            
        case kSMBChallengeTypeDrinkRoulette:
            return @"Drink Roulette";
            
        case kSMBChallengeTypeCount:
            return @"";
    }
}


- (UIView *)cardViewForFrame:(CGRect)frame
{
    switch ([self challengeTypeEnum])
    {
        case kSMBChallengeTypePokeORama:
            return [SMBPokeORamaGameView cardWithFrame:frame];
            break;
        case kSMBChallengeTypeDrinkRoulette:
            return [SMBDrinkRouletteGameView cardWithFrame:frame];
            break;
        default:
        {
            UIView *cardView = [[UIView alloc] initWithFrame:frame];
            [cardView setBackgroundColor:[UIColor simbiRedColor]];
            return cardView;
        }
    }
}


+ (UIView *)cardViewForIndex:(NSInteger)index frame:(CGRect)frame
{
    switch (index)
    {
        case kSMBChallengeTypePokeORama:
            return [SMBPokeORamaGameView cardWithFrame:frame];
            break;
        case kSMBChallengeTypeDrinkRoulette:
            return [SMBDrinkRouletteGameView cardWithFrame:frame];
            break;
        default:
        {
            UIView *cardView = [[UIView alloc] initWithFrame:frame];
            [cardView setBackgroundColor:[UIColor simbiRedColor]];
            return cardView;
        }
    }
}


@end
