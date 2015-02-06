//
//  SMBChatManager.h
//  Simbi
//
//  Created by flynn on 6/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBManager.h"

#import "SMBChallengeViewController.h"
#import "SMBChatStatusView.h"
#import "SMBQuestionViewController.h"


@class SMBChatManager;

@protocol SMBChatManagerDelegate

- (void)chatManager:(SMBChatManager *)chatManager willLoadMessagesForChat:(SMBChat *)chat;
- (void)chatManager:(SMBChatManager *)chatManager didLoadMessages:(NSMutableArray *)messages gameMessages:(NSMutableArray *)gameMessages forChat:(SMBChat *)chat;
- (void)chatManager:(SMBChatManager *)chatManager failedToLoadMessagesForChat:(SMBChat *)chat error:(NSError *)error;

- (void)chatManager:(SMBChatManager *)chatManager didReceiveMessage:(SMBMessage *)message forChat:(SMBChat *)chat;
- (void)chatManager:(SMBChatManager *)chatManager didReceiveGameMessage:(SMBMessage *)message forChat:(SMBChat *)chat;
- (void)chatManager:(SMBChatManager *)chatManager chatDidExpire:(SMBChat *)chat;
- (void)chatManager:(SMBChatManager *)chatManager otherUserDidRevealWithImage:(UIImage *)image inChat:(SMBChat *)chat;
- (void)chatManager:(SMBChatManager *)chatManager otherUserLeftChat:(SMBChat *)chat;
- (void)chatManager:(SMBChatManager *)chatManager didDeclineChat:(SMBChat *)chat;
- (void)chatManager:(SMBChatManager *)chatManager otherUserIsTyping:(BOOL)isTyping forChat:(SMBChat *)chat;
- (void)chatManager:(SMBChatManager *)chatManager forcedRevealAtIndex:(NSInteger)index forChat:(SMBChat *)chat;

@end


@interface SMBChatManager : SMBManager <SMBChallengeViewControllerDelegate, SMBQuestionViewControllerDelegate, SMBChatStatusViewDelegate>

- (void)addChatDelegate:(id<SMBChatManagerDelegate>)delegate forChat:(SMBChat *)chat;
- (void)cleanDelegatesForChat:(SMBChat *)chat; // Call this method in the delegate's dealloc to remove

- (NSMutableArray *)messagesForChat:(SMBChat *)chat;
- (NSMutableArray *)gameMessagesForChat:(SMBChat *)chat;
- (void)reloadMessagesForChat:(SMBChat *)chat;
- (void)sendMessageForChat:(SMBChat *)chat withText:(NSString *)text dummyMessage:(SMBMessage *)message callback:(void(^)(BOOL succeeded))callback;

- (void)currentUserDidTypeForChat:(SMBChat *)chat;

- (void)addChat:(SMBChat *)chat;
- (void)addChatWithId:(NSString *)chatId callback:(void(^)(BOOL succeeded))callback;

@end
