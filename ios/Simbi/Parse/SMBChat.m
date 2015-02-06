//
//  SMBChat.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChat.h"

@implementation SMBChat

@dynamic userOne;
@dynamic userTwo;
@dynamic userOneRead;
@dynamic userTwoRead;
@dynamic messages;
@dynamic gameMessages;
@dynamic lastMessage;
@dynamic dateLastMessageSent;

@dynamic dateStarted;

@dynamic isActive;
@dynamic isAccepted;
@dynamic isDeclined;

@dynamic userOneRevealed;
@dynamic userTwoRevealed;
@dynamic forceRevealed;

@dynamic userOneRemoved;
@dynamic userTwoRemoved;

@dynamic currentChallenge;
@dynamic currentQuestion;

@dynamic startedWithChallenge;
@dynamic startedWithQuestion;

+ (NSString *)parseClassName
{
    return @"Chat";
}


+ (void)drawConnectionsForChatsInArray:(NSArray *)chats
{
    // Function that sets the user pointers on chats, challenges, and questions so that they all
    // reflect the same local object. (For example, both chats and challenges have from/toUser pointers.
    // when we query them, however, they will actually be different objects)
    
    // Assumes that userOne, userTwo, currentChallenge, and currentQuestion on the chat object are fetched.
    
    for (SMBChat *chat in chats)
    {
        // Replace whatever object is the current user with the actual current user object
        
        if ([chat.userOne.objectId isEqualToString:[SMBUser currentUser].objectId])
            [chat setUserOne:[SMBUser currentUser]];
        if ([chat.userTwo.objectId isEqualToString:[SMBUser currentUser].objectId])
            [chat setUserTwo:[SMBUser currentUser]];
        
        // Challenges
        
        if ([chat.currentChallenge.fromUser.objectId isEqualToString:chat.userOne.objectId])
            [chat.currentChallenge setFromUser:chat.userOne];
        if ([chat.currentChallenge.toUser.objectId isEqualToString:chat.userOne.objectId])
            [chat.currentChallenge setToUser:chat.userOne];
        
        if ([chat.currentChallenge.fromUser.objectId isEqualToString:chat.userTwo.objectId])
            [chat.currentChallenge setFromUser:chat.userTwo];
        if ([chat.currentChallenge.toUser.objectId isEqualToString:chat.userTwo.objectId])
            [chat.currentChallenge setToUser:chat.userTwo];
        
        // Questions
        
        if ([chat.currentQuestion.fromUser.objectId isEqualToString:chat.userOne.objectId])
            [chat.currentQuestion setFromUser:chat.userOne];
        if ([chat.currentQuestion.toUser.objectId isEqualToString:chat.userOne.objectId])
            [chat.currentQuestion setToUser:chat.userOne];
        
        if ([chat.currentQuestion.fromUser.objectId isEqualToString:chat.userTwo.objectId])
            [chat.currentQuestion setFromUser:chat.userTwo];
        if ([chat.currentQuestion.toUser.objectId isEqualToString:chat.userTwo.objectId])
            [chat.currentQuestion setToUser:chat.userTwo];
    }
}


- (SMBUser *)otherUser
{
    if ([[SMBUser currentUser].objectId isEqualToString:self.userOne.objectId])
        return self.userTwo;
    else if ([[SMBUser currentUser].objectId isEqualToString:self.userTwo.objectId])
        return self.userOne;
    else
        return nil;
}


- (BOOL)currentUserHasReadChat
{
    if ([[SMBUser currentUser].objectId isEqualToString:self.userOne.objectId])
        return self.userOneRead;
    else if ([[SMBUser currentUser].objectId isEqualToString:self.userTwo.objectId])
        return self.userTwoRead;
    else
        return NO;
}


- (void)setThisUsersHasRead:(BOOL)hasRead
{
    // Sets the other user's 'hasRead' flag
    
    if ([[SMBUser currentUser].objectId isEqualToString:self.userOne.objectId])
        self.userOneRead = hasRead;
    else if ([[SMBUser currentUser].objectId isEqualToString:self.userTwo.objectId])
        self.userTwoRead = hasRead;
    else
        NSLog(@"%s - Warning: Tried to set the this user's 'has read' flag when there is no this user!", __PRETTY_FUNCTION__);
}


- (void)setOtherUsersHasRead:(BOOL)hasRead
{
    // Sets the other user's 'hasRead' flag
    
    if ([[self otherUser].objectId isEqualToString:self.userOne.objectId])
        self.userOneRead = hasRead;
    else if ([[self otherUser].objectId isEqualToString:self.userTwo.objectId])
        self.userTwoRead = hasRead;
    else
        NSLog(@"%s - Warning: Tried to set the other user's 'has read' flag when there is no other user!", __PRETTY_FUNCTION__);
}


- (BOOL)thisUserHasRevealed
{
    if ([[SMBUser currentUser].objectId isEqualToString:self.userOne.objectId])
        return self.userOneRevealed;
    else if ([[SMBUser currentUser].objectId isEqualToString:self.userTwo.objectId])
        return self.userTwoRevealed;
    else
        return NO;
}


- (BOOL)otherUserHasRevealed
{
    if ([[self otherUser].objectId isEqualToString:self.userOne.objectId])
        return self.userOneRevealed;
    else if ([[self otherUser].objectId isEqualToString:self.userTwo.objectId])
        return self.userTwoRevealed;
    else
        return NO;
}


- (void)setThisUsersHasRevealed:(BOOL)hasRevealed
{
    if ([[SMBUser currentUser].objectId isEqualToString:self.userOne.objectId])
        self.userOneRevealed = hasRevealed;
    else if ([[SMBUser currentUser].objectId isEqualToString:self.userTwo.objectId])
        self.userTwoRevealed = hasRevealed;
}


- (void)setOtherUsersHasRevealed:(BOOL)hasRevealed
{
    if ([[self otherUser].objectId isEqualToString:self.userOne.objectId])
        self.userOneRevealed = hasRevealed;
    else if ([[self otherUser].objectId isEqualToString:self.userTwo.objectId])
        self.userTwoRevealed = hasRevealed;
}


- (void)setThisUserRemoved:(BOOL)removed
{
    if ([[SMBUser currentUser].objectId isEqualToString:self.userOne.objectId])
        self.userOneRemoved = removed;
    else if ([[SMBUser currentUser].objectId isEqualToString:self.userTwo.objectId])
        self.userTwoRemoved = removed;
    else
        NSLog(@"%s - WARNING: Tried to set this user as removed when user is not a member of chat", __PRETTY_FUNCTION__);
}


- (void)setOtherUserRemoved:(BOOL)removed
{
    if ([[self otherUser].objectId isEqualToString:self.userOne.objectId])
        self.userOneRemoved = removed;
    else if ([[self otherUser].objectId isEqualToString:self.userTwo.objectId])
        self.userTwoRemoved = removed;
    else
        NSLog(@"%s - WARNING: Tried to set other user as removed when user is not a member of chat", __PRETTY_FUNCTION__);
}


- (BOOL)otherUserHasRemoved
{
    if ([[self otherUser].objectId isEqualToString:self.userOne.objectId])
        return self.userOneRemoved;
    else if ([[self otherUser].objectId isEqualToString:self.userTwo.objectId])
        return self.userTwoRemoved;
    else
        return NO;
}


@end
