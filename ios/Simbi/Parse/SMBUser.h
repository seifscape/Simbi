//
//  SMBUser.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>

#import "SMBUserCell.h"


@class SMBHairColor;
@class SMBImage;
@class SMBLocation;
@class SMBUserPrivate;
@class SMBUserCredits;


@interface SMBUser : PFUser <PFSubclassing>

typedef enum SMBUserGenderType : NSInteger
{
    kSMBUserGenderMale = 0,
    kSMBUserGenderFemale,
    kSMBUserGenderOther,
    kSMBUserGenderNone
} SMBUserGenderType;

typedef enum SMBUserPreference : NSInteger
{
    kSMBUserPreferenceFirst,
    kSMBUserPreferenceSecond,
    kSMBUserPreferenceThird,
    kSMBUserPreferenceNone
} SMBUserPreference;

+ (SMBUser *)currentUser;
+ (BOOL)exists;

- (void)setGenderType:(SMBUserGenderType)type;
- (SMBUserGenderType)genderType;
- (void)setGenderPreferenceType:(SMBUserGenderType)type;
- (SMBUserGenderType)genderPreferenceType;
- (SMBUserPreference)userPreference;

- (void)syncWithFacebook:(void (^)(BOOL succeeded))completion;

- (NSString *)cityAndState;

- (SMBUserCell *)userCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath cellIdentifier:(NSString *)cellIdentifier;

@property (retain, readonly) NSString *name;
@property (retain) NSString *firstName;
@property (retain) NSString *lastName;
@property (retain) NSNumber *age;
@property (retain) NSString *gender;
@property (retain) NSArray *lookingto;
@property (retain) SMBHairColor *hairColor;
@property (retain) SMBImage *profilePicture;
@property (retain) SMBImage *backgroundImage;
@property (retain) SMBLocation *location;
@property (retain) PFGeoPoint *geoPoint;
@property (retain) NSString *facebookId;

@property (retain) NSString *city;
@property (retain) NSString *state;

@property (retain) NSString *searchString;

@property (retain) NSNumber *lowerAgePreference;
@property (retain) NSNumber *upperAgePreference;
@property (retain) NSString *genderPreference;
@property (retain) SMBHairColor *hairColorPreference;

@property (retain, readonly) PFRelation *visitedUsers;
@property (retain, readonly) PFRelation *friends;
@property (retain, readonly) PFRelation *friendRequests;
@property (retain) NSNumber *pendingFriendRequests;

@property (retain, readonly) PFRelation *encounters;
@property (retain, readonly) PFRelation *chats;
@property (retain, readonly) PFRelation *activities;
@property (retain) NSNumber *unreadMessageCount;
@property BOOL hasNewMessage;

@property (retain) NSString *phoneNumber;
@property (retain) NSString *confirmingPhoneNumber;
@property BOOL isConfirmed;

@property (retain) NSNumber *height;
@property (retain) NSNumber *lowerHeightPreference;
@property (retain) NSNumber *upperHeightPreference;

@property (retain) SMBUserPrivate *private;
@property (retain) SMBUserCredits *credits;
@property  BOOL visible;
@property (retain) NSString* aboutme;
@property (retain) NSString* ethnicity;
@property  (retain) NSString* degree;
@property (retain) NSString* school;
@property (retain) NSMutableArray* tags;
@property (retain) NSArray* MeetUpLocations;
@property (retain) NSArray* MeetUpTimes;
@property (retain) NSString* occupation;
@property (retain) NSString* employer;
@property (retain) NSArray* ContactList;
@end
