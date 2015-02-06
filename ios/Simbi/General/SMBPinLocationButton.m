//
//  SMBPinLocationButton.m
//  Simbi
//
//  Created by flynn on 7/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBPinLocationButton.h"


@implementation SMBPinLocationButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setFrame:frame];
    
    if (self)
    {
        [self setBackgroundColor:[[UIColor simbiWhiteColor] colorWithAlphaComponent:0.9f]];
        [self.layer setCornerRadius:4.f];
        [self.layer setBorderColor:[UIColor simbiBlueColor].CGColor];
        [self.layer setBorderWidth:1.f];
        
        UIView *leftDotView = [[UIView alloc] initWithFrame:CGRectMake(12, self.frame.size.height/2.f-4, 8, 8)];
        [leftDotView setBackgroundColor:[UIColor simbiBlueColor]];
        [leftDotView.layer setCornerRadius:leftDotView.frame.size.width/2.f];
        [leftDotView setUserInteractionEnabled:NO];
        [self addSubview:leftDotView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [label setText:@"Pin Location"];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont simbiFontWithSize:12.f]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setUserInteractionEnabled:NO];
        [self addSubview:label];
        
        UIView *rightOuterDotView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-44, 8, 28, 28)];
        [rightOuterDotView setBackgroundColor:[UIColor simbiBlueColor]];
        [rightOuterDotView.layer setCornerRadius:rightOuterDotView.frame.size.width/2.f];
        [rightOuterDotView setUserInteractionEnabled:NO];
        
        UIView *rightInnerDotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        [rightInnerDotView setCenter:CGPointMake(rightOuterDotView.frame.size.width/2.f, rightOuterDotView.frame.size.height/2.f)];
        [rightInnerDotView setBackgroundColor:[UIColor simbiWhiteColor]];
        [rightInnerDotView.layer setCornerRadius:rightInnerDotView.frame.size.width/2.f];
        [rightInnerDotView setUserInteractionEnabled:NO];
        [rightOuterDotView addSubview:rightInnerDotView];
        
        [self addSubview:rightOuterDotView];
    }
    
    return self;
}

@end
