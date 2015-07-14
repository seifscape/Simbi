//
//  LSUtility.m
//  SmartTopicNews
//
//  Created by Rebecca on 15/5/19.
//  Copyright (c) 2015年 Smart Topic Company. All rights reserved.
//

#import "LSUtility.h"

@implementation LSUtility

+(UIImage *)getSnapshotGaussianBlurInputRadius:(CGFloat)inputRadius view:(UIView*)view inRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width,view.frame.size.height), YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = viewImage.CGImage;
    CGRect turnRect = CGRectMake(rect.origin.x*(CGImageGetWidth(imageRef)/view.frame.size.width), rect.origin.y*(CGImageGetHeight(imageRef)/view.frame.size.height),rect.size.width* (CGImageGetWidth(imageRef)/view.frame.size.width),rect.size.height*(CGImageGetHeight(imageRef)/view.frame.size.height));
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, turnRect);
//    CGImageRelease(imageRef);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *image = [CIImage imageWithCGImage:imageRefRect];
//    CGImageRelease(imageRefRect);
    
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:@(inputRadius) forKey: @"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef outImageRef = [context createCGImage: result fromRect:[result extent]];
    UIImage * blurImage = [[UIImage alloc]initWithCGImage:outImageRef];
    CGImageRelease(outImageRef);
    
    return blurImage;
}


+(UIImage *)getSnapshotWithView:(UIView *)view inRect:(CGRect )rect
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width,view.frame.size.height), YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = viewImage.CGImage;
    CGRect turnRect = CGRectMake(rect.origin.x*(CGImageGetWidth(imageRef)/view.frame.size.width), rect.origin.y*(CGImageGetHeight(imageRef)/view.frame.size.height),rect.size.width* (CGImageGetWidth(imageRef)/view.frame.size.width),rect.size.height*(CGImageGetHeight(imageRef)/view.frame.size.height));
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, turnRect);
    UIImage * snapshotImage = [[UIImage alloc]initWithCGImage:imageRefRect];
    return snapshotImage;
}

@end
