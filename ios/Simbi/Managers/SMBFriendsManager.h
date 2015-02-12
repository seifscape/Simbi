//
//  SMBFriendsManager.h
//  Simbi
//
//  Created by flynn on 6/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBManager.h"


@interface SMBFriendsManager : SMBManager

- (NSArray *)friendsObjectIds;
+ (instancetype)sharedManager;
@end
