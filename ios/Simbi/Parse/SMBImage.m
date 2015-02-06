//
//  SMBImage.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBImage.h"

@implementation SMBImage

@dynamic originalImage;
@dynamic mediumImage;
@dynamic mediumSquareImage;
@dynamic thumbnailImage;
@dynamic content;

+ (NSString *)parseClassName
{
    return @"Image";
}

@end
