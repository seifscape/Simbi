//
//  SMBChatCollection.m
//  Simbi
//
//  Created by flynn on 6/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChatCollection.h"


@implementation SMBChatCollection

static const NSInteger kRepliesUntilRevealed = 12;

#pragma mark - Public Methods

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _messages = [NSMutableArray arrayWithObject:[NSNull null]];
        _gameMessages = [NSMutableArray arrayWithObject:[NSNull null]];
        _delegates = [NSPointerArray weakObjectsPointerArray];
    }
    
    return self;
}


- (void)loadDataForChat:(void(^)(BOOL succeeded))callback
{
    // Function to load the messages and the profile picture for a chat after the chat has been set
    
    _isLoading = YES;
    _messagesLoaded = NO;
    _failedToLoad = NO;
    
    if (!_chat)
    {
        NSLog(@"%s - WARNING: No chat set!", __PRETTY_FUNCTION__);
        _isLoading = NO;
        _failedToLoad = YES;
        if (callback)
            callback(NO);
        return;
    }
    
    // Load messages
    
    PFQuery *query = _chat.messages.query;
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (objects)
        {
            _messages = [NSMutableArray arrayWithObject:[NSNull null]];
            [_messages addObjectsFromArray:objects];
            
            // Load game messages
            
            PFQuery *query = _chat.gameMessages.query;
            [query orderByAscending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (objects)
                {
                    _gameMessages = [NSMutableArray arrayWithObject:[NSNull null]];
                    [_gameMessages addObjectsFromArray:objects];
                    
                    // Load the other user's profile picture
                    
                    [[_chat otherUser].profilePicture fetchIfNeeded];
                    
                    [[_chat otherUser].profilePicture.thumbnailImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        
                        _isLoading = NO;
                        
                        if (data)
                        {
                            _otherUserProfilePicture = [UIImage imageWithData:data];
                            _messagesLoaded = YES;
                            if (callback)
                                callback(YES);
                        }
                        else
                        {
                            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                            _messages = nil;
                            _failedToLoad = YES;
                            if (callback)
                                callback(NO);
                        }
                    }];
                }
                else
                {
                    NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                    _isLoading = NO;
                    _failedToLoad = YES;
                    if (callback)
                        callback(NO);
                }
            }];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            _isLoading = NO;
            _failedToLoad = YES;
            if (callback)
                callback(NO);
        }
    }];
}


- (void)refreshProfilePicture:(void(^)(BOOL succeeded))callback
{
    if (_otherUserProfilePicture)
    {
        if (callback)
            callback(YES);
    }
    else
    {
        [[_chat otherUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (object)
            {
                [[_chat otherUser].profilePicture fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    if (object)
                    {
                        [[_chat otherUser].profilePicture.thumbnailImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            
                            if (data)
                            {
                                _otherUserProfilePicture = [UIImage imageWithData:data];
                                if (callback)
                                    callback(YES);
                            }
                            else
                            {
                                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                                if (callback)
                                    callback(NO);
                            }
                        }];
                    }
                    else
                    {
                        NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                        if (callback)
                            callback(NO);
                    }
                }];
            }
            else
            {
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                if (callback)
                    callback(NO);
            }
        }];
    }
}


- (void)checkForForcedReveal:(void(^)(BOOL shouldReveal, NSInteger index))callback
{
    if (!_chat.forceRevealed)
    {
        SMBUser *user;
        NSInteger replyCount = 0;
        NSInteger index = 0;
        
        for (id item in _messages)
        {
            if ([item isKindOfClass:[SMBMessage class]])
            {
                SMBMessage *message = (SMBMessage *)item;
                
                if (user && ![user.objectId isEqualToString:message.fromUser.objectId])
                    replyCount++;
                
                user = message.fromUser;
            }
            
            if (replyCount >= kRepliesUntilRevealed)
                break;
            
            index++;
        }
        
        if (index > 0 && replyCount >= kRepliesUntilRevealed)
        {
            if (!_chat.forceRevealed)
                [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationChatForceRevealed
                                                                    object:nil
                                                                  userInfo:@{@"chatId": _chat.objectId}];
            
            [_chat setForceRevealed:YES];
            [_chat saveInBackground];
            
            [self refreshProfilePicture:^(BOOL succeeded) {
                if (callback)
                    callback(YES, index);
            }];
        }
        else
        {
            if (callback)
                callback(NO, 0);
        }
    }
    else
    {
        if (callback)
            callback(NO, 0);
    }
}


- (void)updateDateStarted
{
    [_chat fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object)
        {
            if (_chat.dateStarted)
            {
                NSDictionary *userInfo = @{ @"chatId": _chat.objectId, @"date": _chat.dateStarted };
                [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationTimerUpdate object:nil userInfo:userInfo];
            }
            else
                NSLog(@"%s - WARNING: chat has no dateStarted when it should!", __PRETTY_FUNCTION__);
        }
        else
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
    }];
}


- (void)currentUserDidType
{
    if (_typingTimer)
    {
        [_typingTimer invalidate];
        _typingTimer = nil;
    }
    else
    {
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"user" equalTo:[_chat otherUser]];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:query];
        [push setData:@{@"content-available": @1, @"sound": @"", @"pushType": @"UserStartedTyping", @"chatId": _chat.objectId}];
        [push sendPushInBackground];
    }
    
    _typingTimer = [NSTimer scheduledTimerWithTimeInterval:4.f target:self selector:@selector(typingTimerExpired:) userInfo:nil repeats:NO];
}


- (void)declineChat
{
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:[_chat otherUser]];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setData:@{@"content-available": @1, @"sound": @"", @"pushType": @"ChatDeclined", @"chatId": _chat.objectId}];
    [push sendPushInBackground];
}


#pragma mark - Private Methods

- (void)typingTimerExpired:(NSTimer *)timer
{
    _typingTimer = nil;
    
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:[_chat otherUser]];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setData:@{@"content-available": @1, @"sound": @"", @"pushType": @"UserStoppedTyping", @"chatId": _chat.objectId}];
    [push sendPushInBackground];
}


@end
