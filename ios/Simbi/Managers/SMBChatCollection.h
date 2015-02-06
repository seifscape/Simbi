//
//  SMBChatCollection.h
//  Simbi
//
//  Created by flynn on 6/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChallengeViewController.h"
#import "SMBChatStatusView.h"
#import "SMBQuestionViewController.h"


@protocol SMBChatManagerDelegate;

@interface SMBChatCollection : NSObject

- (void)loadDataForChat:(void(^)(BOOL succeeded))callback;
- (void)refreshProfilePicture:(void(^)(BOOL succeeded))callback;
- (void)checkForForcedReveal:(void(^)(BOOL shouldReveal, NSInteger index))callback;
- (void)updateDateStarted;
- (void)currentUserDidType;
- (void)declineChat;

@property (nonatomic, strong) SMBChat *chat;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *gameMessages;
@property (nonatomic, strong) UIImage *otherUserProfilePicture;
@property (nonatomic, strong) NSPointerArray *delegates; // id<SMBChatManagerDelegate>
@property (nonatomic, strong) NSTimer *typingTimer;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL messagesLoaded;
@property (nonatomic) BOOL failedToLoad;

@end
