//
//  SMBChatCircleTimerView.m
//  Simbi
//
//  Created by flynn on 7/25/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChatCircleTimerView.h"


@interface SMBChatCircleTimerView ()

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic) CGFloat progress;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *chatId;

@end


@implementation SMBChatCircleTimerView

static const CGFloat kAngleOffset = -90.0f;
static const CGFloat kDegreesInRadian = 180/M_PI;

- (instancetype)initWithFrame:(CGRect)frame chat:(SMBChat *)chat
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _chatId = chat.objectId;
        
        if (chat.dateStarted)
            [self setTime:chat.dateStarted];
        
        _progress = 0.f;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(update) userInfo:nil repeats:YES];
        
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
        [self setTime:notification.userInfo[@"date"]];
    }
}


- (void)handleChallengeAcceptedNotification:(NSNotification *)notification
{
    if ([_chatId isEqualToString:notification.userInfo[@"chatId"]])
    {
        if (![self hasTime])
            [self setTime:[NSDate date]];
    }
}


- (void)handleQuestionAcceptedNotification:(NSNotification *)notification
{
    if ([_chatId isEqualToString:notification.userInfo[@"chatId"]])
    {
        if (![self hasTime])
            [self setTime:[NSDate date]];
    }
}


- (BOOL)hasTime
{
    return (BOOL)_startTime;
}


- (void)setTime:(NSDate *)time
{
    _startTime = time;
    _endTime = [time twentyMinutesFromDate];
    
    [self setNeedsDisplay];
}


- (BOOL)hasExpired
{
    return NO;
}


- (void)update
{
    if (_startTime)
    {
        NSTimeInterval currentTime = [NSDate date].timeIntervalSince1970;
        NSTimeInterval startTime = _startTime.timeIntervalSince1970;
        NSTimeInterval endTime = _endTime.timeIntervalSince1970;
        
        _progress = MIN((currentTime-startTime)/(float)(endTime-startTime), 1.f);
    }
    else
        _progress = 0.f;
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Adapted from SSToolKit/SSPieProgressView.m (https://github.com/samsoffes/sstoolkit)
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat radius = center.y;
    CGFloat angle = ((360.0f * _progress) + kAngleOffset)/kDegreesInRadian;
    CGPoint points[3] = {
        CGPointMake(center.x, 0.0f),
        center,
        CGPointMake(center.x + radius * cosf(angle), center.y + radius * sinf(angle))
    };
    
    CGContextSetFillColorWithColor(context, [UIColor simbiBlueColor].CGColor);
    
    CGContextAddLines(context, points, sizeof(points) / sizeof(points[0]));
    CGContextAddArc(context, center.x, center.y, radius, kAngleOffset/kDegreesInRadian, angle, false);
    CGContextDrawPath(context, kCGPathEOFill);
}


@end
