//
//  SMBLocationPickerViewControllerTableViewController.m
//  Simbi
//
//  Created by Patrick Sutton on 6/4/14.
//  Copyright (c) 2014 MaxxPotential. All rights reserved.
//

#import "SMBLocationViewController.h"

@interface SMBLocationViewController ()

@property (nonatomic, strong) NSArray *locations;

@property (nonatomic, strong) FourSquareLocation *location;

@property (nonatomic, strong) MBProgressHUD *hud;

@end


@implementation SMBLocationViewController

- (id)initWithLocations:(NSArray *)locations
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self)
    {
        _locations = [[NSArray alloc] initWithArray:locations];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self.navigationItem setTitle:@"Select Your Location"];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    [self.tableView setBackgroundColor:[UIColor simbiLightGrayColor]];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_locations.count);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    NSNumber *distanceInFeet;
    NSString *distanceString;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: cellIdentifier];
    
    
    _location = (FourSquareLocation *)_locations[indexPath.row];
    
    distanceInFeet = [NSNumber numberWithFloat:_location.distance.floatValue * 3.28];
    distanceString = [NSString stringWithFormat:@"Distance Away: %ift.", distanceInFeet.intValue];
    
    [cell.textLabel setText: _location.name];
    [cell.detailTextLabel setText:distanceString];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _location = (FourSquareLocation *)_locations[indexPath.row];
    if (_location)
        [self saveUserAndLocation];
}

#pragma mark User Actions

- (void)saveUserAndLocation
{
    _hud = [MBProgressHUD HUDwithMessage:@"Saving..." parent:self];
    SMBLocation *locationToParse = [[SMBLocation alloc] init];
    [locationToParse setLocationName: _location.name];
    [locationToParse setGeoPoint:_location.geoPoint];
    
    [[SMBUser currentUser] setCity:_location.city];
    [[SMBUser currentUser] setState:_location.state];
    [[SMBUser currentUser] setLocation:locationToParse];
    
    SMBActivity *activity = [[SMBActivity alloc] init];
    [activity setUser: [SMBUser currentUser]];
    [activity setActivityLocation:locationToParse];
    [activity setActivityText:_location.name];
    [activity setActivityType:@"CheckIn"];
    
    
    
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
       if (succeeded)
       {
           PFRelation *activityRelation = [[PFUser currentUser] relationForKey:@"activities"];
           [activityRelation addObject:activity];
           
           [[SMBUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (succeeded)
                {
                    [_hud dismissWithMessage:@"Checked in!"];
                    [self dismissViewControllerAnimated:YES completion: nil];
                }
                else
                {
                    [_hud dismissWithError];
                }
            }];
       }
       else
       {
           [_hud dismissWithError];
       }
    }];
    
}


-(void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
