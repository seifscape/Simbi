//
//  SMBSignupInfoViewController.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBSignupInfoViewController.h"

#import <NMRangeSlider/NMRangeSlider.h>

#import "SMBAppDelegate.h"
#import "SMBImageView.h"
#import "SMBFacebookFriendsViewController.h"


@interface _SMBSignupInfoViewController ()

@property (nonatomic, strong) SMBImageView *profilePictureView;
@property (nonatomic, strong) SMBImage *profileImage;

@property (nonatomic, strong) UILabel *myAgeLabel;
@property (nonatomic, strong) UILabel *agePrefLabel;

@property (nonatomic, strong) UIView *statusBarView;

@end


@implementation _SMBSignupInfoViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor simbiBlueColor]];
    
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    _statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    [_statusBarView setBackgroundColor:[[UIColor simbiBlueColor] colorWithAlphaComponent:0.66f]];
    [self.navigationController.view addSubview:_statusBarView];
    
    if (![PFFacebookUtils isLinkedWithUser:[SMBUser currentUser]])
        [self changePictureAction];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIView animateWithDuration:0.25f animations:^{
        [_statusBarView setAlpha:0.f];
    } completion:^(BOOL finished) {
        [_statusBarView removeFromSuperview];
    }];
}


#pragma mark - User Actions

- (void)changePictureAction
{
    NSString *title = @"Profile Picture";
    
    UIAlertView *alertView;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take photo now", @"Select photo", nil];
    }
    else
    {
        alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Select photo", nil];
    }
    [alertView show];
}


- (void)myGenderDidChange:(UISegmentedControl *)genderControl
{
    if (genderControl.selectedSegmentIndex == 0)
        [[SMBUser currentUser] setGenderType:kSMBUserGenderMale];
    else if (genderControl.selectedSegmentIndex == 1)
        [[SMBUser currentUser] setGenderType:kSMBUserGenderFemale];
    else if (genderControl.selectedSegmentIndex == 2)
        [[SMBUser currentUser] setGenderType:kSMBUserGenderOther];
}


- (void)myAgeDidChange:(UISlider *)ageSlider
{
    [[SMBUser currentUser] setAge:[NSNumber numberWithInt:(int)ageSlider.value]];
    
    [_myAgeLabel setText:[NSString stringWithFormat:@"%d", (int)ageSlider.value]];
    
    if ((int)ageSlider.value >= (int)ageSlider.maximumValue)
        [_myAgeLabel setText:[NSString stringWithFormat:@"%d+", (int)ageSlider.maximumValue]];
}


- (void)myHairColorDidChange
{
    
}


- (void) genderPreferenceDidChange:(UISegmentedControl *)genderControl
{
    if (genderControl.selectedSegmentIndex == 0)
        [[SMBUser currentUser] setGenderPreferenceType:kSMBUserGenderMale];
    else if (genderControl.selectedSegmentIndex == 1)
        [[SMBUser currentUser] setGenderPreferenceType:kSMBUserGenderFemale];
    else if (genderControl.selectedSegmentIndex == 2)
        [[SMBUser currentUser] setGenderPreferenceType:kSMBUserGenderOther];
}

-(void)agePreferenceDidChange:(NMRangeSlider *)agePrefSlider
{
    if ((int)agePrefSlider.upperValue >= (int)agePrefSlider.maximumValue)
        [_agePrefLabel setText:[NSString stringWithFormat:@"%d-%d+", (int)agePrefSlider.lowerValue, (int)agePrefSlider.upperValue]];
    else
        [_agePrefLabel setText:[NSString stringWithFormat:@"%d-%d", (int)agePrefSlider.lowerValue, (int)agePrefSlider.upperValue]];
    
    [[SMBUser currentUser] setLowerAgePreference: [NSNumber numberWithInt:(int)agePrefSlider.lowerValue]];
    [[SMBUser currentUser] setUpperAgePreference:[NSNumber numberWithInt:(int)agePrefSlider.upperValue]];
}



- (void)hairColorPreferenceDidChange
{
    
}


