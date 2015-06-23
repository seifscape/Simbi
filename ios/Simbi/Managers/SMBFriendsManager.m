//
//  SMBFriendsManager.m
//  Simbi
//
//  Created by flynn on 6/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendsManager.h"


@interface SMBFriendsManager ()

@end


@implementation SMBFriendsManager

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
        [self registerClassName:@"_User" includes:@[@"profilePicture", @"hairColor"] orderKey:@"name"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFriendRequestAcceptedNotification:) name:kSMBNotificationFriendRequestAccepted object:nil];
    }
    
    return self;
}


#pragma mark - Notification Handling

- (void)handleFriendRequestAcceptedNotification:(NSNotification *)notification
{
    NSString *toUserId = notification.userInfo[@"toUserId"];
    
    if (!toUserId || toUserId.length == 0)
    {
        NSLog(@"%s - WARNING: Received a FriendRequestAccepted notification with no toUserId provided!", __PRETTY_FUNCTION__);
        return;
    }
    
    [self addObjectWithId:toUserId];
}


#pragma mark - SMBManager Methods

- (PFQuery *)query
{
    PFQuery *query = [SMBUser currentUser].friends.query;

    /*
        deleted by zhy at 2015-06-17
        
        bug: SIMBI USER table could not show out the users
        reason: wrong query conditions, like "profilePicture" "hairColor"
     
     */
    
    //    [query includeKey:@"profilePicture"];
    //    [query includeKey:@"hairColor"];
    
    [query orderByAscending:@"name"];
    
    return query;
}


- (void)objectsDidLoad
{
    NSLog(@"%@: loaded %ld friends", [self class], (long)self.objects.count);
}


#pragma mark - Public Methods

- (NSArray *)friendsObjectIds
{
    NSMutableArray *objectIds = [NSMutableArray new];
    
    for (SMBUser *user in self.objects)
        [objectIds addObject:user.objectId];
    
    return [NSArray arrayWithArray:objectIds];
}


@end
