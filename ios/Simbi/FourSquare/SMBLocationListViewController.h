//
//  SMBLocationListViewController.h
//  Simbi
//
//  Created by flynn on 7/25/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBFourSquareLocation;


@interface SMBLocationListViewController : UITableViewController <UIAlertViewDelegate>

- (instancetype)initWithCategory:(NSString *)category locations:(NSArray *)locations;

@end
