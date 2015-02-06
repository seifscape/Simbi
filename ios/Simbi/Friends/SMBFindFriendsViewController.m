//
//  SMBFindFriendsViewController.m
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFindFriendsViewController.h"

#import "_SMBChatButton.h"
#import "SMBChatListViewController.h"
#import "SMBUserDetailViewController.h"


@interface SMBFindFriendsViewController ()

@property (nonatomic, strong) NSArray *objects;

@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSTimer *currentSearchTimer;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) UILabel *noResultsLabel;

@end


@implementation SMBFindFriendsViewController

static NSString *cellIdentifier = @"Cell";

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:[[_SMBChatButton alloc] initWithTarget:self action:@selector(chatAction)]];
    
    [self.navigationItem setTitle:@"Find Friends"];
    [self.tableView setBackgroundColor:[UIColor simbiWhiteColor]];
    
    [self.tableView registerClass:[SMBUserCell class] forCellReuseIdentifier:cellIdentifier];
    
    
    // Create views
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 88)];

    UIView *textFieldBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 22, self.view.frame.size.width, 44)];
    [textFieldBackgroundView setBackgroundColor:[UIColor whiteColor]];
    [headerView addSubview:textFieldBackgroundView];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(16, 22, self.view.frame.size.width-16-44, 44)];
    [textField setDelegate:self];
    [textField setFont:[UIFont simbiLightFontWithSize:18.f]];
    [textField setPlaceholder:@"Search by name or email"];
    [headerView addSubview:textField];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityIndicatorView setFrame:CGRectMake(self.view.frame.size.width-44, 22, 44, 44)];
    [headerView addSubview:_activityIndicatorView];
    
    [self.tableView setTableHeaderView:headerView];
    
    
    _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 88, self.view.frame.size.width, 88)];
    [_noResultsLabel setText:@"No Results!"];
    [_noResultsLabel setTextColor:[UIColor simbiDarkGrayColor]];
    [_noResultsLabel setFont:[UIFont simbiLightFontWithSize:22.f]];
    [_noResultsLabel setTextAlignment:NSTextAlignmentCenter];
    [_noResultsLabel setHidden:YES];
    [self.tableView addSubview:_noResultsLabel];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}


- (void)loadObjects
{
    if (_searchTerm.length > 0)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"objectId" notEqualTo:[SMBUser currentUser].objectId];
        [query whereKey:@"searchString" containsString:_searchTerm.lowercaseString];
        [query includeKey:@"profilePicture"];
        [query includeKey:@"hairColor"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            [_activityIndicatorView stopAnimating];
            
            if (objects)
            {
                _objects = objects;
                [self.tableView reloadData];
                
                [_noResultsLabel setHidden:(_objects.count > 0)];
            }
            else
            {
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                [MBProgressHUD showMessage:@"Something went wrong!" parent:self];
            }
        }];
    }
    else
    {
        [_activityIndicatorView stopAnimating];
    }
}


#pragma mark - User Actions

- (void)chatAction
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
    if (_objects && _objects.count > 0)
        return self.objects.count;
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBUser *user = [_objects objectAtIndex:indexPath.row];
    SMBUserCell *cell = [user userCellForTableView:tableView indexPath:indexPath cellIdentifier:cellIdentifier];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SMBUser *user = [_objects objectAtIndex:indexPath.row];
    
    SMBUserDetailViewController *viewController = [[SMBUserDetailViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [_activityIndicatorView startAnimating];
    [_noResultsLabel setHidden:YES];
    
    _objects = nil;
    [self.tableView reloadData];
    
    _searchTerm = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_currentSearchTimer)
        [_currentSearchTimer invalidate];
    
    _currentSearchTimer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(reloadObjectsForSearchTerm) userInfo:nil repeats:NO];
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)reloadObjectsForSearchTerm
{    
    if (_currentSearchTimer)
        [_currentSearchTimer invalidate];
    
    [self loadObjects];
}


@end
