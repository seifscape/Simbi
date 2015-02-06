//
//  SMBChatCircleTimerView.h
//  Simbi
//
//  Created by flynn on 7/25/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBChat;


@interface SMBChatCircleTimerView : UIView

- (instancetype)initWithFrame:(CGRect)frame chat:(SMBChat *)chat;

- (void)setTime:(NSDate *)time;
- (BOOL)hasExpired;

@end
