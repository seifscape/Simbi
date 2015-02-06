//
//  SMBActivity.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBActivity.h"

@implementation SMBActivity

@dynamic user;
@dynamic userObjectId;
@dynamic activityType;
@dynamic activityText;
@dynamic activityLocation;

+ (NSString *)parseClassName
{
    return @"Activity";
}


@end
