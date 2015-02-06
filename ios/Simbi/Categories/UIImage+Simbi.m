//
//  UIImage+Simbi.m
//  Simbi
//
//  Created by flynn on 6/20/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "UIImage+Simbi.h"

@implementation UIImage (Simbi)

- (UIImage *)imageWithRoundedCornerSize:(CGFloat)cornerRadius
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
    
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    [self drawInRect:imageView.bounds];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageView.image;
}


- (UIImage *)imageResizedByScale:(CGFloat)scale
{
    CGSize size = CGSizeMake(self.size.width/scale, self.size.height/scale);
    
    UIGraphicsBeginImageContext(size);
    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (UIImage *)imageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (UIImage *)imageWithBackgroundColorForName:(NSString *)name
{
    UIImage *image = [self copy];
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 1.0);
    [[UIColor randomPreferenceColorForName:name] setFill];
    UIRectFill(CGRectMake(0, 0, image.size.width, image.size.height));
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage *)filteredBlueImage
{
    // Create a false color filter and apply it to our image
    CIImage *image = [CIImage imageWithCGImage:self.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIFalseColor"];
    [filter setValue:image forKey:@"inputImage"];
    [filter setValue:[CIColor colorWithCGColor:[UIColor simbiBlueColor].CGColor] forKey:@"inputColor0"];
    [filter setValue:[CIColor colorWithCGColor:[UIColor simbiWhiteColor].CGColor] forKey:@"inputColor1"];
    
    image = filter.outputImage;
    
    // Create a UIImage from the CIImage
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImageRef = [context createCGImage:image fromRect:image.extent];
    UIImage *filteredImage = [UIImage imageWithCGImage:cgImageRef];
    
    CGImageRelease(cgImageRef); // run free!
    
    return filteredImage;
}


@end
