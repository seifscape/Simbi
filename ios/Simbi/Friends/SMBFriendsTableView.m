//
//  SMBFriendsTableView.m
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendsTableView.h"

#import "SMBFacebookFriendsViewController.h"
#import "SMBFriendsManager.h"
#import "_SMBFriendsListViewController.h"


@interface SMBFriendsTableView ()

@property (nonatomic, strong) UIView *noResultsButtonView;

@end


@implementation SMBFriendsTableView

static NSString *cellIdentifier = @"Cell";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped manager:[SMBFriendsManager sharedManager]];
    
    if (self)
    {
        [self setBackgroundColor:[UIColor simbiWhiteColor]];
        
        [self setNoResultsMessage:@"No Friends... Yet!"];
        [self setErrorMessage:@"Error Loading Friends"];
        
        [self registerClass:[SMBUserCell class] forCellReuseIdentifier:cellIdentifier];
    }
    
    return self;
}


#pragma mark - SMBManagerTableView

- (void)showNoResultsLabel:(BOOL)shouldShow
{
    [super showNoResultsLabel:shouldShow];
    
    if (!_noResultsButtonView)
    {
        _noResultsButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2.f+88, self.frame.size.width, self.frame.size.height/2.f-88)];
        
        UIButton *findFriendsButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, 0, self.frame.size.width-88, 44)];
        [findFriendsButton setTitle:@"Find Friends" forState:UIControlStateNormal];
        [findFriendsButton addTarget:_parent action:@selector(findFriendsAction) forControlEvents:UIControlEventTouchUpInside];
        [_noResultsButtonView addSubview:findFriendsButton];
        
        if ([SMBUser currentUser].facebookId && [SMBUser currentUser].facebookId.length > 0)
        {
            UIButton *facebookFriendsButton = [UIButton simbiFacebookButtonWithFrame:CGRectMake(44, 44+8, self.frame.size.width-88, 44) title:@"Find Facebook Friends"];
            [facebookFriendsButton addTarget:_parent action:@selector(facebookFriendsAction) forControlEvents:UIControlEventTouchUpInside];
            [_noResultsButtonView addSubview:facebookFriendsButton];
        }
        
        [self addSubview:_noResultsButtonView];
    }
    
    [_noResultsButtonView setHidden:!shouldShow];
}


#pragma mark - UITableViewDataSource/Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([SMBUser currentUser].facebookId && [SMBUser currentUser].facebookId.length > 0)
        return 132+8;
    else
        return 88;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.objects && self.objects.count > 0)
    {
        UIView *view = [[UIView alloc] init];
        
        UIButton *findFriendsButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, 22, self.frame.size.width-88, 44)];
        [findFriendsButton setTitle:@"Find More Friends" forState:UIControlStateNormal];
        [findFriendsButton addTarget:_parent action:@selector(findFriendsAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:findFriendsButton];
        
        if ([SMBUser currentUser].facebookId && [SMBUser currentUser].facebookId.length > 0)
        {
            UIButton *facebookFriendsButton = [UIButton simbiFacebookButtonWithFrame:CGRectMake(44, 66+8, self.frame.size.width-88, 44) title:@"Find Facebook Friends"];
            [facebookFriendsButton addTarget:_parent action:@selector(facebookFriendsAction) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:facebookFriendsButton];
        }
        
        return view;
    }
    else
        return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBUser *user = [self.objects objectAtIndex:indexPath.row];
    SMBUserCell *cell = [user userCellForTableView:tableView indexPath:indexPath cellIdentifier:cellIdentifier];
    return cell;
}


@end
