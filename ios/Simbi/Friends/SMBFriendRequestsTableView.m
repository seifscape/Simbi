//
//  SMBFriendRequestsTableView.m
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendRequestsTableView.h"

#import "SMBFriendRequestsManager.h"
#import "_SMBFriendsListViewController.h"


@implementation SMBFriendRequestsTableView

static NSString *cellIdentifier = @"Cell";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped manager:[SMBFriendRequestsManager sharedManager]];
    
    if (self)
    {
        [self setBackgroundColor:[UIColor simbiWhiteColor]];
        
        [self setNoResultsMessage:@"No Requests"];
        [self setErrorMessage:@"Error Loading Requests"];
        
        [self registerClass:[SMBFriendRequestCell class] forCellReuseIdentifier:cellIdentifier];
    }
    
    return self;
}


#pragma mark - SMBManagerTableView

- (void)manager:(SMBManager *)manager didUpdateObjects:(NSArray *)objects
{
    [super manager:manager didUpdateObjects:objects];
    
    [_parent updateRequestCountWithNumber:objects.count];
}


- (void)manager:(SMBManager *)manager didFailToLoadObjects:(NSError *)error
{
    [super manager:manager didFailToLoadObjects:error];
    
    [_parent updateRequestCountWithNumber:0];
}


#pragma mark - UITableViewDataSource/Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBFriendRequest *request = [self.objects objectAtIndex:indexPath.row];
    SMBFriendRequestCell *cell = [request requestCellForTableView:tableView indexPath:indexPath cellIdentifier:cellIdentifier];
    return cell;
}


@end
