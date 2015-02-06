//
//  SMBHairColor.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBHairColor.h"

@implementation SMBHairColor

@dynamic colorName;
@dynamic redValue;
@dynamic greenValue;
@dynamic blueValue;

+ (NSString *)parseClassName
{
    return @"HairColor";
}


- (UIColor *)UIColor
{
    return [UIColor colorWithRed:self.redValue.intValue/255.f
                           green:self.greenValue.intValue/255.f
                            blue:self.blueValue.intValue/255.f
                           alpha:1.f];
}


@end
