//
//  SMBChatManager.m
//  Simbi
//
//  Created by flynn on 6/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChatManager.h"

#import "SMBChatCollection.h"


@interface SMBChatManager ()

@property (nonatomic, strong) NSArray *chatCollections;

@end


@implementation SMBChatManager

+ (instancetype)sharedManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
       
        
        NSArray *includes = @[@"userOne",
                              @"userOne.profilePicture",
                              @"userOne.hairColor",
                              @"userTwo",
                              @"userTwo.profilePicture",
                              @"userTwo.hairColor",
                              @"currentChallenge",
                              @"currentChallenge.chat",
                              @"currentQuestion",
                              @"currentQuestion.chat"];
        
        [self registerClassName:@"Chat" includes:includes orderKey:@"createdAt"];
        [self setOrder:NSOrderedDescending];
        
        // Receiving chats
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatReceivedNotification:) name:kSMBNotificationChallengeReceived object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatReceivedNotification:) name:kSMBNotificationQuestionReceived object:nil];
        
        // Chat accepted, declined
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChallengeAcceptedNotification:) name:kSMBNotificationChallengeAccepted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuestionAcceptedNotification:) name:kSMBNotificationQuestionAccepted object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatDeclinedNotification:) name:kSMBNotificationChatDeclined object:nil];
        
        // Chat actions
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageReceivedNotification:) name:kSMBNotificationMessageReceived object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChallengeActionNotification:) name:kSMBNotificationChallengeAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatRevealedNotification:) name:kSMBNotificationChatRevealed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChatRemovedNotification:) name:kSMBNotificationChatRemoved object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTimerExpiredNotification:) name:kSMBNotificationTimerExpired object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActionExecutedNotification:) name:kSMBNotificationChallengeActionExecuted object:nil];
        
        // Typing
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartedTypingNotification:) name:kSMBNotificationUserStartedTyping object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStoppedTypingNotification:) name:kSMBNotificationUserStoppedTyping object:nil];
    }
    
    return self;
}


#pragma mark - Notification Handling:
#pragma mark

#pragma mark Chat Received

- (void)handleChatReceivedNotification:(NSNotification *)notification
{
    NSString *chatId = notification.userInfo[@"chatId"];
    
    if (!chatId || chatId.length == 0)
    {
        NSLog(@"%s - WARNING: Received a notification without a chatId!", __PRETTY_FUNCTION__);
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    
    for (NSString *include in self.includes)
        [query includeKey:include];
    
    [query getObjectInBackgroundWithId:chatId block:^(PFObject *object, NSError *error) {
        
        if (object)
        {
            SMBChat *chat = (SMBChat *)object;
            [self addChat:chat];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
        }
    }];
}


#pragma mark Chat Accepted

- (void)handleChallengeAcceptedNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        [chatCollection updateDateStarted];
        
        [chatCollection.chat.currentChallenge setAccepted:YES];
        
        NSString *messageText = notification.userInfo[@"chatMessage"];
        
        if (!messageText || messageText.length == 0)
        {
            NSLog(@"%s - WARNING: Received a message with no text!", __PRETTY_FUNCTION__);
            return;
        }
        
        // Make a 'dummy' smbMessage that won't get saved
        SMBMessage *message = [[SMBMessage alloc] init];
        [message setFromUser:[chatCollection.chat otherUser]];
        [message setToUser:[SMBUser currentUser]];
        [message setMessageText:messageText];
        [message setIsAction:YES];
        [message setIsAccept:YES];
        [chatCollection.messages addObject:message];
        [chatCollection.gameMessages addObject:message];
        
        [self checkForForcedReveal:chatCollection];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didReceiveMessage:message forChat:chatCollection.chat];
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didReceiveGameMessage:message forChat:chatCollection.chat];
        
        [self updateDelegates];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)handleQuestionAcceptedNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        [chatCollection updateDateStarted];
        
        [chatCollection.chat.currentQuestion setAccepted:YES];
        
        NSString *messageText = notification.userInfo[@"chatMessage"];
        
        if (!messageText || messageText.length == 0)
        {
            NSLog(@"%s - WARNING: Received a message with no text!", __PRETTY_FUNCTION__);
            return;
        }
        
        // Make a 'dummy' smbMessage that won't get saved
        SMBMessage *message = [[SMBMessage alloc] init];
        [message setFromUser:[chatCollection.chat otherUser]];
        [message setToUser:[SMBUser currentUser]];
        [message setMessageText:messageText];
        [message setIsAction:YES];
        [message setIsAccept:YES];
        [chatCollection.messages addObject:message];
        
        [self checkForForcedReveal:chatCollection];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didReceiveMessage:message forChat:chatCollection.chat];
        
        [self updateDelegates];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)handleChatDeclinedNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didDeclineChat:chatCollection.chat];
        
        [self removeChat:chatCollection.chat];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


