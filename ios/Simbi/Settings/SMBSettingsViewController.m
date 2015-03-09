//
//  SMBSettingsViewController.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBSettingsViewController.h"

#import "SMBAppDelegate.h"
#import "SMBChatManager.h"
#import "SMBFriendsManager.h"
#import "SMBFriendRequestsManager.h"
#import "SMBImageView.h"
#import "SMBMyProfileViewController.h"
#import "SMBPreferencesViewController.h"
#import "Simbi-Swift.h"


@interface SMBSettingsViewController ()

@property (nonatomic, strong) SMBImageView *profilePictureView;
@property (nonatomic, strong) SMBImageView *backgroundImageView;
@property (nonatomic, strong) LiuMyProfileViewController* liuMyProfile;
@end


@implementation SMBSettingsViewController

const NSInteger kAlertView_changePicture    = 0;
const NSInteger kAlertView_logOut           = 1;
const NSInteger kAlertView_deleteAccount    = 2;
const NSInteger kAlertView_changeBackground = 3;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.liuMyProfile = nil;
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Settings"];
    [self.view setBackgroundColor:[UIColor simbiLightGrayColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    if ([UIScreen mainScreen].bounds.size.height >= [self requiredHeightForTable]+44)
        [self.tableView setScrollEnabled:NO];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[SMBAppDelegate instance] enableSideMenuGesture:NO];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SMBAppDelegate instance] enableSideMenuGesture:YES];
}


#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:  return 2; // Profile picture, background image
        case 1:  return 2; // Edit my profile, preferences
        case 2:  return 2; // Log out, delete
        default: return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor simbiWhiteColor]];
    [cell.textLabel setFont:[UIFont simbiFontWithSize:16.f]];
    [cell.textLabel setTextColor:[UIColor simbiDarkGrayColor]];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [cell.textLabel setText:@"Change Profile Picture"];
            
            if (!_profilePictureView)
            {
                _profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-44, 4, 44-8, 44-8) parseImage:[SMBUser currentUser].profilePicture];
                [_profilePictureView setBackgroundColor:[UIColor simbiDarkGrayColor]];
                [_profilePictureView.layer setCornerRadius:_profilePictureView.frame.size.width/2.f];
                [_profilePictureView.layer setMasksToBounds:YES];
            }
            [cell.contentView addSubview:_profilePictureView];
        }
        if (indexPath.row == 1)
        {
            [cell.textLabel setText:@"Change Background Photo"];
            
            if (!_backgroundImageView)
            {
                _backgroundImageView = [[SMBImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-66, 0, 66, 44)];
                if ([SMBUser currentUser].backgroundImage)
                    [_backgroundImageView setParseImage:[SMBUser currentUser].backgroundImage];
                [_backgroundImageView setBackgroundColor:[UIColor clearColor]];
                
                CAGradientLayer *gradientLayer = [CAGradientLayer layer];
                [gradientLayer setColors:[NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, nil]];
                [gradientLayer setTransform:CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(-M_PI_2))];
                [gradientLayer setFrame:CGRectMake(0, 0, _backgroundImageView.frame.size.width, _backgroundImageView.frame.size.height)];
                [_backgroundImageView.layer setMask:gradientLayer];
            }
            [cell.contentView addSubview:_backgroundImageView];
        }
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            [cell.textLabel setText:@"Edit My Profile"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        if (indexPath.row == 1)
        {
            [cell.textLabel setText:@"Edit Preferences"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            [cell.textLabel setText:@"Log Out"];
        }
        if (indexPath.row == 1)
        {
            [cell.textLabel setTextColor:[UIColor simbiRedColor]];
            [cell.textLabel setText:@"Delete Account"];
        }
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [self changeProfilePictureAction];
        }
        if (indexPath.row == 1)
        {
            [self changeBackgroundImageAction];
        }
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            if (self.liuMyProfile==nil) {
                self.liuMyProfile = [[LiuMyProfileViewController alloc] init];
                
            }
            [self.navigationController pushViewController:self.liuMyProfile animated:YES];
        }
        if (indexPath.row == 1)
        {
            SMBPreferencesViewController *viewController = [[SMBPreferencesViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            [self promptToLogOutAction];
        }
        if (indexPath.row == 1)
        {
            [self promptToDeleteAccountAction];
        }
    }
}


#pragma mark - User Actions

