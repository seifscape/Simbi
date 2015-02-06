//
//  SMBChatStatusView.m
//  Simbi
//
//  Created by flynn on 6/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChatStatusView.h"


@interface SMBChatStatusView ()

@property (nonatomic, strong) SMBMessage *message;

@property (nonatomic, strong) UILabel *failedIndicatorView;
@property (nonatomic, strong) UIButton *resendButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end


@implementation SMBChatStatusView

- (instancetype)initWithFrame:(CGRect)frame message:(id)message delegate:(id<SMBChatStatusViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _chatStatusViewDelegate = delegate;
        
        if ([message isKindOfClass:[SMBMessage class]])
        {
            _message = message;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageFailedToSend:) name:kSMBNotificationMessageFailed object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSent:) name:kSMBNotificationMessageSent object:nil];
        }
        
        _messageFailed = NO;
        
        
        _failedIndicatorView = [[UILabel alloc] initWithFrame:CGRectZero];
        [_failedIndicatorView setFrame:CGRectMake(self.frame.size.width-40, 0, 16, 16)];
        [_failedIndicatorView setBackgroundColor:[UIColor simbiRedColor]];
        [_failedIndicatorView setText:@"!"];
        [_failedIndicatorView setTextColor:[UIColor whiteColor]];
        [_failedIndicatorView setFont:[UIFont simbiBoldFontWithSize:14.f]];
        [_failedIndicatorView setTextAlignment:NSTextAlignmentCenter];
        [_failedIndicatorView.layer setCornerRadius:_failedIndicatorView.frame.size.width/2.f];
        [_failedIndicatorView.layer setMasksToBounds:YES];
        [_failedIndicatorView setHidden:YES];
        [self addSubview:_failedIndicatorView];
        
        _resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resendButton setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [_resendButton addTarget:self action:@selector(promptResendAction:) forControlEvents:UIControlEventTouchUpInside];
        [_resendButton setHidden:YES];
        [self addSubview:_resendButton];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityIndicatorView setFrame:_failedIndicatorView.frame];
        
        if (_message && !_message.objectId && !_message.isAction && [[SMBUser currentUser].objectId isEqualToString:_message.fromUser.objectId])
        {
            [_activityIndicatorView startAnimating];
            [self addSubview:_activityIndicatorView];
        }
        
        [self setUserInteractionEnabled:NO];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [_failedIndicatorView setFrame:CGRectMake(self.frame.size.width-40, 0, 16, 16)];
    [_resendButton setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_activityIndicatorView setFrame:_failedIndicatorView.frame];
}


#pragma mark - Notification Handling

- (void)messageFailedToSend:(NSNotification *)notification
{
    if (notification.userInfo[@"message"] == _message)
    {
        _messageFailed = YES;
        
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
        
        [_failedIndicatorView setHidden:NO];
        [_resendButton setHidden:NO];
        
        [self setUserInteractionEnabled:YES];
    }
}


- (void)messageSent:(NSNotification *)notification
{
    if (notification.userInfo[@"message"] == _message)
    {
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
    }
}


#pragma mark - User Actions

- (void)promptResendAction:(UIButton *)button
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Resend Message" message:@"This message failed to send. Try again?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
    [alertView show];
}


- (void)resendAction
{
    [self setUserInteractionEnabled:NO];
    
    [_failedIndicatorView setHidden:YES];
    [_resendButton setHidden:YES];
    
    [_activityIndicatorView startAnimating];
    [self addSubview:_activityIndicatorView];
    
    [_chatStatusViewDelegate chatStatusView:self retrySaveForMessage:_message callback:^(BOOL succeeded) {
        
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
        
        if (succeeded)
        {
            _messageFailed = NO;
        }
        else
        {
            _messageFailed = YES;
            
            [_failedIndicatorView setHidden:NO];
            [_resendButton setHidden:NO];
            
            [self setUserInteractionEnabled:YES];
        }
    }];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
        [self resendAction];
}


@end
