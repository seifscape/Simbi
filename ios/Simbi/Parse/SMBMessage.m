//
//  SMBMessage.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBMessage.h"

#import "JSQMessage.h"

@implementation SMBMessage

@dynamic messageText;
@dynamic dateSent;
@dynamic fromUser;
@dynamic toUser;
@dynamic image;
@dynamic chat;
@dynamic isAction;
@dynamic isAccept;
@dynamic challengeId;
@dynamic questionId;

+ (NSString *)parseClassName
{
    return @"Message";
}


- (JSQMessage *)JSQMessage
{
    if ([[SMBUser currentUser].objectId isEqualToString:self.fromUser.objectId])
        return [JSQMessage messageWithText:[self.messageText stringByAppendingString:@""] sender:@"ME"];
    else
        return [JSQMessage messageWithText:[self.messageText stringByAppendingString:@""] sender:@"OTHER"];
}


@end
