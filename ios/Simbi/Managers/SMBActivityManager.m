//
//  SMBActivityManager.m
//  Simbi
//
//  Created by flynn on 7/2/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBActivityManager.h"

#import "SMBFriendsManager.h"


@interface SMBActivityManager ()

@end


@implementation SMBActivityManager

+ (instancetype)sharedManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.isLoading = YES; // Is "loading" until the friends manager can load
        
        [self registerClassName:@"Activity" includes:@[@"user", @"user.profilePicture"] orderKey:@"createdAt"];
        [self setOrder:NSOrderedDescending];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCheckInActivityNotification:) name:kSMBNotificationCheckInActivity object:nil];
        
        [[SMBFriendsManager sharedManager] addDelegate:self];
    }
    
    return self;
}


#pragma mark - Notification Handling

- (void)handleCheckInActivityNotification:(NSNotification *)notification
{    
    [self addObjectWithId:notification.userInfo[@"activityId"]];
}


#pragma mark - SMBManager Methods

- (PFQuery *)query
{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    
    [query whereKey:@"userObjectId" containedIn:[[SMBFriendsManager sharedManager] friendsObjectIds]];
    
    for (NSString *include in self.includes)
        [query includeKey:include];
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}


- (void)objectsDidLoad
{
    NSLog(@"%@: loaded %ld activities", [self class], (long)self.objects.count);
}


#pragma mark - SMBManagerDelegate (for SMBFriendsManager)

- (void)manager:(SMBManager *)manager didUpdateObjects:(NSArray *)objects
{
    [self loadObjects:nil];
}


- (void)manager:(SMBManager *)manager didFailToLoadObjects:(NSError *)error
{
    
}


@end
