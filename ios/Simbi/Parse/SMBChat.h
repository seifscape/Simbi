//
//  SMBChat.h
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>

#import "SMBChatCell.h"


@class SMBChallenge;
@class SMBQuestion;
@class SMBUser;


@interface SMBChat : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

+ (void)drawConnectionsForChatsInArray:(NSArray *)chats;

- (SMBUser *)otherUser;

- (BOOL)currentUserHasReadChat;

- (void)setThisUsersHasRead:(BOOL)hasRead;
- (void)setOtherUsersHasRead:(BOOL)hasRead;

- (BOOL)thisUserHasRevealed;
- (BOOL)otherUserHasRevealed;

- (void)setThisUsersHasRevealed:(BOOL)hasRevealed;
- (void)setOtherUsersHasRevealed:(BOOL)hasRevealed;

- (void)setThisUserRemoved:(BOOL)removed;
- (void)setOtherUserRemoved:(BOOL)removed;

- (BOOL)otherUserHasRemoved;

@property (retain) SMBUser *userOne;
@property (retain) SMBUser *userTwo;
@property BOOL userOneRead;
@property BOOL userTwoRead;
@property (retain, readonly) PFRelation *messages;
@property (retain, readonly) PFRelation *gameMessages;
@property (retain) NSString *lastMessage;
@property (retain) NSDate *dateLastMessageSent;

@property BOOL isAccepted;
@property BOOL isDeclined;
@property BOOL isActive;

@property BOOL userOneRevealed;
@property BOOL userTwoRevealed;
@property BOOL forceRevealed;

@property BOOL userOneRemoved;
@property BOOL userTwoRemoved;

@property (retain) NSDate *dateStarted;

@property (retain) SMBChallenge *currentChallenge;
@property (retain) SMBQuestion *currentQuestion;

@property BOOL startedWithQuestion;
@property BOOL startedWithChallenge;

@end
