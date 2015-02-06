//
//  SMBActivityTableView.h
//  Simbi
//
//  Created by flynn on 7/2/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBManagerTableView.h"


@protocol SMBActivityDrawerDelegate;

@interface SMBActivityTableView : SMBManagerTableView

@property (nonatomic, weak) id<SMBActivityDrawerDelegate> activityDelegate;

@end