#pragma mark Chat Actions

- (void)handleMessageReceivedNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        NSString *messageId = notification.userInfo[@"messageId"];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        
        [query getObjectInBackgroundWithId:messageId block:^(PFObject *object, NSError *error) {
            
            if (object)
            {
                SMBMessage *message = (SMBMessage *)object;
                [chatCollection.messages addObject:message];
                [self checkForForcedReveal:chatCollection];
                
                for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
                    [delegate chatManager:self didReceiveMessage:message forChat:chatCollection.chat];
            }
            else
            {
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            }
        }];
        
        [self updateDelegates];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)handleChallengeActionNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        NSString *messageText = notification.userInfo[@"chatMessage"];
        
        if (!messageText || messageText.length == 0)
        {
            NSLog(@"%s - WARNING: Received a message with no text!", __PRETTY_FUNCTION__);
            return;
        }
        
        // Make a 'dummy' smbMessage that won't get saved
        SMBMessage *message = [[SMBMessage alloc] init];
        [message setFromUser:[chatCollection.chat otherUser]];
        [message setToUser:[SMBUser currentUser]];
        [message setMessageText:messageText];
        [message setIsAction:YES];
        [message setChallengeId:notification.userInfo[@"challengeId"]];
        [chatCollection.gameMessages addObject:message];
        
        [self checkForForcedReveal:chatCollection];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didReceiveGameMessage:message forChat:chatCollection.chat];
        
        [self updateDelegates];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)handleChatRevealedNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        NSString *messageText = notification.userInfo[@"chatMessage"];
        
        if (!messageText || messageText.length == 0)
        {
            NSLog(@"%s - WARNING: Received a message with no text!", __PRETTY_FUNCTION__);
            return;
        }
        
        [chatCollection refreshProfilePicture:^(BOOL succeeded) {
            
            if (succeeded)
            {
                [chatCollection.chat setOtherUsersHasRevealed:YES];
                
                // Make a 'dummy' smbMessage that won't get saved
                SMBMessage *message = [[SMBMessage alloc] init];
                [message setFromUser:[chatCollection.chat otherUser]];
                [message setToUser:[SMBUser currentUser]];
                [message setMessageText:messageText];
                [message setIsAction:YES];
                [chatCollection.messages addObject:message];
                
                [self checkForForcedReveal:chatCollection];
                
                for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
                    [delegate chatManager:self didReceiveMessage:message forChat:chatCollection.chat];
                for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
                    [delegate chatManager:self otherUserDidRevealWithImage:chatCollection.otherUserProfilePicture inChat:chatCollection.chat];
                
                [self updateDelegates];
            }
        }];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)handleChatRemovedNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        NSString *messageText = notification.userInfo[@"chatMessage"];
        
        if (!messageText || messageText.length == 0)
        {
            NSLog(@"%s - WARNING: Received a message with no text!", __PRETTY_FUNCTION__);
            return;
        }
        
        // Make a 'dummy' smbMessage that won't get saved
        SMBMessage *message = [[SMBMessage alloc] init];
        [message setFromUser:[chatCollection.chat otherUser]];
        [message setToUser:[SMBUser currentUser]];
        [message setMessageText:messageText];
        [message setIsAction:YES];
        [chatCollection.messages addObject:message];
        
        [self checkForForcedReveal:chatCollection];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didReceiveMessage:message forChat:chatCollection.chat];
        
        [self updateDelegates];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)handleTimerExpiredNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        [chatCollection.chat setIsActive:NO];
        [chatCollection.chat saveInBackground];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self chatDidExpire:chatCollection.chat];
        
        [self removeChat:chatCollection.chat];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)handleActionExecutedNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        NSString *messageText = notification.userInfo[@"chatMessage"];
        
        if (!messageText || messageText.length == 0)
        {
            NSLog(@"%s - WARNING: Received a message with no text!", __PRETTY_FUNCTION__);
            return;
        }
        
        // Make a 'dummy' smbMessage that won't get saved
        SMBMessage *message = [[SMBMessage alloc] init];
        [message setFromUser:[SMBUser currentUser]];
        [message setToUser:[chatCollection.chat otherUser]];
        [message setMessageText:messageText];
        [message setIsAction:YES];
        [message setChallengeId:notification.userInfo[@"challengeId"]];
        [chatCollection.gameMessages addObject:message];
        
        [self checkForForcedReveal:chatCollection];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didReceiveGameMessage:message forChat:chatCollection.chat];
        
        [self updateDelegates];
    }
}


