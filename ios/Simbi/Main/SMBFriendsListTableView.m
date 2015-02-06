//
//  SMBFriendsTableView.m
//  Simbi
//
//  Created by flynn on 8/29/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendsListTableView.h"

#import "SMBActivityDrawerView.h"
#import "SMBFriendsListCell.h"
#import "SMBFriendsManager.h"


@interface SMBFriendsListTableView ()

@property (nonatomic, strong) NSMutableArray *filteredUsers;

@end


@implementation SMBFriendsListTableView

static NSString *CellIdentifier = @"Friends";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped manager:[SMBFriendsManager sharedManager]];
    
    if (self)
    {
        [self setBackgroundColor:[UIColor simbiWhiteColor]];
        [self setSeparatorColor:[UIColor clearColor]];
        
        if ([SMBFriendsManager sharedManager].objects.count > 0)
            _filteredUsers = [NSMutableArray arrayWithArray:[SMBFriendsManager sharedManager].objects];
        else
            _filteredUsers = [NSMutableArray new];
        
        
        [self registerClass:[SMBFriendsListCell class] forCellReuseIdentifier:CellIdentifier];
    }
    
    return self;
}


- (void)filterUsers:(NSString *)string
{
    if (string && string.length > 0)
    {
        _filteredUsers = [NSMutableArray new];
        
        for (SMBUser *user in self.objects)
            if ([user.name.lowercaseString rangeOfString:string.lowercaseString].location != NSNotFound)
                [_filteredUsers addObject:user];
    }
    else
    {
        _filteredUsers = [NSMutableArray arrayWithArray:self.objects];
    }
    
    [self reloadData];
}


#pragma mark - UITableViewDataSource/Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SMBFriendsListCell cellHeight];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filteredUsers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBFriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SMBFriendsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    SMBUser *user = [_filteredUsers objectAtIndex:indexPath.row];
    
    [cell.profilePictureView setParseImage:user.profilePicture withType:kImageTypeThumbnail];
    [cell.nameLabel setText:user.name];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_activityDelegate)
    {
        SMBUser *user = [_filteredUsers objectAtIndex:indexPath.row];
        [_activityDelegate activityDrawerDidSelectUser:user];
    }
}


#pragma mark - SMBManagerDelegate

- (void)manager:(SMBManager *)manager didUpdateObjects:(NSArray *)objects
{
    [super manager:manager didUpdateObjects:objects];
    
    [self filterUsers:@""];
}


- (void)manager:(SMBManager *)manager didFailToLoadObjects:(NSError *)error
{
    [super manager:manager didFailToLoadObjects:error];
    
    [self filterUsers:@""];
}


@end
