//
//  JSQMessagesCollectionViewCell+Simbi.m
//  Simbi
//
//  Created by flynn on 6/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "JSQMessagesCollectionViewCell+Simbi.h"

#import <objc/runtime.h>

@implementation JSQMessagesCollectionViewCell (Simbi)

// I CANNOT easily figure out how to make these cells selectable. So, add two buttons and a view
// for each cell that we can swap out in cellForItem...

// If you want to murder me I sit in the corner.

#pragma mark - spookyaction

static const void * ERROR_VIEW_KEY;

@dynamic chatStatusView;

- (void)setChatStatusView:(SMBChatStatusView *)chatStatusView
{
    objc_setAssociatedObject(self, &ERROR_VIEW_KEY, chatStatusView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (SMBChatStatusView *)chatStatusView
{
    return objc_getAssociatedObject(self, &ERROR_VIEW_KEY);
}


static const void * SELECT_BUTTON_KEY;

@dynamic selectButton;

- (void)setSelectButton:(UIButton *)selectButton
{
    objc_setAssociatedObject(self, &SELECT_BUTTON_KEY, selectButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (UIButton *)selectButton
{
    return objc_getAssociatedObject(self, &SELECT_BUTTON_KEY);
}


static const void * AVATAR_BUTTON_KEY;

@dynamic avatarButton;

- (void)setAvatarButton:(UIButton *)avatarButton
{
    objc_setAssociatedObject(self, &AVATAR_BUTTON_KEY, avatarButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (UIButton *)avatarButton
{
    return objc_getAssociatedObject(self, &AVATAR_BUTTON_KEY);
}


@end
