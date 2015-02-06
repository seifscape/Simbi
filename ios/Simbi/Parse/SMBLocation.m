//
//  SMBLocation.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBLocation.h"

@implementation SMBLocation

@dynamic locationName;
@dynamic geoPoint;
@dynamic image;

+ (NSString *)parseClassName
{
    return @"Location";
}

@end
