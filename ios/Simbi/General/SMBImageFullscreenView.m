//
//  SMBImageFullscreenView.m
//  Simbi
//
//  Created by flynn on 6/17/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBImageFullscreenView.h"


@interface SMBImageFullscreenView ()

@property (nonatomic, strong) SMBImageView *imageView;

@end


@implementation SMBImageFullscreenView

- (id)initWithImage:(SMBImage *)image
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    if (self)
    {
        [self setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.66]];
        
        CGFloat width  = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        
        SMBImageView *imageView = [[SMBImageView alloc] initWithFrame:CGRectMake(width/16.f, (height-7*width/8.f)/2.f, 7*width/8.f, 7*width/8.f) parseImage:image];
        [imageView.layer setCornerRadius:imageView.frame.size.width/2.f];
        [imageView.layer setMasksToBounds:YES];
        [imageView loadInBackground];
        [self addSubview:imageView];
        
        UIButton *tapOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tapOutButton setFrame:CGRectMake(0, 0, width, height)];
        [tapOutButton addTarget:self action:@selector(tapOut:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tapOutButton];
    }
    
    return self;
}


- (void)show
{
    [self setAlpha:0.f];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self setAlpha:1.f];
    }];
}


- (void)tapOut:(UIButton *)button
{
    [self removeFromSuperview];
}


@end
