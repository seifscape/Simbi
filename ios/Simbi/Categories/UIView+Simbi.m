//
//  UIView+Simbi.m
//  Simbi
//
//  Created by flynn on 5/30/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "UIView+Simbi.h"

@implementation UIView (Simbi)

- (void)drawCorners
{
    // Debugging method that will draw squares at each corner of the view to show that it's positioned correctly
    
    UIView *topLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    [topLeft setBackgroundColor:[UIColor blackColor]];
    [self addSubview:topLeft];
    
    UIView *topRight = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-8, 0, 8, 8)];
    [topRight setBackgroundColor:[UIColor blackColor]];
    [self addSubview:topRight];
    
    UIView *bottomLeft = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-8, 8, 8)];
    [bottomLeft setBackgroundColor:[UIColor blackColor]];
    [self addSubview:bottomLeft];

    UIView *bottomRight = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-8, self.frame.size.height-8, 8, 8)];
    [bottomRight setBackgroundColor:[UIColor blackColor]];
    [self addSubview:bottomRight];
}


- (void)roundSide:(SMBSide)side
{
    UIBezierPath *maskPath;
    
    if (side == kSMBSideLeft)
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                         byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)
                                               cornerRadii:CGSizeMake(8.f, 8.f)];
    else if (side == kSMBSideRight)
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                         byRoundingCorners:(UIRectCornerTopRight|UIRectCornerBottomRight)
                                               cornerRadii:CGSizeMake(8.f, 8.f)];
    else if (side == kSMBSideUp)
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                         byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                               cornerRadii:CGSizeMake(8.f, 8.f)];
    else
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                         byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                               cornerRadii:CGSizeMake(8.f, 8.f)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    self.layer.mask = maskLayer;
    
    [self.layer setMasksToBounds:YES];
}


- (void)makeLayerHexagonal
{
    // From https://github.com/phatblat/Hexagon/blob/master/Hexagon/HexagonView.m
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.frame = self.bounds;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat hPadding = width * 1 / 8 / 2;
    
    UIGraphicsBeginImageContext(self.frame.size);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(width/2, 0)];
    [path addLineToPoint:CGPointMake(width - hPadding, height / 4)];
    [path addLineToPoint:CGPointMake(width - hPadding, height * 3 / 4)];
    [path addLineToPoint:CGPointMake(width / 2, height)];
    [path addLineToPoint:CGPointMake(hPadding, height * 3 / 4)];
    [path addLineToPoint:CGPointMake(hPadding, height / 4)];
    [path closePath];
    [path fill];
    maskLayer.path = path.CGPath;
    UIGraphicsEndImageContext();
    self.layer.mask = maskLayer;
}


- (void)addToView:(UIView *)view andAnimate:(BOOL)animate
{    
    if (animate)
    {        
        [UIView animateWithDuration:0.25f animations:^{
            [self setAlpha:1.f];
        }];
    }
    
    [view addSubview:self];
}


- (void)removeFromViewAndAnimate:(BOOL)animate
{
    if (animate)
    {
        [UIView animateWithDuration:0.25f animations:^{
            [self setAlpha:0.f];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    else
        [self removeFromSuperview];
}


@end
