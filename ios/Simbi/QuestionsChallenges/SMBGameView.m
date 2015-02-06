//
//  SMBGameView.m
//  Simbi
//
//  Created by flynn on 6/11/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBGameView.h"


@implementation SMBGameView

- (instancetype)initWithFrame:(CGRect)frame challenge:(SMBChallenge *)challenge
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _challenge = challenge;
        
        [self setUpGame];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChallengeActionNotification:) name:kSMBNotificationChallengeAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRevealNotification:) name:kSMBNotificationChatRevealed object:nil];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Getter Properties

- (NSMutableDictionary *)challengeInfo
{
    return _challenge.challengeInfo;
}


- (SMBUser *)otherUser
{
    return [_challenge otherUser];
}


- (BOOL)otherUserRevealed
{
    return [_challenge.chat otherUserHasRevealed];
}


- (BOOL)isPlayingAlone
{
    if (!_challenge.toUser.objectId)
        return YES;
    else
        return NO;
}


#pragma mark - Notification Handling

- (void)handleChallengeActionNotification:(NSNotification *)notification
{
    if ([_challenge.objectId isEqualToString:notification.userInfo[@"challengeId"]])
    {
        [self.challenge fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (object)
                [self challengeActionReceived:notification.userInfo[@"actionType"]];
            else
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
        }];
    }
}


- (void)handleRevealNotification:(NSNotification *)notification
{
    if ([_challenge.chat.objectId isEqualToString:notification.userInfo[@"chatId"]])
    {
        [self otherUserDidReveal];
    }
}


#pragma mark - Action Execution

- (void)executeChallengeAction:(NSString *)challengeAction parameters:(NSDictionary *)params withCallback:(void(^)(NSString *response, NSError *error))callback
{
    if (!self.challenge.chat.isAccepted)
    {
        [self.challenge.chat setIsAccepted:YES];
        [self.challenge.chat setIsDeclined:NO];
        [self.challenge.chat saveInBackground];
    }
    
    [self.challenge saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            
            NSMutableDictionary *actionParams = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                        @"challengeId": self.challenge.objectId,
                                                        @"otherUserId": [self.challenge otherUser].objectId,
                                                        @"action":      challengeAction}];
            
            [actionParams addEntriesFromDictionary:params];
            
            [PFCloud callFunctionInBackground:@"challengeAction" withParameters:actionParams block:^(NSString *response, NSError *error) {
                
                if (response)
                {
                    [self.challenge fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        
                        if (object)
                        {
                            callback(response, nil);
                            
                            // Send a notification so any open chat views receive the message
                            [self postChatNotificationWithMessage:response];
                        }
                        else
                        {
                            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                            callback(nil, error);
                        }
                    }];
                }
                else
                {
                    NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                    callback(nil, error);
                }
            }];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            callback(nil, error);
        }
    }];
}


- (void)postChatNotificationWithMessage:(NSString *)chatMessage
{
    NSDictionary *userInfo = @{ @"chatMessage": chatMessage,
                                @"chatId"     : self.challenge.chat.objectId,
                                @"challengeId": self.challenge.objectId };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationChallengeActionExecuted object:nil userInfo:userInfo];
}


#pragma mark - SMBGameView Methods

+ (UIView *)cardWithFrame:(CGRect)frame
{
    NSAssert(NO, @"%s - +[SMBGameView cardWithFrame:] must be overridden!", __PRETTY_FUNCTION__);
    return nil;
}


- (void)setUpGame
{
    NSAssert(NO, @"%s - -[SMBGameView setUpGame] must be overridden!", __PRETTY_FUNCTION__);
}


- (void)startGame
{
    NSAssert(NO, @"%s - -[SMBGameView startGame] must be overridden!", __PRETTY_FUNCTION__);
}


- (void)stopGame
{
    NSAssert(NO, @"%s - -[SMBGameView stopGame] must be overridden!", __PRETTY_FUNCTION__);
}


- (void)challengeActionReceived:(NSString *)actionType
{
    NSAssert(NO, @"%s - -[SMBGameView challengeActionReceived:] must be overridden!", __PRETTY_FUNCTION__);
}


- (void)otherUserDidReveal
{
    NSAssert(NO, @"%s - -[SMBGameView otherUserDidReveal] must be overridden!", __PRETTY_FUNCTION__);
}


@end
