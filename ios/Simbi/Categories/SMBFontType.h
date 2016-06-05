//
//  SMBFontType.h
//  Simbi
//
//  Created by Seif Kobrosly on 3/29/16.
//  Copyright © 2016 SimbiSocial. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMBFontType : NSObject

@end

typedef enum : NSUInteger {
    kFontRegular    = (1 << 0),
    kFontBlack      = (1 << 1),
    kFontBold       = (1 << 2),
    kFontItalic     = (1 << 3),
    kFontCondensed  = (1 << 4),
    kFontLight      = (1 << 5),
    kFontMedium     = (1 << 6)
} SMBFontAttribute;