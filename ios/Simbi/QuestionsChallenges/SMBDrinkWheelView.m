//
//  SMBDrinkWheelView.m
//  Simbi
//
//  Created by flynn on 6/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBDrinkWheelView.h"


@interface SMBDrinkWheelView ()

@property (nonatomic, strong) UIImageView *wheelView;
@property (nonatomic, strong) UIView *pinContainerView;
@property (nonatomic, strong) UIImageView *pinView;

@property (nonatomic) CGFloat angle;

@end


@implementation SMBDrinkWheelView

typedef enum SMBDirection : NSInteger
{
    kSMBDirectionLeft,
    kSMBDirectionRight
} SMBDirection;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _wheelView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wheel_temp"]];
        [_wheelView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_wheelView setContentMode:UIViewContentModeScaleAspectFit];
        [_wheelView.layer setCornerRadius:self.frame.size.width/2.f];
        [_wheelView.layer setMasksToBounds:YES];
        [self addSubview:_wheelView];
        
        _pinContainerView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width-44)/2.f, -44, 44, 66)];
        
        _pinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_temp"]];
        [_pinView setFrame:CGRectMake(0, 22, 44, 44)];
        [_pinView setContentMode:UIViewContentModeScaleAspectFit];
        [_pinView setUserInteractionEnabled:NO];
        [_pinContainerView addSubview:_pinView];
        
        [self addSubview:_pinContainerView];
        
        
        _angle = 0.f;
        
        
        UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(spinRightAction:)];
        [swipeRightGesture setDelegate:self];
        [swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:swipeRightGesture];
        
        UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(spinLeftAction:)];
        [swipeLeftGesture setDelegate:self];
        [swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:swipeLeftGesture];
    }
    
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (touch.view == self || [self.subviews containsObject:touch.view])
        return YES;
    else
        return NO;
}


#pragma mark - Public Methods

- (void)spin
{
    [self spinWheelNumberOfTimes:24+arc4random()%8
                 currentRotation:0
                       direction:kSMBDirectionRight
                          easeIn:YES
                  rotationAmount:(arc4random()%1000)/1000.f*M_PI_4 + M_PI_4];
}


#pragma mark - User Actions

- (void)spinRightAction:(UISwipeGestureRecognizer *)swipeGesture
{
    [self spinWheelNumberOfTimes:24+arc4random()%8
                 currentRotation:0
                       direction:kSMBDirectionRight
                          easeIn:NO
                  rotationAmount:(arc4random()%1000)/1000.f*M_PI_4 + M_PI_4];
}


- (void)spinLeftAction:(UISwipeGestureRecognizer *)swipeGesture
{
    [self spinWheelNumberOfTimes:24+arc4random()%8
                 currentRotation:0
                       direction:kSMBDirectionLeft
                          easeIn:NO
                  rotationAmount:(arc4random()%1000)/1000.f*M_PI_4 + M_PI_4];
}


#pragma mark - Spin Methods

- (void)spinWheelNumberOfTimes:(NSInteger)numberOfTimes currentRotation:(NSInteger)currentRotation direction:(SMBDirection)direction easeIn:(BOOL)easeIn rotationAmount:(CGFloat)rotationAmount
{
    UIViewAnimationOptions animationOptions;
    
    if (currentRotation == 0)
        animationOptions = UIViewAnimationOptionCurveEaseIn;
    else if (currentRotation == numberOfTimes)
        animationOptions = UIViewAnimationOptionCurveEaseOut;
    else
        animationOptions = UIViewAnimationOptionCurveLinear;
    
    
    if (direction == kSMBDirectionRight)
        _angle += rotationAmount;
    else
        _angle -= rotationAmount;
    
    
    NSTimeInterval duration;
    
    if (easeIn)
        duration = ( abs( currentRotation-(numberOfTimes/2.f)) / (float)numberOfTimes/2.f ) / 1.25f;
    else
        duration = ( (currentRotation+1) / (float)(numberOfTimes+1) ) / 1.25f;
    
    [UIView animateWithDuration:duration
                          delay:0.f
                        options:animationOptions
                     animations:^{
                         [_wheelView setTransform:CGAffineTransformMakeRotation(_angle)];
                     }
                     completion:^(BOOL finished) {
                         
                         if (currentRotation < numberOfTimes)
                             [self spinWheelNumberOfTimes:numberOfTimes currentRotation:currentRotation+1 direction:direction easeIn:easeIn rotationAmount:rotationAmount];
                         else
                             [self wheelFinishedSpinning];
                     }];
    
    [_pinContainerView setTransform:CGAffineTransformMakeRotation(0)];
    
    [UIView animateWithDuration:duration animations:^{
        [_pinContainerView setTransform:CGAffineTransformMakeRotation(-M_PI_4/2.f)];
    }];
}


- (void)wheelFinishedSpinning
{
    [UIView animateWithDuration:0.125f animations:^{
        [_pinContainerView setTransform:CGAffineTransformMakeRotation(0)];
    }];
    
    while (_angle >= 2*M_PI)
        _angle -= 2*M_PI;
    
    NSString *drink;
    
    if      (             0 <= _angle && _angle < M_PI_4        ) drink = @"beer";
    else if (        M_PI_4 <= _angle && _angle < M_PI_2        ) drink = @"martini";
    else if (        M_PI_2 <= _angle && _angle < 3*M_PI_4      ) drink = @"margarita";
    else if (      3*M_PI_4 <= _angle && _angle < M_PI          ) drink = @"cocktail";
    else if (          M_PI <= _angle && _angle < M_PI+M_PI_4   ) drink = @"lager";
    else if (   M_PI+M_PI_4 <= _angle && _angle < M_PI+M_PI_2   ) drink = @"whiskey";
    else if (   M_PI+M_PI_2 <= _angle && _angle < M_PI+3*M_PI_4 ) drink = @"water";
    else if ( M_PI+3*M_PI_4 <= _angle && _angle < 2*M_PI        ) drink = @"something fruity";
    else                                                          drink = @"nothing";
    
    [_delegate drinkWheelView:self didStopAtDrink:drink];
}


@end
