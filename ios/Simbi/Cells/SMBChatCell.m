//
//  SMBChatCell.m
//  Simbi
//
//  Created by flynn on 6/2/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChatCell.h"

#import "SMBChatCircleTimerView.h"
#import "SMBImageView.h"
#import "SMBTimerLabel.h"


@interface SMBChatCell ()

@property (nonatomic, strong) SMBChat *chat;

@end


@implementation SMBChatCell

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

        
        CGFloat height = [SMBChatCell cellHeight];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _timerView = [[SMBChatCircleTimerView alloc] initWithFrame:CGRectMake(0, 0, height-28, height-28) chat:_chat];
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
        
        _firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, 12, self.frame.size.width-height*2, 22)];
        [_firstNameLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_firstNameLabel setFont:[UIFont simbiBoldFontWithSize:12.f]];
        [_firstNameLabel setText:[_chat otherUser].name];
        [self addSubview:_firstNameLabel];
        
        _lastMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, height-44, self.frame.size.width-height*2, 44)];
        [_lastMessageLabel setTextColor:[UIColor simbiGrayColor]];
        [_lastMessageLabel setFont:[UIFont simbiLightFontWithSize:16.f]];
        [_lastMessageLabel setText:_chat.lastMessage];
        [self addSubview:_lastMessageLabel];
        
        _lastSentLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, 12, self.frame.size.width-height-44, 22)];
        [_lastSentLabel setTextColor:[UIColor simbiGrayColor]];
        [_lastSentLabel setFont:[UIFont simbiFontWithSize:10.f]];
        [_lastSentLabel setText:[_chat.dateLastMessageSent relativeDateString]];
        [_lastSentLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_lastSentLabel];
        
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(44, height-0.66f, self.frame.size.width-88, 0.66f)];
        [bottomLine setBackgroundColor:[UIColor simbiGrayColor]];
        [self.contentView addSubview:bottomLine];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchChat:) name:kSMBNotificationWillEnterForeground object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell:) name:kSMBNotificationMessageReceived object:nil];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)fetchChat:(NSNotification *)notification
{
    [_chat fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (object)
        {            
            [_lastMessageLabel setText:_chat.lastMessage];
            //[_isUnreadView setHidden:[_chat currentUserHasReadChat]];
        }
    }];
}


- (void)updateCell:(NSNotification *)notification
{
    if ([notification.userInfo[@"chatId"] isEqualToString:_chat.objectId])
    {
        [_chat fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (object)
            {
                [_lastMessageLabel setText:_chat.lastMessage];
                //[_isUnreadView setHidden:[_chat currentUserHasReadChat]];
            }
        }];
    }
}


@end
