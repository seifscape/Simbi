//
//  SMBFriendRequest.h
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>

#import "SMBFriendRequestCell.h"


@class SMBUser;


@interface SMBFriendRequest : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

- (SMBFriendRequestCell *)requestCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cellIdentifier:(NSString *)cellIdentifier;

@property (retain) SMBUser *toUser;
@property (retain) SMBUser *fromUser;
@property (retain) NSString *status;
@property BOOL isAccepted;

@end
