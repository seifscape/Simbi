//
//  UIView+Simbi.h
//  Simbi
//
//  Created by flynn on 5/30/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface UIView (Simbi)

typedef enum SMBSide : NSInteger { kSMBSideLeft, kSMBSideRight, kSMBSideUp, kSMBSideDown } SMBSide;

- (void)roundSide:(SMBSide)side;
- (void)makeLayerHexagonal;

- (void)addToView:(UIView *)view andAnimate:(BOOL)animate;
- (void)removeFromViewAndAnimate:(BOOL)animate;

@end
