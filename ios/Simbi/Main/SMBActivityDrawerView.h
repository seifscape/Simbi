//
//  SMBActivityDrawerView.h
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBActivityTableView.h"
#import "SMBFriendsListTableView.h"


@protocol SMBActivityDrawerDelegate

- (void)activityDrawerDidSelectUser:(SMBUser *)user;
- (void)toggleActivityDrawer;

@end


@class SMBHomeViewController;

@interface SMBActivityDrawerView : UIView <UISearchBarDelegate>

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<SMBActivityDrawerDelegate>)delegate;

@property (nonatomic, strong) UIButton *headerButton;
@property (nonatomic, strong) SMBActivityTableView *activityTableView;
@property (nonatomic, strong) SMBFriendsListTableView *friendsTableView;

@end
