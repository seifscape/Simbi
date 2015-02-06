//
//  SMBTimerLabel.m
//  Simbi
//
//  Created by flynn on 6/12/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBTimerLabel.h"


@interface SMBTimerLabel ()

@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) NSInteger numberOfMinutes;
@property (nonatomic, strong) NSDate *dateExpires;
@property (nonatomic) BOOL hasExpired;

@end


@implementation SMBTimerLabel

- (instancetype)initWithFrame:(CGRect)frame chat:(SMBChat *)chat
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _chatId = chat.objectId;
        
        _hasExpired = NO;
        
        _numberOfMinutes = 20;
        
        [self setText:@"20:00"];
        [self setTextColor:[UIColor simbiBlueColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        
        if (chat.dateStarted)
            [self setDate:chat.dateStarted];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTimerUpdateNotification:) name:kSMBNotificationTimerUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChallengeAcceptedNotification:) name:kSMBNotificationChallengeAccepted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuestionAcceptedNotification:) name:kSMBNotificationQuestionAccepted object:nil];
    }
    
    return self;
}


- (void)dealloc
{
    if (_timer)
        [_timer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)handleTimerUpdateNotification:(NSNotification *)notification
{
    if ([_chatId isEqualToString:notification.userInfo[@"chatId"]])
    {
        [self setDate:notification.userInfo[@"date"]];
    }
}


- (void)handleChallengeAcceptedNotification:(NSNotification *)notification
{
    if ([_chatId isEqualToString:notification.userInfo[@"chatId"]])
    {
        if (![self hasTime])
            [self setDate:[NSDate date]];
    }
}


- (void)handleQuestionAcceptedNotification:(NSNotification *)notification
{
    if ([_chatId isEqualToString:notification.userInfo[@"chatId"]])
    {
        if (![self hasTime])
            [self setDate:[NSDate date]];
    }
}


- (void)setDate:(NSDate *)date
{
    [self setTextColor:[UIColor simbiRedColor]];
    _dateExpires = [date dateByAddingTimeInterval:60*_numberOfMinutes];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(update) userInfo:nil repeats:YES];
    [self update];
}


- (void)update
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:[NSDate date] toDate:_dateExpires options:0];
    
    int minutes = (int)[components minute];
    int seconds = (int)[components second];
    
    if (minutes < 0)
        minutes = 0;
    if (seconds < 0)
        seconds = 0;
    
    [self setText:[NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
    
    if (minutes == 0 && seconds == 0)
    {
        _hasExpired = YES;
        [_timer invalidate];
        _timer = nil;
        [self setTextColor:[UIColor simbiGrayColor]];
        
        NSDictionary *userInfo = @{ @"chatId" : _chatId };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationTimerExpired object:nil userInfo:userInfo];
    }
}


- (BOOL)hasTime
{
    return (BOOL)_dateExpires;
}


- (BOOL)hasExpired
{
    return _hasExpired;
}


@end
