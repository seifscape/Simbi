//
//  UIFont+Simbi.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "UIFont+Simbi.h"

@implementation UIFont (Simbi)

BOOL typeInMask(SMBFontAttribute mask, SMBFontAttribute type)
{
    return (mask & type) == type;
}


+ (UIFont *)simbiFontWithAttributes:(SMBFontAttribute)attributes size:(CGFloat)size
{
    if (attributes == kFontRegular)
    {
        return [UIFont fontWithName:@"DINOT-Regular" size:size];
    }
    if (typeInMask(attributes, kFontBlack))
    {
        if (attributes == kFontBlack || typeInMask(attributes, kFontRegular))
            return [UIFont fontWithName:@"DINOT-Black" size:size];
        
        if (typeInMask(attributes, kFontItalic))
            return [UIFont fontWithName:@"DINOT-BlackItalic" size:size];
    }
    if (typeInMask(attributes, kFontBold))
    {
        if (attributes == kFontBold || typeInMask(attributes, kFontRegular))
            return [UIFont fontWithName:@"DINOT-Bold" size:size];
        
        if (typeInMask(attributes, kFontItalic))
            return [UIFont fontWithName:@"DINOT-BoldItalic" size:size];
    }
    if (typeInMask(attributes, kFontCondensed))
    {
        if (attributes == kFontCondensed || typeInMask(attributes, kFontRegular))
            return [UIFont fontWithName:@"DINOT-CondRegular" size:size];
        
        if (typeInMask(attributes, kFontBlack))
            return [UIFont fontWithName:@"DINOT-CondBlack" size:size];
        
        if (typeInMask(attributes, kFontBold))
            return [UIFont fontWithName:@"DINOT-CondBold" size:size];
        
        if (typeInMask(attributes, kFontLight))
            return [UIFont fontWithName:@"DINOT-CondLight" size:size];
        
        if (typeInMask(attributes, kFontMedium))
            return [UIFont fontWithName:@"DINOT-CondMedium" size:size];
    }
    if (typeInMask(attributes, kFontLight))
    {
        if (attributes == kFontLight || typeInMask(attributes, kFontRegular))
            return [UIFont fontWithName:@"DINOT-Light" size:size];
        
        if (typeInMask(attributes, kFontItalic))
            return [UIFont fontWithName:@"DINOT-LightItalic" size:size];
    }
    if (typeInMask(attributes, kFontMedium))
    {
        if (attributes == kFontMedium || typeInMask(attributes, kFontRegular))
            return [UIFont fontWithName:@"DINOT-Medium" size:size];
        
        if (typeInMask(attributes, kFontItalic))
            return [UIFont fontWithName:@"DINOT-MediumItalic" size:size];
    }

    NSLog(@"WARNING: No font for given mask!");
    return nil;
}


#pragma mark - Deprecated Methods

+ (UIFont *)simbiFontWithSize:(CGFloat)size
{
    return [UIFont simbiFontWithAttributes:kFontRegular size:size];
}


+ (UIFont *)simbiBoldFontWithSize:(CGFloat)size
{
    return [UIFont simbiFontWithAttributes:kFontBold size:size];
}


+ (UIFont *)simbiLightFontWithSize:(CGFloat)size
{
    return [UIFont simbiFontWithAttributes:kFontLight size:size];
}


@end
