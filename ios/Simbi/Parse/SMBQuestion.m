//
//  SMBQuestion.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBQuestion.h"

@implementation SMBQuestion

@dynamic questionType;
@dynamic toUser;
@dynamic fromUser;
@dynamic questionText;
@dynamic answer;
@dynamic chat;
@dynamic accepted;

+ (NSString *)parseClassName
{
    return @"Question";
}


- (SMBUser *)otherUser
{
    if ([[SMBUser currentUser].objectId isEqualToString:self.toUser.objectId])
        return self.toUser;
    else if ([[SMBUser currentUser].objectId isEqualToString:self.fromUser.objectId])
        return self.fromUser;
    else
        return nil;
}


@end
