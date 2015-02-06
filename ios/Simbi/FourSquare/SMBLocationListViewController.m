//
//  SMBLocationListViewController.m
//  Simbi
//
//  Created by flynn on 7/25/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBLocationListViewController.h"

#import "SMBFourSquareLocation.h"
#import "SMBLocationCell.h"


@interface SMBLocationListViewController ()

@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSArray *locations;

@property (nonatomic, strong) SMBFourSquareLocation *selectedLocation;

@end


@implementation SMBLocationListViewController

static NSString *kCellIdentifier = @"Cell";

- (instancetype)initWithCategory:(NSString *)category locations:(NSArray *)locations
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self)
    {
        _category  = category;
        _locations = locations;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self setTitle:_category];
    
    [self.tableView setBackgroundColor:[UIColor simbiWhiteColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    [self.tableView registerClass:[SMBLocationCell class] forCellReuseIdentifier:kCellIdentifier];
}


#pragma mark - User Actions

- (void)saveUserWithLocation
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Checking In..." parent:self];
    
    SMBLocation *parseLocation = [[SMBLocation alloc] init];
    [parseLocation setLocationName:_selectedLocation.name];
    [parseLocation setGeoPoint:_selectedLocation.geoPoint];
    
    [[SMBUser currentUser] setCity:_selectedLocation.city];
    [[SMBUser currentUser] setState:_selectedLocation.state];
    [[SMBUser currentUser] setLocation:parseLocation];
    [[SMBUser currentUser] setGeoPoint:_selectedLocation.geoPoint];
    
    SMBActivity *activity = [[SMBActivity alloc] init];
    [activity setUser:[SMBUser currentUser]];
    [activity setUserObjectId:[SMBUser currentUser].objectId];
    [activity setActivityLocation:parseLocation];
    [activity setActivityText:_selectedLocation.name];
    [activity setActivityType:@"CheckIn"];
    
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            PFRelation *activityRelation = [[PFUser currentUser] relationForKey:@"activities"];
            [activityRelation addObject:activity];
            
            [[SMBUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    [hud dismissQuickly];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                    [hud dismissWithError];
                }
            }];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [hud dismissWithError];
        }
    }];
}


#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SMBLocationCell cellHeight];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _locations.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, tableView.frame.size.width, 44)];
    [label setText:@"Nearby Locations"];
    [label setTextColor:[UIColor simbiGrayColor]];
    [label setFont:[UIFont simbiFontWithSize:12.f]];
    [view addSubview:label];
    
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (!cell)
        cell = [[SMBLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    SMBFourSquareLocation *location = [_locations objectAtIndex:indexPath.row];
    
    [cell.titleLabel setText:location.name];
    [cell.detailLabel setText:location.city];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedLocation = [_locations objectAtIndex:indexPath.row];
    
    NSString *title = @"Pin Location";
    NSString *message = [NSString stringWithFormat:@"Do you want to check in at %@?", _selectedLocation.name];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes", nil];
    [alertView show];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
        [self saveUserWithLocation];
}


@end
