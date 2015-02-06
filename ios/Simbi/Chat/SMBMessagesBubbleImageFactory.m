//
//  SMBMessagesBubbleImageFactory.m
//  Simbi
//
//  Created by flynn on 8/18/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBMessagesBubbleImageFactory.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"


@interface SMBMessagesBubbleImageFactory ()

+ (UIImageView *)bubbleImageViewWithColor:(UIColor *)color flippedForIncoming:(BOOL)flippedForIncoming;

+ (UIImage *)smb_horizontallyFlippedImageFromImage:(UIImage *)image;

+ (UIImage *)smb_stretchableImageFromImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets;

@end


@implementation SMBMessagesBubbleImageFactory

#pragma mark - Public

+ (UIImageView *)outgoingMessageBubbleImageViewWithColor:(UIColor *)color
{
    NSParameterAssert(color != nil);
    return [SMBMessagesBubbleImageFactory bubbleImageViewWithColor:color flippedForIncoming:NO];
}


+ (UIImageView *)incomingMessageBubbleImageViewWithColor:(UIColor *)color
{
    NSParameterAssert(color != nil);
    return [SMBMessagesBubbleImageFactory bubbleImageViewWithColor:color flippedForIncoming:YES];
}


#pragma mark - Private

+ (UIImageView *)bubbleImageViewWithColor:(UIColor *)color flippedForIncoming:(BOOL)flippedForIncoming
{
    UIImage *bubble = [UIImage imageNamed:@"simbi_bubble"];
    
    UIImage *normalBubble = [bubble jsq_imageMaskedWithColor:color];
    UIImage *highlightedBubble = [bubble jsq_imageMaskedWithColor:[color jsq_colorByDarkeningColorWithValue:0.12f]];
    
    if (flippedForIncoming) {
        normalBubble = [SMBMessagesBubbleImageFactory smb_horizontallyFlippedImageFromImage:normalBubble];
        highlightedBubble = [SMBMessagesBubbleImageFactory smb_horizontallyFlippedImageFromImage:highlightedBubble];
    }
    
    // make image stretchable from center point
    CGPoint center = CGPointMake(bubble.size.width / 2.0f, bubble.size.height / 2.0f);
    UIEdgeInsets capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
    
    normalBubble = [SMBMessagesBubbleImageFactory smb_stretchableImageFromImage:normalBubble withCapInsets:capInsets];
    highlightedBubble = [SMBMessagesBubbleImageFactory smb_stretchableImageFromImage:highlightedBubble withCapInsets:capInsets];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:normalBubble highlightedImage:highlightedBubble];
    imageView.backgroundColor = [UIColor whiteColor];
    return imageView;
}


+ (UIImage *)smb_horizontallyFlippedImageFromImage:(UIImage *)image
{
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationUpMirrored];
}


+ (UIImage *)smb_stretchableImageFromImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets
{
    return [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

@end
