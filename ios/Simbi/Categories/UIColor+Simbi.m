//
//  UIColor+Simbi.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "UIColor+Simbi.h"


@implementation UIColor (Simbi)

+ (UIColor *)simbiBlueColor         { return [UIColor colorWithRed: 65/255.f green:114/255.f blue:232/255.f alpha:1.f]; }

+ (UIColor *)simbiSkyBlueColor      { return [UIColor colorWithRed: 62/255.f green:188/255.f blue:209/255.f alpha:1.f]; }
+ (UIColor *)simbiYellowColor       { return [UIColor colorWithRed:243/255.f green:223/255.f blue: 70/255.f alpha:1.f]; }
+ (UIColor *)simbiRedColor          { return [UIColor colorWithRed:190/255.f green: 25/255.f blue: 32/255.f alpha:1.f]; }
+ (UIColor *)simbiGreenColor        { return [UIColor colorWithRed:132/255.f green:223/255.f blue:131/255.f alpha:1.f]; }
+ (UIColor *)simbiPinkColor         { return [UIColor colorWithRed:213/255.f green: 82/255.f blue:102/255.f alpha:1.f]; }
+ (UIColor *)simbiOrangeColor       { return [UIColor colorWithRed:225/255.f green:157/255.f blue: 38/255.f alpha:1.f]; }
+ (UIColor *)simbiLavender1Color    { return [UIColor colorWithRed:222/255.f green:227/255.f blue:249/255.f alpha:1.f]; }
+ (UIColor *)simbiLavender2Color    { return [UIColor colorWithRed:200/255.f green:213/255.f blue:248/255.f alpha:1.f]; }

+ (UIColor *)simbiWhiteColor        { return [UIColor colorWithRed:252/255.f green:249/255.f blue:245/255.f alpha:1.f]; }
+ (UIColor *)simbiLightGrayColor    { return [UIColor colorWithRed:233/255.f green:231/255.f blue:232/255.f alpha:1.f]; }
+ (UIColor *)simbiGrayColor         { return [UIColor colorWithRed:216/255.f green:210/255.f blue:204/255.f alpha:1.f]; }
+ (UIColor *)simbiDarkGrayColor     { return [UIColor colorWithRed: 81/255.f green: 84/255.f blue: 87/255.f alpha:1.f]; }
+ (UIColor *)simbiBlackColor        { return [UIColor colorWithRed: 40/255.f green: 40/255.f blue: 40/255.f alpha:1.f]; }

+ (UIColor *)facebookColor          { return [UIColor colorWithRed: 59/255.f green: 89/255.f blue:161/255.f alpha:1.f]; }
+ (UIColor *)twitterColor           { return [UIColor colorWithRed: 93/255.f green:168/255.f blue:223/255.f alpha:1.f]; }

// Old colors

+ (UIColor *)simbiLightTealColor    { return [UIColor colorWithRed:219/255.f green:232/255.f blue:232/255.f alpha:1.f]; }
+ (UIColor *)simbiDarkBlueColor     { return [UIColor colorWithRed: 41/255.f green: 61/255.f blue:117/255.f alpha:1.f]; }


+ (UIColor *)randomPreferenceColorForName:(NSString *)name
{
    long woop = 0;
    
    for (int i = 0; i < name.length; i++)
        woop += [name characterAtIndex:i];
    
    woop = woop % 3;
    
    if (woop == 0)
        return [UIColor simbiRedColor];
    else if (woop == 1)
        return [UIColor simbiYellowColor];
    else
        return [UIColor simbiGreenColor];
}

@end
