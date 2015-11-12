//
//  SMBFacebookFriendsViewController.m
//  Simbi
//
//  Created by flynn on 6/17/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFacebookFriendsViewController.h"

#import "MBProgressHUD.h"

#import "SMBAppDelegate.h"
#import "_SMBChatButton.h"
#import "SMBChatListViewController.h"
#import "SMBUserDetailViewController.h"

@interface SMBFacebookFriendsViewController ()

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSMutableArray *selectedUsers;

@property (nonatomic) BOOL isSignUp;

@property (nonatomic, strong) UILabel *noResultsLabel;

@end


@implementation SMBFacebookFriendsViewController

static NSString *CellIdentifier = @"Cell";

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self)
    {
        _isSignUp = NO;
        _users = nil;
    }
    
    return self;
}


- (id)initWithUsers:(NSArray *)users isSignUp:(BOOL)isSignUp
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self)
    {
        _isSignUp = isSignUp;
        _users = users;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_isSignUp)
        [self.navigationItem setHidesBackButton:YES];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.tableView setBackgroundColor:[UIColor simbiWhiteColor]];
    
    if (_isSignUp)
    {
        UIBarButtonItem *selectAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllAction:)];
        [self.navigationItem setLeftBarButtonItem:selectAllButton];
    
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Don't Send Requests" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
        [self.navigationItem setRightBarButtonItem:doneButton];
    }
    else
    {
        [self.navigationItem setTitle:@"Facebook Friends"];
        
        [self.navigationItem setRightBarButtonItem:[[_SMBChatButton alloc] initWithTarget:self action:@selector(chatAction:)]];
    }
    
    
    _selectedUsers = [NSMutableArray new];
    
    if (_isSignUp)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 66)];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-40, 66)];
        [headerLabel setText:@"Your Facebook friends are on Simbi! Want to send them an invite?"];
        [headerLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [headerLabel setFont:[UIFont simbiFontWithSize:16.f]];
        [headerLabel setTextAlignment:NSTextAlignmentCenter];
        [headerLabel setNumberOfLines:2];
        [headerView addSubview:headerLabel];
        
        [self.tableView setTableHeaderView:headerView];
    }
    
    
    if (!_users)
    {
        [self loadUsers];
    }
    
    
    [self.tableView registerClass:[SMBUserCell class] forCellReuseIdentifier:CellIdentifier];
}


- (void)loadUsers
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    [activityIndicatorView startAnimating];
    [self.tableView addSubview:activityIndicatorView];
    
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends"
                                                                   parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        // TODO: handle results or error of request.
        if (!error)
        {
            NSArray *friends = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray new];
            
            for (NSDictionary *friend in friends)
                [friendIds addObject:friend[@"id"]];
            
            // Query for any users that match those IDs
            
            PFQuery *query = [PFQuery queryWithClassName:@"_User"];
            [query whereKey:@"facebookId" containedIn:friendIds];
            [query includeKey:@"profilePicture"];
            [query includeKey:@"hairColor"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                [activityIndicatorView stopAnimating];
                [activityIndicatorView removeFromSuperview];
                
                if (objects)
                {
                    [self showNoResultsLabel:(objects.count == 0)];
                    _users = objects;
                    [self.tableView reloadData];
                }
                else
                {
                    [self showNoResultsLabel:YES];
                    NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                }
            }];
        }
        else
        {
            [self showNoResultsLabel:YES];
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [activityIndicatorView stopAnimating];
            [activityIndicatorView removeFromSuperview];
        }
        
    }];
}


- (void)showNoResultsLabel:(BOOL)shouldShow
{
    if (!_noResultsLabel)
    {
        _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height-20-44)];
        [_noResultsLabel setText:@"No Friends Found!"];
        [_noResultsLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_noResultsLabel setFont:[UIFont simbiLightFontWithSize:22.f]];
        [_noResultsLabel setTextAlignment:NSTextAlignmentCenter];
        [self.tableView addSubview:_noResultsLabel];
    }
    
    [_noResultsLabel setHidden:!shouldShow];
}


#pragma mark - User Actions

- (void)doneAction:(UIBarButtonItem *)button
{
    if (_selectedUsers.count > 0)
    {
        MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Sending..." parent:self];
        
        NSMutableArray *selectedUserIds = [NSMutableArray new];
        
        for (SMBUser *user in _selectedUsers)
            [selectedUserIds addObject:user.objectId];
        
        NSDictionary *params = @{@"userIds": selectedUserIds };
        
        [PFCloud callFunctionInBackground:@"sendBatchFriendRequests" withParameters:params block:^(id object, NSError *error) {
            
            if (object)
            {
                [hud dismissQuickly];
                [[SMBAppDelegate instance] animateToMain];
            }
            else
            {
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                [hud dismissWithError];
            }
        }];
    }
    else if (_isSignUp)
    {
        [[SMBAppDelegate instance] animateToMain];
    }
}


- (void)selectAllAction:(UIBarButtonItem *)button
{
    _selectedUsers = [NSMutableArray arrayWithArray:_users];
    [self.tableView reloadData];
}


- (void)chatAction:(_SMBChatButton *)chatButton
{
    SMBChatListViewController *viewController = [[SMBChatListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_users)
        return _users.count;
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBUser *user = [_users objectAtIndex:indexPath.row];
    SMBUserCell *cell = [user userCellForTableView:tableView indexPath:indexPath cellIdentifier:CellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if ([_selectedUsers containsObject:user])
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SMBUser *user = [_users objectAtIndex:indexPath.row];
 
    if (_isSignUp)
    {
        if ([_selectedUsers containsObject:user])
        {
            [_selectedUsers removeObject:user];
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
        }
        else
        {
            [_selectedUsers addObject:user];
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        }

        if (_selectedUsers.count == 0)
            [self.navigationItem.rightBarButtonItem setTitle:@"Don't Send Requests"];
        else if (_selectedUsers.count == 1)
            [self.navigationItem.rightBarButtonItem setTitle:@"Send Friend Request"];
        else
            [self.navigationItem.rightBarButtonItem setTitle:@"Send Friend Requests"];
    }
    else
    {
        SMBUserDetailViewController *viewController = [[SMBUserDetailViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


@end