- (void)doneAction
{
    // Validate fields (except Hair Color..)
    
    if (![SMBUser currentUser].profilePicture.objectId)
    {
        [MBProgressHUD showMessage:@"Please upload a picture" parent:self];
        return;
    }
    if (![SMBUser currentUser].gender)
    {
        [MBProgressHUD showMessage:@"Please choose a gender" parent:self];
        return;
    }
    if (![SMBUser currentUser].age)
    {
        [MBProgressHUD showMessage:@"Please choose an age" parent:self];
        return;
    }
    
    // Save and launch into the app
    
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Saving..." parent:self];
    
    // Get a starting geoPoint (don't care if error)
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
       
        if (geoPoint)
            [[SMBUser currentUser] setGeoPoint:geoPoint];
        
        // Do a reverse-geocpode lookup to get a starting city and state (don't care if error)
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
           
            if (placemarks)
            {
                CLPlacemark *placemark = [placemarks firstObject];
                
                [[SMBUser currentUser] setCity:placemark.locality];
                [[SMBUser currentUser] setState:placemark.administrativeArea];
            }
            else
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            
            if (![SMBUser currentUser].city || ![SMBUser currentUser].state)
            {
                [[SMBUser currentUser] setCity:@"Somewhere"];
                [[SMBUser currentUser] setState:@""];
            }
            
            [[SMBUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    if ([PFFacebookUtils isLinkedWithUser:[SMBUser currentUser]])
                    {
                        // If from Facebook, get a list of all their friends
                        
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
                                    
                                    if (objects)
                                    {
                                        [hud dismissQuickly];
                                        
                                        if (objects.count > 0) // Push into view if the user has friends on the app
                                        {
                                            SMBFacebookFriendsViewController *viewController = [[SMBFacebookFriendsViewController alloc] initWithUsers:objects isSignUp:YES];
                                            [self.navigationController pushViewController:viewController animated:YES];
                                        }
                                        else // Otherwise, just go to main
                                        {
                                            [[SMBAppDelegate instance] animateToMain];
                                        }
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
                    else
                    {
                        [hud dismissQuickly];
                        [[SMBAppDelegate instance] animateToMain];
                    }
                }
                else
                {
                    NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                    [hud dismissWithError];
                }
            }];
        }];
    }];
}


