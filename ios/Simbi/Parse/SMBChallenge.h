//
//  SMBChallenge.h
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>


@class SMBChat;
@class SMBUser;


@interface SMBChallenge : PFObject <PFSubclassing>

typedef enum SMBChallengeType : NSInteger
{
    kSMBChallengeTypePokeORama,
    kSMBChallengeTypeDrinkRoulette,
    kSMBChallengeTypeCount
} SMBChallengeType;

+ (NSString *)parseClassName;

- (SMBUser *)otherUser;

+ (NSString *)stringForChallengeType:(SMBChallengeType)type;
+ (SMBChallengeType)challengeTypeForString:(NSString *)string;
- (SMBChallengeType)challengeTypeEnum;
+ (NSString *)nameForChallengeType:(SMBChallengeType)type;
- (UIView *)cardViewForFrame:(CGRect)frame;
+ (UIView *)cardViewForIndex:(NSInteger)index frame:(CGRect)frame;

@property (retain) NSString *challengeType;
@property (retain) NSString *challengeName;
@property (retain) SMBUser *toUser;
@property (retain) SMBUser *fromUser;
@property BOOL accepted;
@property BOOL declined;
@property (retain) SMBUser *winner;
@property (retain) NSMutableDictionary *challengeInfo;
@property (retain) SMBChat *chat;

@end
