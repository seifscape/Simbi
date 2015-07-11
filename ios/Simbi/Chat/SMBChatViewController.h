//
//  SMBChatViewController.h
//  Simbi
//
//  Created by flynn on 5/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "JSQMessages.h"

#import "SMBChatManager.h"
#import "SMBChatStatusView.h"
#import "SMBChallengeViewController.h"
#import "SMBQuestionViewController.h"


@class SMBChatViewController;

@protocol SMBChatViewControllerDelegate
- (void)chatViewController:(SMBChatViewController *)viewController didDeclineChat:(SMBChat *)chat;
- (void)chatViewController:(SMBChatViewController *)viewController didDeclineChallengeFromChat:(SMBChat *)chat;
@end


@interface SMBChatViewController : JSQMessagesViewController <UITextViewDelegate, UIAlertViewDelegate, SMBChatManagerDelegate>

+ (instancetype)messagesViewControllerWithChat:(SMBChat *)chat isViewingChat:(BOOL)isViewingChat;

@property (nonatomic, weak) id<SMBChatViewControllerDelegate> delegate;

@property (nonatomic, strong) SMBChat *chat;

/*added by zhy at 2015-07-11 for different topView*/
@property (nonatomic) BOOL isFriend;

@end
