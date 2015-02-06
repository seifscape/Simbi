//
//  Constants.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#ifndef Simbi_Constants_h
#define Simbi_Constants_h


// API keys

#define kParseAppId @"mwpk2PsstIHMd7JG6mW3rGi8jIGJ0BI8X92C6up0"
#define kParseClientKey @"BagK2iG0scmSCQGvECLhf7n1K8oPbxqUOs4rmqZH"

#define kFacebookId @"1378602369095327"
#define kFacebookSecret @"f3b026a008f493bd1403a79a0d37d4a3"


// Notification names

// Push notifications
#define kSMBNotificationMessageReceived             @"MessageReceived"
#define kSMBNotificationQuestionReceived            @"QuestionReceived"
#define kSMBNotificationChallengeReceived           @"ChallengeReceived"
#define kSMBNotificationChallengeAction             @"ChallengeAction"
#define kSMBNotificationWillEnterForeground         @"WillEnterForeground"
#define kSMBNotificationShowChatIcon                @"ShowChatIcon"
#define kSMBNotificationHideChatIcon                @"HideChatIcon"
#define kSMBNotificationChatRevealed                @"ChatRevealed"
#define kSMBNotificationChatRemoved                 @"ChatRemoved"
#define kSMBNotificationChallengeAccepted           @"ChallengeAccepted"
#define kSMBNotificationQuestionAccepted            @"QuestionAccepted"
#define kSMBNotificationUserStartedTyping           @"UserStartedTyping"
#define kSMBNotificationUserStoppedTyping           @"UserStoppedTyping"
#define kSMBNotificationFriendRequestReceived       @"FriendRequestReceived"
#define kSMBNotificationFriendRequestAccepted       @"FriendRequestAccepted"
#define kSMBNotificationChatDeclined                @"ChatDeclined" // Silent
#define kSMBNotificationCheckInActivity             @"CheckInActivity"

// Chats
#define kSMBNotificationChatForceRevealed           @"ChatForceRevealed"

// Challenges
#define kSMBNotificationChallengeActionExecuted     @"ChallengeActionExecuted"

// Timer
#define kSMBNotificationTimerUpdate                 @"TimerUpdate"
#define kSMBNotificationTimerExpired                @"TimerExpired"

// Chat bubble cell
#define kSMBNotificationMessageFailed               @"MessageFailed"
#define kSMBNotificationMessageSent                 @"MessageSent"

#endif