#pragma mark Typing Notifications

- (void)handleStartedTypingNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self otherUserIsTyping:YES forChat:chatCollection.chat];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)handleStoppedTypingNotification:(NSNotification *)notification
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:notification.userInfo[@"chatId"]];
    
    if (chatCollection)
    {
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self otherUserIsTyping:NO forChat:chatCollection.chat];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


#pragma mark - SMBManager Methods

- (PFQuery *)query
{
    PFQuery *queryOne = [PFQuery queryWithClassName:@"Chat"];
    [queryOne whereKey:@"userOne" equalTo:[SMBUser currentUser]];
    [queryOne whereKey:@"userOneRemoved" notEqualTo:@YES];
    
    PFQuery *queryTwo = [PFQuery queryWithClassName:@"Chat"];
    [queryTwo whereKey:@"userTwo" equalTo:[SMBUser currentUser]];
    [queryTwo whereKey:@"userTwoRemoved" notEqualTo:@YES];
    
    PFQuery *queryWithDate = [PFQuery orQueryWithSubqueries:@[queryOne, queryTwo]];
    [queryWithDate whereKey:@"dateStarted" greaterThanOrEqualTo:[[NSDate date] dateByAddingTimeInterval:-60*20]];
    
    PFQuery *queryWithoutDate = [PFQuery orQueryWithSubqueries:@[queryOne, queryTwo]];
    [queryWithoutDate whereKeyDoesNotExist:@"dateStarted"];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryWithDate, queryWithoutDate]];
    [query whereKey:@"isActive" equalTo:@YES];
    
    for (NSString *include in self.includes)
        [query includeKey:include];

    [query orderByDescending:@"createdAt"];
    
    return query;
}


- (void)objectsDidLoad
{
    NSLog(@"%@: loaded %ld chats", [self class], (long)self.objects.count);
    
    NSMutableArray *chatCollections = [NSMutableArray new];
    
    for (SMBChat *chat in self.objects)
    {
        SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
        
        if (!chatCollection)
            chatCollection = [[SMBChatCollection alloc] init];
        
        [chatCollection setChat:chat];
        [chatCollections addObject:chatCollection];
    }
    
    _chatCollections = [NSArray arrayWithArray:chatCollections];
    
    NSLog(@"%@: Loading messages...", [self class]);
    
    [self loadMessagesForChatCollectionAtIndex:0];
}


#pragma mark - Public Methods

- (void)addChatDelegate:(id<SMBChatManagerDelegate>)delegate forChat:(SMBChat *)chat
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
    
    if (chatCollection)
        [chatCollection.delegates addPointer:(__bridge void *)delegate];
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)cleanDelegatesForChat:(SMBChat *)chat
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
    
    if (chatCollection)
    {
        NSMutableArray *indicies = [NSMutableArray new];
        
        for (int i = 0; i < chatCollection.delegates.count; i++)
            if ([chatCollection.delegates pointerAtIndex:i] == nil)
                [indicies addObject:[NSNumber numberWithInt:i]];
                
        for (int i = (int)indicies.count-1; i >= 0; i--)
            [chatCollection.delegates removePointerAtIndex:((NSNumber *)[indicies objectAtIndex:i]).intValue];
    }
    // No warning if there's no chatCollection
}


- (void)reloadMessagesForChat:(SMBChat *)chat
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
    
    if (chatCollection)
    {
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self willLoadMessagesForChat:chatCollection.chat];
        
        [chatCollection loadDataForChat:^(BOOL succeeded) {
            
            if (succeeded)
            {
                for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
                    [delegate chatManager:self didLoadMessages:chatCollection.messages gameMessages:chatCollection.gameMessages forChat:chatCollection.chat];
            }
            else
            {
                for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
                    [delegate chatManager:self failedToLoadMessagesForChat:chatCollection.chat error:nil];
            }
        }];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (NSMutableArray *)messagesForChat:(SMBChat *)chat
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
    
    if (chatCollection)
        return chatCollection.messages;
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
    return nil;
}


- (NSMutableArray *)gameMessagesForChat:(SMBChat *)chat
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
    
    if (chatCollection)
        return chatCollection.gameMessages;
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
    return nil;
}


