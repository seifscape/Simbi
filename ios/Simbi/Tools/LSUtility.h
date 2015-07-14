//
//  LSUtility.h
//  SmartTopicNews
//
//  Created by Rebecca on 15/5/19.
//  Copyright (c) 2015年 Smart Topic Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LSUtility : NSObject


+(UIImage *)getSnapshotGaussianBlurInputRadius:(CGFloat)inputRadius view:(UIView*)view inRect:(CGRect)rect;

+(UIImage *)getSnapshotWithView:(UIView *)view inRect:(CGRect )rect;

@end
