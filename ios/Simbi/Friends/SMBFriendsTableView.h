//
//  SMBFriendsTableView.h
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBManager.h"
#import "SMBManagerTableView.h"


@class _SMBFriendsListViewController;

@interface SMBFriendsTableView : SMBManagerTableView

@property (nonatomic, weak) _SMBFriendsListViewController *parent;

@end
