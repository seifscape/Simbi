//
//  SMBSideMenuViewController.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBSideMenuViewController.h"

#import "SMBAppDelegate.h"
#import "SMBChatListViewController.h"
#import "_SMBFriendsListViewController.h"
#import "SMBSelectChallengeViewController.h"
#import "SMBSettingsViewController.h"
#import "_SMBCreditsViewController.h"
#import "SMBImageView.h"
#import "SMBPreferencesViewController.h"

#import "Simbi-Swift.h"


@interface SMBSideMenuViewController ()

@property (nonatomic, strong) SMBImageView *profilePictureView;
@property (nonatomic, strong) UILabel *nameLabel;

@end


@implementation SMBSideMenuViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor simbiBlackColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setScrollEnabled:NO];
    
    
    // Create header
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 66+20)];
    [headerView setBackgroundColor:[UIColor simbiBlackColor]];
    
    _profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake(11, 20+7, 52, 52)];
    [_profilePictureView setBackgroundColor:[UIColor simbiGrayColor]];
    [_profilePictureView.layer setCornerRadius:_profilePictureView.frame.size.width/2.f];
    [_profilePictureView.layer setMasksToBounds:YES];
    [_profilePictureView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_profilePictureView.layer setBorderWidth:1.f];
    [headerView addSubview:_profilePictureView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 20, self.view.frame.size.width-52, 66)];
    [_nameLabel setTextColor:[UIColor whiteColor]];
    [_nameLabel setFont:[UIFont simbiFontWithAttributes:kFontRegular size:18.f]];
    [headerView addSubview:_nameLabel];
    
    [self.tableView setTableHeaderView:headerView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([SMBUser exists])
    {
        [_profilePictureView setParseImage:[SMBUser currentUser].profilePicture withType:kImageTypeThumbnail];
        [_nameLabel setText:[SMBUser currentUser].name];
    }
}


#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [UIScreen mainScreen].bounds.size.height > 480.f ? 44 : 11;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setBackgroundColor:[UIColor simbiBlackColor]];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 17, 32, 32)];
    [cell.contentView addSubview:iconImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(66, 0, cell.frame.size.width-44, 66)];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont simbiFontWithAttributes:kFontRegular size:20.f]];
    [cell.contentView addSubview:label];
    
    switch (indexPath.row)
    {
        case 0:
            [iconImageView setImage:[UIImage imageNamed:@"homecircleicon"]];
            [label setText:@"Home"];
            break;
        case 1:
            [iconImageView setImage:[UIImage imageNamed:@"friendsicon"]];
            [label setText:@"Friends"];
            break;
        case 2:
            [iconImageView setImage:[UIImage imageNamed:@"gamesicon"]];
            [label setText:@"Games"];
            break;
//        case 3:
//            [iconImageView setImage:[UIImage imageNamed:@"creditsicon"]];
//            [label setText:@"Credits"];
//            break;
        case 3:
            [iconImageView setImage:[UIImage imageNamed:@"settingsicon"]];
            [label setText:@"Settings"];
            break;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id viewController;
    
    switch (indexPath.row)
    {
        case 0: viewController = [[SMBMainViewController alloc] init];              break;
        case 1: viewController = [[SMBFriendsListViewController alloc] init];       break;
        case 2: viewController = [[SMBSelectChallengeViewController alloc] init];   break;
//        case 3: viewController = [[SMBCreditsViewController alloc] init];           break;
        case 3: viewController = [[SMBSettingsViewController alloc] init];          break;
    }
    
    if (viewController)
        [[SMBAppDelegate instance] setCenterViewController:viewController];
}


@end
