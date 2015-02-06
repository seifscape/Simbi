//
//  SMBFriendsListViewController.h
//  Simbi
//
//  Created by flynn on 5/27/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBManagerTableView.h"


@interface _SMBFriendsListViewController : UIViewController <SMBManagerTableViewDelegate>

- (void)updateRequestCountWithNumber:(NSInteger)requestCount;

- (void)findFriendsAction;
- (void)facebookFriendsAction;

@end
