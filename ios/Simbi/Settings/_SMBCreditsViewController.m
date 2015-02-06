//
//  SMBCreditsViewController.m
//  Simbi
//
//  Created by flynn on 6/26/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBCreditsViewController.h"


@interface _SMBCreditsViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation _SMBCreditsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setTitle:@"Credits"];
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, (height-20-44)/2.f+20+44, width-40, (height-20-44)/2.f)];
    [_imageView setImage:[UIImage imageNamed:@"leprechaun"]];
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_imageView];
    
    [self animateUp];
}


- (void)animateUp
{
    __weak _SMBCreditsViewController *_self = self;
    
    [UIView animateWithDuration:0.33f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_imageView setFrame:CGRectMake(20, 20+44, _imageView.frame.size.width, _imageView.frame.size.height)];
                     } completion:^(BOOL finished) {
                         if (_self)
                             [_self animateDown];
                     }];
}


- (void)animateDown
{
    __weak _SMBCreditsViewController *_self = self;
    
    CGFloat height = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.33f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [_imageView setFrame:CGRectMake(20, (height-20-44)/2.f+20+44, _imageView.frame.size.width, _imageView.frame.size.height)];
                     } completion:^(BOOL finished) {
                         if (_self)
                             [_self animateUp];
                     }];
}


@end
