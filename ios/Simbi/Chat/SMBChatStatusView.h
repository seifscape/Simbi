//
//  SMBChatStatusView.h
//  Simbi
//
//  Created by flynn on 6/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "JSQMessages.h"


@class SMBChatStatusView;
@class SMBMessage;

@protocol SMBChatStatusViewDelegate
- (void)chatStatusView:(SMBChatStatusView *)chatStatusView retrySaveForMessage:(id)message callback:(void(^)(BOOL succeeded))callback;
@end


@interface SMBChatStatusView : UIView <UIAlertViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame message:(SMBMessage *)message delegate:(id<SMBChatStatusViewDelegate>)delegate;
- (void)setFrame:(CGRect)frame;

@property (nonatomic, weak) id<SMBChatStatusViewDelegate> chatStatusViewDelegate;
@property (nonatomic) BOOL messageFailed;

@end