#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 132+(tableView.frame.size.width-176);
    else if (section == 1)
        return 44;
    else
        return 8;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 132+(tableView.frame.size.width-176))];
        
        UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(0, -220, tableView.frame.size.width, 220+44+(headerView.frame.size.width-176)/2.f)];
        [blueView setBackgroundColor:[UIColor simbiBlueColor]];
        [headerView addSubview:blueView];
        
        _profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake(88, 44, headerView.frame.size.width-176, headerView.frame.size.width-176)];
        [_profilePictureView.layer setCornerRadius:_profilePictureView.frame.size.width/2.f];
        [_profilePictureView.layer setMasksToBounds:YES];
        [_profilePictureView setBackgroundColor:[UIColor simbiDarkGrayColor]];
        if ([SMBUser currentUser].profilePicture.objectId)
            [_profilePictureView setParseImage:[SMBUser currentUser].profilePicture];
        [headerView addSubview:_profilePictureView];
        
        UIButton *profilePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [profilePictureButton setFrame:CGRectMake(88, _profilePictureView.frame.origin.y+_profilePictureView.frame.size.height, tableView.frame.size.width-176, 32)];
        [profilePictureButton setTitle:@"Change Picture" forState:UIControlStateNormal];
        [profilePictureButton setTitleColor:[UIColor simbiGrayColor] forState:UIControlStateNormal];
        [profilePictureButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:14.f]];
        [profilePictureButton addTarget:self action:@selector(changePictureAction) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:profilePictureButton];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 132+(tableView.frame.size.width-176)-44, tableView.frame.size.width-8, 44)];
        [titleLabel setText:@"About Me:"];
        [titleLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [titleLabel setFont:[UIFont simbiBoldFontWithSize:18.f]];
        [headerView addSubview:titleLabel];
        
        return headerView;
    }
    else if (section == 1)
    {
        UIView *headerView = [[UIView alloc] init];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, tableView.frame.size.width-8, 44)];
        [titleLabel setText:@"My Preferences:"];
        [titleLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [titleLabel setFont:[UIFont simbiBoldFontWithSize:18.f]];
        [headerView addSubview:titleLabel];
        
        return headerView;
    }
    else
        return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 3;
    else if (section == 1)
        return 3;
    else if (section == 2)
        return 1;
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    [textLabel setFont:[UIFont simbiFontWithSize:14.f]];
    [textLabel setTextColor:[UIColor simbiDarkGrayColor]];
    [textLabel setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:textLabel];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [textLabel setText:@"Gender"];
            
            UISegmentedControl *myGenderControl = [[UISegmentedControl alloc] initWithItems:@[@"Male", @"Female", @"Other"]];
            [myGenderControl setFrame:CGRectMake(88, 8, tableView.frame.size.width-88-20, 44-16)];
            [myGenderControl setTintColor:[UIColor simbiRedColor]];
            [myGenderControl addTarget:self action:@selector(myGenderDidChange:) forControlEvents:UIControlEventValueChanged];
            
            if ([SMBUser currentUser].gender)
            {
                if ([SMBUser currentUser].genderType == kSMBUserGenderMale)
                    [myGenderControl setSelectedSegmentIndex:0];
                else if ([SMBUser currentUser].genderType == kSMBUserGenderFemale)
                    [myGenderControl setSelectedSegmentIndex:1];
                else
                    [myGenderControl setSelectedSegmentIndex:2];
            }
            
            [cell.contentView addSubview:myGenderControl];
        }
        else if (indexPath.row == 1)
        {
            [textLabel setText:@"Age"];
            
            if (!_myAgeLabel)
            {
                _myAgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-44-20, 0, 60, 44)];
                [_myAgeLabel setFont:[UIFont simbiBoldFontWithSize:18.f]];
                [_myAgeLabel setTextAlignment:NSTextAlignmentCenter];
                [_myAgeLabel setText:@"18"];
                
                [[SMBUser currentUser] setAge:@18];
            }
            [cell.contentView addSubview:_myAgeLabel];
            
            UISlider *myAgeSlider = [[UISlider alloc] initWithFrame:CGRectMake(88, 0, tableView.frame.size.width-88-44-20, 44)];
            [myAgeSlider setMinimumValue:18];
            [myAgeSlider setMaximumValue:55];
            [myAgeSlider setTintColor:[UIColor simbiRedColor]];
            [myAgeSlider addTarget:self action:@selector(myAgeDidChange:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:myAgeSlider];
        }
        else if (indexPath.row == 2)
        {
            [textLabel setText:@"Hair Color"];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            [textLabel setText:@"Gender"];
            
            UISegmentedControl *genderPrefControl = [[UISegmentedControl alloc] initWithItems:@[@"Male", @"Female", @"Other"]];
            [genderPrefControl setFrame:CGRectMake(88, 8, tableView.frame.size.width-88-20, 44-16)];
            [genderPrefControl setTintColor:[UIColor simbiRedColor]];
            [genderPrefControl addTarget:self action:@selector(genderPreferenceDidChange:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:genderPrefControl];
        }
        else if (indexPath.row == 1)
        {
            [textLabel setText:@"Age"];
            
            
            NMRangeSlider *agePrefSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(88, 0, cell.frame.size.width-88-44-20, 44)];
            [agePrefSlider setMinimumValue:18];
            [agePrefSlider setMaximumValue:55];
            [agePrefSlider setMinimumRange:1];
            [agePrefSlider setTintColor:[UIColor simbiRedColor]];
            
            [agePrefSlider setUpperValue: agePrefSlider.maximumValue];
            [agePrefSlider setLowerValue: agePrefSlider.minimumValue];
            
            [agePrefSlider addTarget:self action:@selector(agePreferenceDidChange:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:agePrefSlider];
            
            if (!_agePrefLabel)
            {
                _agePrefLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-44-20, 0, 60, 44)];
                [_agePrefLabel setFont:[UIFont simbiBoldFontWithSize:18.f]];
                [_agePrefLabel setTextAlignment:NSTextAlignmentCenter];
                [self agePreferenceDidChange:agePrefSlider];
            }
            [cell.contentView addSubview:_agePrefLabel];
        }
        else if (indexPath.row == 2)
        {
            [textLabel setText:@"Hair Color"];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            UIButton *doneButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, 0, tableView.frame.size.width-88, 44)];
            [doneButton setTitle:@"Done" forState:UIControlStateNormal];
            [doneButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:doneButton];
        }
    }
    
    return cell;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setDelegate:self];
        [imagePicker setAllowsEditing:YES];
        
        if (alertView.numberOfButtons == 3 && buttonIndex == 1) // Take photo
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        else // Select a photo
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        UIImage *image = info[UIImagePickerControllerEditedImage];

        SMBImage *profileImage = [[SMBImage alloc] init];
        [profileImage setOriginalImage:[PFFile fileWithData:UIImageJPEGRepresentation(image, 0.8f)]];
        
        [_profilePictureView setParseImage:profileImage ];
        [_profilePictureView saveImageInBackgroundWithBlock:^(SMBImage *savedImage) {
            
            if (savedImage)
            {
                [[SMBUser currentUser] setProfilePicture:profileImage];
                [[SMBUser currentUser] saveInBackground];
            }
        }];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)imagePickerController
{
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


@end
