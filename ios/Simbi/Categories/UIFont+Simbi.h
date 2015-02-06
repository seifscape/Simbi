//
//  UIFont+Simbi.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface UIFont (Simbi)

// Font attribute bitmask

typedef enum : NSUInteger {
    kFontRegular    = (1 << 0),
    kFontBlack      = (1 << 1),
    kFontBold       = (1 << 2),
    kFontItalic     = (1 << 3),
    kFontCondensed  = (1 << 4),
    kFontLight      = (1 << 5),
    kFontMedium     = (1 << 6)
} SMBFontAttribute;

+ (UIFont *)simbiFontWithAttributes:(SMBFontAttribute)attributes size:(CGFloat)size;

+ (UIFont *)simbiFontWithSize:(CGFloat)size;
+ (UIFont *)simbiBoldFontWithSize:(CGFloat)size;
+ (UIFont *)simbiLightFontWithSize:(CGFloat)size;

@end
