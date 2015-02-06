//
//  UIImage+Simbi.h
//  Simbi
//
//  Created by flynn on 6/20/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface UIImage (Simbi)

- (UIImage *)imageWithRoundedCornerSize:(CGFloat)cornerRadius;
- (UIImage *)imageResizedByScale:(CGFloat)scale;
- (UIImage *)imageWithSize:(CGSize)size;
- (UIImage *)imageWithBackgroundColorForName:(NSString *)name;
- (UIImage *)filteredBlueImage;

@end
