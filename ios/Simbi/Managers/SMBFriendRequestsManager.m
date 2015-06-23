//
//  SMBFriendRequestsManager.m
//  Simbi
//
//  Created by flynn on 6/26/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFriendRequestsManager.h"


@interface SMBFriendRequestsManager ()

@end


@implementation SMBFriendRequestsManager

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
        [self registerClassName:@"FriendRequest" includes:@[@"fromUser", @"fromUser.profilePicture", @"fromUser.hairColor"] orderKey:@"createdAt"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFriendRequestReceivedNotification:) name:kSMBNotificationFriendRequestReceived object:nil];
    }
    
    return self;
}


#pragma mark - Notification Handling

- (void)handleFriendRequestReceivedNotification:(NSNotification *)notification
{
    NSString *fromUserId = notification.userInfo[@"fromUserId"];
    
    if (!fromUserId || fromUserId.length == 0)
    {
        NSLog(@"%s - WARNING: Received a FriendRequestReceived notification with no fromUserId provided!", __PRETTY_FUNCTION__);
        return;
    }
    
    [self addObjectWithId:fromUserId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query includeKey:@"profilePicture"];
    [query includeKey:@"hairColor"];
    
    [query getObjectInBackgroundWithId:fromUserId block:^(PFObject *object, NSError *error) {
        
        if (object)
        {
            SMBUser *fromUser = (SMBUser *)object;
            
            PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
            [query whereKey:@"fromUser" equalTo:fromUser];
            [query whereKey:@"toUser" equalTo:[SMBUser currentUser]];
            [query includeKey:@"fromUser"];
            
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                if (object)
                    [self addObject:object];
                else
                    NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            }];
        }
        else
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
    }];
}


#pragma mark - SMBManager Methods

- (PFQuery *)query
{
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"toUser" equalTo:[SMBUser currentUser]];
    [query whereKey:@"status" equalTo:@"Pending"];
    [query includeKey:@"fromUser"];
    
    /*
     deleted by zhy at 2015-06-17
     
     bug: 'SIMBI FRIENDS table' could not show out the friendRequests
     reason: wrong query conditions, like "profilePicture" "hairColor"
     
     */
    
//    [query includeKey:@"fromUser.profilePicture"];
//    [query includeKey:@"fromUser.hairColor"];
    
    return query;
}


- (void)loadObjects:(void (^)(BOOL))callback
{
    [super loadObjects:callback];
}


- (void)objectsDidLoad
{
    NSLog(@"%@: loaded %ld friend requests", [self class], (long)self.objects.count);
    
    // Check for any "bad" friend requests
    
    NSMutableArray *objectsToRemove = [NSMutableArray new];
    
    for (SMBFriendRequest *friendRequest in self.objects)
        if (!friendRequest.fromUser.name)
            [objectsToRemove addObject:friendRequest];
    
    if (objectsToRemove.count > 0)
        NSLog(@"%@: Found %ld bad friend requests! Deleting...", [self class], (long)objectsToRemove.count);
    
    for (SMBFriendRequest *badFriendRequest in objectsToRemove)
    {
        [self removeObject:badFriendRequest];
        [badFriendRequest deleteInBackground];
    }
}


@end
