//
//  UIButton+Simbi.m
//  Simbi
//
//  Created by flynn on 5/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "UIButton+Simbi.h"

@implementation UIButton (Simbi)

+ (UIButton *)simbiRedButtonWithFrame:(CGRect)frame
{
    return [UIButton simbiButtonWithFrame:frame color:[UIColor simbiRedColor]];
}


+ (UIButton *)simbiBlueButtonWithFrame:(CGRect)frame
{
    return [UIButton simbiButtonWithFrame:frame color:[UIColor simbiBlueColor]];
}


+ (UIButton *)simbiFacebookButtonWithFrame:(CGRect)frame title:(NSString *)title
{
    UIButton *button = [UIButton simbiButtonWithFrame:frame color:[UIColor simbiRedColor]];
    
    UIImageView *facebookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, button.frame.size.height-16, button.frame.size.height-16)];
    [facebookImageView setImage:[UIImage imageNamed:@"FacebookIcon"]];
    [facebookImageView setUserInteractionEnabled:NO];
    [button addSubview:facebookImageView];
    
    UILabel *facebookButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.size.height-12, 0, button.frame.size.width-32, button.frame.size.height)];
    [facebookButtonLabel setText:title];
    [facebookButtonLabel setFont:[UIFont simbiBoldFontWithSize:18.f]];
    [facebookButtonLabel setTextColor:[UIColor whiteColor]];
    [facebookButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [facebookButtonLabel setUserInteractionEnabled:NO];
    [button addSubview:facebookButtonLabel];
    
    return button;
}


+ (UIButton *)simbiButtonWithFrame:(CGRect)frame color:(UIColor *)color
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setBackgroundColor:color];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont simbiBoldFontWithSize:18.f]];
    [button.layer setCornerRadius:10.f];
    return button;
}


@end
