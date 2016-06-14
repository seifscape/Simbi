//
//  SMBActivity.h
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>


@class SMBLocation;
@class SMBUser;



@interface SMBActivity : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) SMBUser *user;
@property (retain) NSString *userObjectId;
@property (retain) NSString *activityType;
@property (retain) NSString *activityText;
@property (retain) SMBLocation *activityLocation;

@end
