//
//  UIFont+Simbi.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFontType.h"


@interface UIFont (Simbi)

// Font attribute bitmask
+ (UIFont *)simbiFontWithAttributes:(SMBFontAttribute)attributes size:(CGFloat)size;

+ (UIFont *)simbiFontWithSize:(CGFloat)size;
+ (UIFont *)simbiBoldFontWithSize:(CGFloat)size;
+ (UIFont *)simbiLightFontWithSize:(CGFloat)size;

@end

