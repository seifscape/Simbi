//
//  NSDate+Simbi.m
//  Simbi
//
//  Created by flynn on 7/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "NSDate+Simbi.h"

@implementation NSDate (Simbi)

- (NSString *)relativeDateString
{
    static const int SECOND = 1;
    static const int MINUTE = 60 * SECOND;
    static const int HOUR   = 60 * MINUTE;
    static const int DAY    = 24 * HOUR;
    static const int MONTH  = 30 * DAY;
    
    NSDate *now = [NSDate date];
    NSTimeInterval delta = [self timeIntervalSinceDate:now] * -1.0;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [calendar components:units fromDate:self toDate:now options:0];
    
    NSString *relativeString;
    
    if (delta < 0) {
        relativeString = @""; // in the future!
    } else if (delta < 1 * MINUTE) {
        relativeString = (components.second == 1) ? @"1 s" : [NSString stringWithFormat:@"%d s",components.second];
        
    } else if (delta < 2 * MINUTE) {
        relativeString =  @"1 m";
        
    } else if (delta < 45 * MINUTE) {
        relativeString = [NSString stringWithFormat:@"%d m",components.minute];
        
    } else if (delta < 90 * MINUTE) {
        relativeString = @"1 hr";
        
    } else if (delta < 24 * HOUR) {
        relativeString = [NSString stringWithFormat:@"%d hrs",components.hour];
        
    } else if (delta < 48 * HOUR) {
        relativeString = @"1 day";
        
    } else if (delta < 30 * DAY) {
        relativeString = [NSString stringWithFormat:@"%d days",components.day];
        
    } else if (delta < 12 * MONTH) {
        relativeString = (components.month <= 1) ? @"1 month" : [NSString stringWithFormat:@"%d months",components.month];
        
    } else {
        relativeString = (components.year <= 1) ? @"1 year" : [NSString stringWithFormat:@"%d years",components.year];
    }
    
    return relativeString;
}


- (NSDate *)twentyMinutesFromDate
{
    const int secondsInMinute = 60;
    return [self dateByAddingTimeInterval:secondsInMinute*20];
}


@end
