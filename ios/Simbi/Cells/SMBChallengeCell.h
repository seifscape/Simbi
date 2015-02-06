//
//  SMBChallengeCell.h
//  Simbi
//
//  Created by flynn on 6/2/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBChatCircleTimerView;
@class SMBChallenge;
@class SMBImageView;


@interface SMBChallengeCell : UITableViewCell

+ (CGFloat)cellHeight;
- (id)initWithChat:(SMBChat *)chat;

@property (nonatomic, strong) SMBChatCircleTimerView *timerView;
@property (nonatomic, strong) SMBImageView *profilePictureView;
@property (nonatomic, strong) UILabel *challengeNameLabel;
@property (nonatomic, strong) UILabel *otherUserNameLabel;
@property (nonatomic, strong) UILabel *lastSentLabel;

@end
