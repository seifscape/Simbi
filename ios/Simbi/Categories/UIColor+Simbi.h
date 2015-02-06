//
//  UIColor+Simbi.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface UIColor (Simbi)

+ (UIColor *)simbiBlueColor;

+ (UIColor *)simbiSkyBlueColor;
+ (UIColor *)simbiYellowColor;
+ (UIColor *)simbiRedColor;
+ (UIColor *)simbiGreenColor;
+ (UIColor *)simbiPinkColor;
+ (UIColor *)simbiOrangeColor;
+ (UIColor *)simbiLavender1Color;
+ (UIColor *)simbiLavender2Color;

+ (UIColor *)simbiWhiteColor;
+ (UIColor *)simbiLightGrayColor;
+ (UIColor *)simbiGrayColor;
+ (UIColor *)simbiDarkGrayColor;
+ (UIColor *)simbiBlackColor;

+ (UIColor *)facebookColor;
+ (UIColor *)twitterColor;


// Old colors
+ (UIColor *)simbiLightTealColor __deprecated;
+ (UIColor *)simbiDarkBlueColor __deprecated;

+ (UIColor *)randomPreferenceColorForName:(NSString *)name;

@end
