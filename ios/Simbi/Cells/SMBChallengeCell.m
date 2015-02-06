//
//  SMBChallengeCell.m
//  Simbi
//
//  Created by flynn on 6/2/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChallengeCell.h"

#import "SMBChatCircleTimerView.h"
#import "SMBImageView.h"
#import "SMBTimerLabel.h"


@interface SMBChallengeCell ()

@property (nonatomic, strong) SMBChat *chat;

@end


@implementation SMBChallengeCell

+ (CGFloat)cellHeight
{
    return 66;
}


- (id)initWithChat:(SMBChat *)chat
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if (self)
    {
        _chat = chat;
        
        
        CGFloat height = [SMBChallengeCell cellHeight];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _timerView = [[SMBChatCircleTimerView alloc] initWithFrame:CGRectMake(0, 0, height-28, height-28) chat:chat];
        [_timerView setCenter:CGPointMake(height/2.f, height/2.f)];
        [_timerView setBackgroundColor:[UIColor clearColor]];
        [_timerView.layer setCornerRadius:_timerView.frame.size.width/2.f];
        [_timerView.layer setMasksToBounds:YES];
        [_timerView.layer setBorderColor:[UIColor clearColor].CGColor];
        [_timerView.layer setBorderWidth:.66f];
        [self addSubview:_timerView];
        
        _profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake(0, 0, height-32, height-32)];
        [_profilePictureView setCenter:CGPointMake(height/2.f, height/2.f)];
        [_profilePictureView setBackgroundColor:[UIColor blackColor]];
        [_profilePictureView.layer setMasksToBounds:YES];
        [_profilePictureView.layer setCornerRadius:_profilePictureView.frame.size.width/2.f];
        [_profilePictureView setClipsToBounds:YES];
        
        if ([_chat otherUserHasRevealed] || _chat.forceRevealed)
            [_profilePictureView setParseImage:[_chat otherUser].profilePicture];
        else
            [_profilePictureView setRawImage:[UIImage imageNamed:@"Silhouette.png"]];
        
        [self addSubview:_profilePictureView];
        
        _challengeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, 12, self.frame.size.width-88, 22)];
        [_challengeNameLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_challengeNameLabel setFont:[UIFont simbiFontWithSize:12.f]];
        [_challengeNameLabel setText:_chat.currentChallenge.challengeName];
        if (!_chat.currentChallenge.accepted && [[SMBUser currentUser].objectId isEqualToString:_chat.currentChallenge.fromUser.objectId])
            [_challengeNameLabel setAlpha:0.5f];
        [self addSubview:_challengeNameLabel];
        
        _otherUserNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, height-44, self.frame.size.width-height*2, 44)];
        [_otherUserNameLabel setTextColor:[UIColor simbiGrayColor]];
        [_otherUserNameLabel setFont:[UIFont simbiLightFontWithSize:16.f]];
        [_otherUserNameLabel setText:[NSString stringWithFormat:@"With %@",[_chat.currentChallenge otherUser].name]];
        [self addSubview:_otherUserNameLabel];
        
        _lastSentLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, 12, self.frame.size.width-height-44, 22)];
        [_lastSentLabel setTextColor:[UIColor simbiGrayColor]];
        [_lastSentLabel setFont:[UIFont simbiFontWithSize:10.f]];
        [_lastSentLabel setText:[_chat.dateLastMessageSent relativeDateString]];
        [_lastSentLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_lastSentLabel];
        
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(44, height-0.66f, self.frame.size.width-88, 0.66f)];
        [bottomLine setBackgroundColor:[UIColor simbiGrayColor]];
        [self.contentView addSubview:bottomLine];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