- (void)sendMessageForChat:(SMBChat *)chat withText:(NSString *)text dummyMessage:(SMBMessage *)message callback:(void(^)(BOOL succeeded))callback
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
    
    if (!chatCollection)
    {
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
        if (callback)
            callback(NO);
        return;
    }
    
    [message setMessageText:text];
    [message setFromUser:[SMBUser currentUser]];
    [message setToUser:[chatCollection.chat otherUser]];
    [message setChat:chatCollection.chat];
    
    if (![chatCollection.messages containsObject:message])
        [chatCollection.messages addObject:message];
    
    NSDictionary *params = @{ @"chatId" : chatCollection.chat.objectId,
                              @"messageText" : text };
    
    [PFCloud callFunctionInBackground:@"sendMessage" withParameters:params block:^(NSString *response, NSError *error) {
        
        if (response)
        {
            [chatCollection.chat setLastMessage:text];
            [message setObjectId:response];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationMessageSent object:nil userInfo:@{ @"message": message }];
            if (callback)
                callback(YES);
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationMessageFailed object:nil userInfo:@{ @"message": message }];
            if (callback)
                callback(NO);
        }
    }];
}


- (void)currentUserDidTypeForChat:(SMBChat *)chat
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
    
    if (chatCollection)
        [chatCollection currentUserDidType];
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)addChat:(SMBChat *)chat
{
    SMBChat *chatToRemove;
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
    
    if (!chatCollection)
        chatCollection = [[SMBChatCollection alloc] init];
    else
        chatToRemove = chatCollection.chat;
    
    [chatCollection setChat:chat];
    
    [chatCollection loadDataForChat:^(BOOL succeeded) {
        
        if (succeeded)
        {
            NSMutableArray *chatCollections = [NSMutableArray arrayWithArray:_chatCollections];
            [chatCollections addObject:chatCollection];
            _chatCollections = [NSArray arrayWithArray:chatCollections];
            
            if (chatToRemove)
                [self removeObject:chatToRemove];
            
            [self addObject:chat];
        }
        else
            NSLog(@"%s - WARNING: Could not load data for chat collection!", __PRETTY_FUNCTION__);
    }];
}


- (void)addChatWithId:(NSString *)chatId callback:(void(^)(BOOL succeeded))callback
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    
    for (NSString *include in self.includes)
        [query includeKey:include];
    
    [query getObjectInBackgroundWithId:chatId block:^(PFObject *object, NSError *error) {
        
        if (object)
        {
            [self addChat:(SMBChat *)object];
            
            if (callback)
                callback(YES);
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            if(callback)
                callback(NO);
        }
    }];
}


- (void)removeChat:(SMBChat *)chat
{
    [self removeObject:chat];
    
    NSMutableArray *chatCollections = [NSMutableArray arrayWithArray:_chatCollections];
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:chat.objectId];
    [chatCollections removeObject:chatCollection];
    _chatCollections = [NSArray arrayWithArray:chatCollections];
}


#pragma mark - Private Methods

- (SMBChatCollection *)chatCollectionForChatId:(NSString *)chatId
{
    if (chatId && chatId.length > 0)
    {
        for (SMBChatCollection *chatCollection in _chatCollections)
            if ([chatCollection.chat.objectId isEqualToString:chatId])
                return chatCollection;
    }
    else
        NSLog(@"%s - WARNING: No chatId provided!", __PRETTY_FUNCTION__);
    
    return nil;
}


- (void)loadMessagesForChatCollectionAtIndex:(NSUInteger)index
{
    if (index >= _chatCollections.count)
    {
        return;
    }
    else
    {
        SMBChatCollection *chatCollection = [_chatCollections objectAtIndex:index];
        SMBChat *chat = chatCollection.chat;
        
        NSLog(@"%@: Loading messages for chat #%@ with %@", [self class], chat.objectId, [chat otherUser].name);
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self willLoadMessagesForChat:chatCollection.chat];
        
        [chatCollection loadDataForChat:^(BOOL succeeded) {
            
            if (succeeded)
            {
                for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
                    [delegate chatManager:self didLoadMessages:chatCollection.messages gameMessages:chatCollection.gameMessages forChat:chatCollection.chat];
            }
            if (!succeeded)
            {
                NSLog(@"%@: WARNING - Failed to load messages for chat #%@ with %@", [self class], chat.objectId, [chat otherUser].name);
                for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
                    [delegate chatManager:self failedToLoadMessagesForChat:chatCollection.chat error:nil];
            }
            
            [self loadMessagesForChatCollectionAtIndex:index+1];
        }];
    }
}


