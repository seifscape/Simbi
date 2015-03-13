//
//  SMBUser.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBUser.h"

#import "SMBFourSquareObject.h"

@implementation SMBUser

@dynamic firstName;
@dynamic lastName;
@dynamic age;
@dynamic gender;
@dynamic hairColor;
@dynamic profilePicture;
@dynamic backgroundImage;
@dynamic location;
@dynamic geoPoint;
@dynamic facebookId;

@dynamic city;
@dynamic state;

@dynamic searchString;

@dynamic lowerAgePreference;
@dynamic upperAgePreference;
@dynamic genderPreference;
@dynamic hairColorPreference;

@dynamic visitedUsers;
@dynamic friends;
@dynamic friendRequests;
@dynamic pendingFriendRequests;

@dynamic encounters;
@dynamic chats;
@dynamic activities;
@dynamic unreadMessageCount;
@dynamic hasNewMessage;

@dynamic phoneNumber;
@dynamic confirmingPhoneNumber;
@dynamic isConfirmed;

@dynamic height;
@dynamic lowerHeightPreference;
@dynamic upperHeightPreference;

@dynamic private;
@dynamic credits;

@dynamic visible;
@dynamic aboutme;
@dynamic ethnicity;
@dynamic degree;
@dynamic school;
@dynamic tags;
@dynamic MeetUpLocations;
@dynamic MeetUpTimes;
@dynamic occupation;
@dynamic employer;
@dynamic lookingto;
@dynamic ContactList;
#pragma mark - PFUser Helpers

+ (SMBUser *)currentUser
{
    return (SMBUser *)[PFUser currentUser];
}


+ (BOOL)exists
{
    if ([PFUser currentUser].objectId)
        return YES;
    else
        return NO;
}


- (NSString *)name
{
    return self.firstName;
}


#pragma mark - Typed Setters

- (void)setGenderType:(SMBUserGenderType)type
{
    switch (type)
    {
        case kSMBUserGenderMale:
            [self setGender:@"male"];
            break;
            
        case kSMBUserGenderFemale:
            [self setGender:@"female"];
            break;
            
        case kSMBUserGenderOther:
            [self setGender:@"other"];
            break;
            
        case kSMBUserGenderNone:
            [self setGender:@""];
            break;
    }
}


- (SMBUserGenderType)genderType
{
    if ([self.gender isEqualToString:@"male"])
        return kSMBUserGenderMale;
    else if ([self.gender isEqualToString:@"female"])
        return kSMBUserGenderFemale;
    else if ([self.gender isEqualToString:@"other"])
        return kSMBUserGenderOther;
    else
        return kSMBUserGenderNone;
}


- (void)setGenderPreferenceType:(SMBUserGenderType)type
{
    switch (type)
    {
        case kSMBUserGenderMale:
            [self setGenderPreference:@"male"];
            break;
            
        case kSMBUserGenderFemale:
            [self setGenderPreference:@"female"];
            break;
            
        case kSMBUserGenderOther:
            [self setGenderPreference:@"other"];
            break;
            
        case kSMBUserGenderNone:
            [self setGenderPreference:@""];
            break;
    }
}


- (SMBUserGenderType)genderPreferenceType
{
    if ([self.genderPreference isEqualToString:@"male"])
        return kSMBUserGenderMale;
    else if ([self.genderPreference isEqualToString:@"female"])
        return kSMBUserGenderFemale;
    else if ([self.genderPreference isEqualToString:@"other"])
        return kSMBUserGenderOther;
    else
        return kSMBUserGenderNone;
}


- (SMBUserPreference)userPreference
{
    long woop = 0;
    
    for (int i = 0; i < self.name.length; i++)
        woop += [self.name characterAtIndex:i];
    
    woop = woop % 3;
    
    if (woop == 0)
        return kSMBUserPreferenceFirst;
    else if (woop == 1)
        return kSMBUserPreferenceSecond;
    else
        return kSMBUserPreferenceThird;
}


#pragma mark - Facebook

- (void)syncWithFacebook:(void (^)(BOOL succeeded))completion
{
    // Method to retrieve and set the user's name, email, gender, and profile picture to the same as on their Facebook profile.
    
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
        
        if (!error)
        {            
            [self setFirstName:FBuser.first_name];
            [self setLastName:FBuser.last_name];
            [self setEmail:FBuser[@"email"]];
            [self setFacebookId:FBuser[@"id"]];
            
            if ([[FBuser[@"gender"] lowercaseString] isEqualToString:@"male"])
                [self setGenderType:kSMBUserGenderMale];
            else if ([[FBuser[@"gender"] lowercaseString] isEqualToString:@"female"])
                [self setGenderType:kSMBUserGenderFemale];
            else
                [self setGenderType:kSMBUserGenderOther];
            
            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", FBuser[@"id"]];
            
            NSData *pictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]];
            
            SMBImage *parseImage = [[SMBImage alloc] init];
            [parseImage setOriginalImage:[PFFile fileWithData:pictureData]];
            
            [parseImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    [self setProfilePicture:parseImage];
                    
                    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded)
                        {
                            completion(YES);
                        }
                        else // User save failure
                        {
                            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                            completion(NO);
                        }
                    }];
                }
                else // Parse Image save failure
                {
                    NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                    completion(NO);
                }
            }];
        }
        else // Facebook failure
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            completion(NO);
        }
    }];
}


#pragma mark - City and State Methods

- (NSString *)cityAndState
{
    if (self.city.length > 0 && self.state.length > 0)
        return [NSString stringWithFormat:@"%@, %@", self.city, self.state];
    else if (self.city.length > 0)
        return self.city;
    else if (self.state.length > 0)
        return self.state;
    else
        return @"";
}


#pragma mark - Cell Methods

- (SMBUserCell *)userCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cellIdentifier:(NSString *)cellIdentifier
{
    SMBUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell)
        cell = [[SMBUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    [cell.profilePictureView setParseImage:self.profilePicture withType:kImageTypeThumbnail];
    [cell.firstNameLabel setText:self.name];
    [cell.emailLabel setText:self.email];
    
    return cell;
}


@end
