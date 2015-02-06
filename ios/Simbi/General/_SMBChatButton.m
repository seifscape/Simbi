//
//  SMBChatButton.m
//  Simbi
//
//  Created by flynn on 5/29/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBChatButton.h"

#import "SMBAppDelegate.h"


@interface _SMBChatButton ()

@property (nonatomic, strong) UIButton *responseButton;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, strong) UILabel *notificationLabel;

@property (nonatomic) CGRect notificationHiddenFrame;
@property (nonatomic) CGRect notificationNormalFrame;
@property (nonatomic) CGRect notificationWideFrame;

@end


@implementation _SMBChatButton

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super init];
    
    if (self)
    {
        _notificationHiddenFrame = CGRectMake(2+13/2.f, 13+13/2.f, 0, 0);
        _notificationNormalFrame = CGRectMake(2, 13, 13, 13);
        _notificationWideFrame   = CGRectMake(0, 13, 17, 13);
        
        
        _buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 44-16, 44-16)];
        [imageView setImage:[UIImage imageNamed:@"Chat_Icon.png"]];
        [_buttonView addSubview:imageView];
        
        if ([SMBUser currentUser].hasNewMessage || [[SMBAppDelegate instance] isAtHomeOrChat])
        {
            if ([SMBUser currentUser].unreadMessageCount.intValue < 10)
                _notificationView = [[UIView alloc] initWithFrame:_notificationNormalFrame];
            else
                _notificationView = [[UIView alloc] initWithFrame:_notificationWideFrame];
        }
        else
            _notificationView = [[UIView alloc] initWithFrame:_notificationHiddenFrame];
        [_notificationView setBackgroundColor:[UIColor simbiRedColor]];
        [_notificationView.layer setCornerRadius:_notificationView.frame.size.height/2.f];
        [_notificationView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_notificationView.layer setBorderWidth:0.5f];
        [_notificationView.layer setMasksToBounds:YES];
        [_buttonView addSubview:_notificationView];
        
        _notificationLabel = [[UILabel alloc] initWithFrame:_notificationWideFrame];
        if ([SMBUser currentUser].unreadMessageCount.intValue > 0)
            [_notificationLabel setText:[SMBUser currentUser].unreadMessageCount.stringValue];
        else
            [_notificationLabel setAlpha:0.f];
        [_notificationLabel setTextColor:[UIColor whiteColor]];
        [_notificationLabel setFont:[UIFont simbiBoldFontWithSize:9.f]];
        [_notificationLabel setTextAlignment:NSTextAlignmentCenter];
        [_buttonView addSubview:_notificationLabel];
        
        _responseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_responseButton setFrame:CGRectMake(2, 2, 40, 40)];
        [_responseButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:_responseButton];
        
        [self setCustomView:_buttonView];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showChatNotification:) name:kSMBNotificationShowChatIcon object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideChatNotification:) name:kSMBNotificationHideChatIcon object:nil];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)showChatNotification:(NSNotification *)notification
{
    if (![[SMBAppDelegate instance] isAtHomeOrChat])
    {
        [_notificationLabel setText:[SMBUser currentUser].unreadMessageCount.stringValue];
        
        if (_notificationLabel.text.length > 2)
            [_notificationLabel setText:@"99+"];
        
        [self animateNotificationViewIn];
    }
}


- (void)hideChatNotification:(NSNotification *)notification
{
    [_notificationLabel setText:[SMBUser currentUser].unreadMessageCount.stringValue];
    
    if (_notificationLabel.text.length > 2)
        [_notificationLabel setText:@"99+"];
    
    [self animateNotificationViewOut];
}


- (void)animateNotificationViewIn
{
    [UIView animateWithDuration:0.33f
                     animations:^{
                         if (_notificationLabel.text.length > 1)
                             [_notificationView setFrame:_notificationWideFrame];
                         else
                             [_notificationView setFrame:_notificationNormalFrame];
                         [_notificationView.layer setCornerRadius:_notificationView.frame.size.height/2.f];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.33f
                                          animations:^{
                                              [_notificationLabel setAlpha:1.f];
                                          }];
                     }
    ];
}


- (void)animateNotificationViewOut
{
    [UIView animateWithDuration:0.33f
                     animations:^{
                         [_notificationLabel setAlpha:0.f];
                         
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.33f
                                          animations:^{
                                              [_notificationView setFrame:_notificationHiddenFrame];
                                          }];
                     }
    ];
}


@end
