//
//  SMBChatCell.h
//  Simbi
//
//  Created by flynn on 6/2/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBChat;
@class SMBChatCircleTimerView;
@class SMBImageView;


@interface SMBChatCell : UITableViewCell

+ (CGFloat)cellHeight;
- (id)initWithChat:(SMBChat *)chat;

@property (nonatomic, strong) SMBChatCircleTimerView *timerView;
@property (nonatomic, strong) SMBImageView *profilePictureView;
@property (nonatomic, strong) UILabel *firstNameLabel;
@property (nonatomic, strong) UILabel *lastMessageLabel;
@property (nonatomic, strong) UILabel *lastSentLabel;

@end
