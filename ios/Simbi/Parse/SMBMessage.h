//
//  SMBMessage.h
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>


@class JSQMessage;

@class SMBChat;
@class SMBImage;
@class SMBUser;


@interface SMBMessage : PFObject <PFSubclassing>

+ (NSString *)parseClassName;
- (JSQMessage *)JSQMessage;

@property (retain) NSString *messageText;
@property (retain) NSDate *dateSent;
@property (retain) SMBUser *fromUser;
@property (retain) SMBUser *toUser;
@property (retain) SMBImage *image;
@property (retain) SMBChat *chat;
@property BOOL isAction;
@property BOOL isAccept;
@property (retain) NSString *challengeId;
@property (retain) NSString *questionId;

@end
