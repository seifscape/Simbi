//
//  SMBTimerLabel.h
//  Simbi
//
//  Created by flynn on 6/12/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface SMBTimerLabel : UILabel

- (instancetype)initWithFrame:(CGRect)frame chat:(SMBChat *)chat;

- (void)setDate:(NSDate *)date;
- (BOOL)hasTime;
- (BOOL)hasExpired;

@end
