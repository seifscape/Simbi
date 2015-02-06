//
//  JSQMessagesCollectionViewCell+Simbi.h
//  Simbi
//
//  Created by flynn on 6/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "JSQMessagesCollectionViewCell.h"

#import "SMBChatStatusView.h"


@interface JSQMessagesCollectionViewCell (Simbi)

@property (nonatomic, strong) SMBChatStatusView *chatStatusView;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *avatarButton;

@end
