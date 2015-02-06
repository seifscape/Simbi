//
//  SMBQuestion.h
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>


@class SMBChat;
@class SMBUser;


@interface SMBQuestion : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

- (SMBUser *)otherUser;

@property (retain) NSString *questionType;
@property (retain) SMBUser *toUser;
@property (retain) SMBUser *fromUser;
@property (retain) NSString *questionText;
@property (retain) NSString *answer;
@property (retain) SMBChat *chat;
@property BOOL accepted;

@end
