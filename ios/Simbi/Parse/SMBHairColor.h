//
//  SMBHairColor.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>

@interface SMBHairColor : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

- (UIColor *)UIColor;

@property (retain) NSString *colorName;
@property (retain) NSNumber *redValue;
@property (retain) NSNumber *greenValue;
@property (retain) NSNumber *blueValue;

@end
