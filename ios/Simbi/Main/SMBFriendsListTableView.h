//
//  SMBFriendsTableView.h
//  Simbi
//
//  Created by flynn on 8/29/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBManagerTableView.h"


@protocol SMBActivityDrawerDelegate;

@interface SMBFriendsListTableView : SMBManagerTableView

@property (nonatomic, weak) id<SMBActivityDrawerDelegate> activityDelegate;

- (void)filterUsers:(NSString *)string;

@end