- (void)changeProfilePictureAction
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
    [alertView setTag:kAlertView_changePicture];
    [alertView show];
}


- (void)changeBackgroundImageAction
{
    NSString *title = @"Background Photo";
    
    UIAlertView *alertView;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take photo now", @"Select photo", @"Remove current photo", nil];
    }
    else
    {
        alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Select photo", @"Remove current photo", nil];
    }
    [alertView setTag:kAlertView_changeBackground];
    [alertView show];
}


- (void)promptToLogOutAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log Out" message:@"Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setTag:kAlertView_logOut];
    [alertView show];
}


- (void)promptToDeleteAccountAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Account" message:@"😨 Are you sure? This cannot be undone." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes, Goodbye…", nil];
    [alertView setTag:kAlertView_deleteAccount];
    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}


#pragma mark - Other Methods

- (void)dismissToHome
{
    [[SMBAppDelegate instance] setCenterViewController:[[SMBMainViewController alloc] init]];
}


- (void)deleteAccount
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Deleting Account..." parent:self];
    
    if ([SMBUser currentUser])
    {
        [[SMBUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 if ([SMBUser exists])
                     [SMBUser logOut];
                 
                 [[SMBFriendsManager sharedManager] clearObjects];
                 [[SMBFriendRequestsManager sharedManager] clearObjects];
                 [[SMBChatManager sharedManager] clearObjects];
                 
                 [[SMBAppDelegate instance] syncUserInstallation];
                 
                 [hud dismissWithMessage:@"Successfully Deleted Acount"];
                 
                 [self performSelector:@selector(dismissToHome) withObject:nil afterDelay:kHUDHideTime];
             }
             else
             {
                 NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                 [hud dismissWithError];
             }
         }];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertView_changePicture)
    {
        if (buttonIndex != 0)
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            [imagePicker setDelegate:self];
            [imagePicker setAllowsEditing:YES];
            [imagePicker.view setTag:kAlertView_changePicture];
            
            if (alertView.numberOfButtons == 3 && buttonIndex == 1) // Take photo
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            else // Select a photo
                [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }
    else if (alertView.tag == kAlertView_changeBackground)
    {
        if (buttonIndex != 0)
        {
            if (buttonIndex < alertView.numberOfButtons-1)
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                [imagePicker setDelegate:self];
                [imagePicker setAllowsEditing:YES];
                [imagePicker.view setTag:kAlertView_changeBackground];
                
                if (alertView.numberOfButtons == 4 && buttonIndex == 1) // Take photo
                    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                else // Select a photo
                    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else
            {
                [[SMBUser currentUser] setBackgroundImage:nil];
                [[SMBUser currentUser] saveInBackground];
                [_backgroundImageView setImage:nil];
            }
        }
    }
    else if (alertView.tag == kAlertView_logOut)
    {
        if (buttonIndex != 0)
        {
            [PFUser logOut];
            [[SMBAppDelegate instance] syncUserInstallation];
            [[SMBAppDelegate instance] setCenterViewController:[[SMBEnterViewController alloc] init]];
            
            [[SMBFriendsManager sharedManager] clearObjects];
            [[SMBFriendRequestsManager sharedManager] clearObjects];
            [[SMBChatManager sharedManager] clearObjects];
        }
    }
    else if (alertView.tag == kAlertView_deleteAccount)
    {
        if (buttonIndex != 0)
            [self deleteAccount];
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        UIImage *image = info[UIImagePickerControllerEditedImage];
        
        SMBImage *parseImage = [[SMBImage alloc] init];
        [parseImage setOriginalImage:[PFFile fileWithData:UIImageJPEGRepresentation(image, 0.8f)]];
        
        if (picker.view.tag == kAlertView_changePicture)
        {
            [_profilePictureView setParseImage:parseImage];
            [_profilePictureView saveImageInBackgroundWithBlock:^(SMBImage *savedImage) {
                
                if (savedImage)
                {
                    [[SMBUser currentUser] setProfilePicture:parseImage];
                    [[SMBUser currentUser] saveInBackground];
                }
            }];
        }
        else
        {
            [_backgroundImageView setParseImage:parseImage];
            [_backgroundImageView saveImageInBackgroundWithBlock:^(SMBImage *savedImage) {
                
                if (savedImage)
                {
                    [[SMBUser currentUser] setBackgroundImage:parseImage];
                    [[SMBUser currentUser] saveInBackground];
                }
            }];
        }
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
