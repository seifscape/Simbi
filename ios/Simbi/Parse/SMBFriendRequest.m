//
//  SMBFriendRequest.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendRequest.h"

@implementation SMBFriendRequest

@dynamic toUser;
@dynamic fromUser;
@dynamic status;
@dynamic isAccepted;

+ (NSString *)parseClassName
{
    return @"FriendRequest";
}


- (SMBFriendRequestCell *)requestCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cellIdentifier:(NSString *)cellIdentifier
{
    SMBFriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell)
        cell = [[SMBFriendRequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    [cell.profilePictureView setParseImage:self.fromUser.profilePicture];
    [cell.messageLabel setText:[NSString stringWithFormat:@"%@ wants to be your friend!", self.fromUser.name]];
    
    return cell;
}

@end