- (void)checkForForcedReveal:(SMBChatCollection *)chatCollection
{
    [chatCollection checkForForcedReveal:^(BOOL shouldReveal, NSInteger index) {
        if (shouldReveal)
        {
            for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
                [delegate chatManager:self forcedRevealAtIndex:index forChat:chatCollection.chat];
            for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
                [delegate chatManager:self otherUserDidRevealWithImage:chatCollection.otherUserProfilePicture inChat:chatCollection.chat];
        }
    }];
}


- (void)noChatCollectionWarning:(const char *)prettyFunction
{
    NSLog(@"%@: WARNING: Tried to run function %s for a chat that isn't being managed!", [self class], prettyFunction);
}


#pragma mark - SMBChallengeViewControllerDelegate

- (void)challengeViewController:(SMBChallengeViewController *)viewController didAcceptWithChatMessage:(NSString *)chatMessage
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:viewController.challenge.chat.objectId];
    
    if (chatCollection)
    {
        [chatCollection.chat setIsAccepted:YES];
        [chatCollection.chat setStartedWithChallenge:NO];
        
        NSDictionary *userInfo = @{ @"chatId": chatCollection.chat.objectId, @"date": [NSDate date] };
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationTimerUpdate object:nil userInfo:userInfo];
        
        [chatCollection updateDateStarted];
        
        SMBMessage *message = [[SMBMessage alloc] init];
        [message setFromUser:[SMBUser currentUser]];
        [message setToUser:[chatCollection.chat otherUser]];
        [message setChat:chatCollection.chat];
        [message setMessageText:chatMessage];
        [message setIsAction:YES];
        [message setChallengeId:viewController.challenge.objectId];
        [message setIsAccept:YES];
        [chatCollection.messages addObject:message];
        [chatCollection.gameMessages addObject:message];
        
        [self checkForForcedReveal:chatCollection];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didReceiveMessage:message forChat:chatCollection.chat];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)challengeViewControllerDidDecline:(SMBChallengeViewController *)viewController
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:viewController.challenge.chat.objectId];
    
    if (chatCollection)
    {
        [chatCollection.chat setIsAccepted:NO];
        [chatCollection.chat setIsDeclined:YES];
        [chatCollection.chat setIsActive:NO];
        [chatCollection.chat setThisUserRemoved:YES];
        
        [chatCollection.chat saveInBackground];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didDeclineChat:chatCollection.chat];
        
        [chatCollection declineChat];
        
        [self removeChat:chatCollection.chat];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


#pragma mark - SMBQuestionViewControllerDelegate

- (void)questionViewController:(SMBQuestionViewController *)viewController didAcceptWithChatMessage:(NSString *)chatMessage
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:viewController.question.chat.objectId];
    
    if (chatCollection)
    {
        [chatCollection.chat setIsActive:YES];
        [chatCollection.chat setStartedWithQuestion:NO];
        
        NSDictionary *userInfo = @{ @"chatId": chatCollection.chat.objectId, @"date": [NSDate date] };
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationTimerUpdate object:nil userInfo:userInfo];
        
        [chatCollection updateDateStarted];
        
        SMBMessage *message = [[SMBMessage alloc] init];
        [message setFromUser:[SMBUser currentUser]];
        [message setToUser:[chatCollection.chat otherUser]];
        [message setChat:chatCollection.chat];
        [message setMessageText:chatMessage];
        [message setIsAction:YES];
        [message setIsAccept:YES];
        [chatCollection.messages addObject:message];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didReceiveMessage:message forChat:chatCollection.chat];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


- (void)questionViewControllerDidDecline:(SMBQuestionViewController *)viewController
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:viewController.question.chat.objectId];
    
    if (chatCollection)
    {
        [chatCollection.chat setIsAccepted:NO];
        [chatCollection.chat setIsDeclined:YES];
        [chatCollection.chat setIsActive:NO];
        
        [chatCollection.chat saveInBackground];
        
        for (id<SMBChatManagerDelegate> delegate in chatCollection.delegates)
            [delegate chatManager:self didDeclineChat:chatCollection.chat];
        
        [chatCollection declineChat];
        
        [self removeChat:chatCollection.chat];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


#pragma mark - SMBChatStatusViewDelegate

- (void)chatStatusView:(SMBChatStatusView *)chatStatusView retrySaveForMessage:(SMBMessage *)message callback:(void (^)(BOOL))callback
{
    SMBChatCollection *chatCollection = [self chatCollectionForChatId:message.chat.objectId];
    
    if (chatCollection)
    {
        [self sendMessageForChat:chatCollection.chat withText:message.messageText dummyMessage:message callback:^(BOOL succeeded) {
            if (callback)
                callback(succeeded);
        }];
    }
    else
        [self noChatCollectionWarning:__PRETTY_FUNCTION__];
}


@end
