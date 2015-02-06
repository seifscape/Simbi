//
//  MBProgressHUD+Simbi.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "MBProgressHUD.h"

#define kHUDHideTime 1.25f
#define kHUDFont @""
#define kHUDErrorMessage @"Network Error: Please Try Again"

@interface MBProgressHUD (Simbi)

@property (nonatomic, retain) id parent;

+ (MBProgressHUD *)HUDwithMessage:(NSString *)message parent:(UIViewController *)parent;
+ (void)showMessage:(NSString *)message parent:(UIViewController *)parent;

- (void)dismissQuickly;
- (void)dismissWithSuccess;
- (void)dismissWithError;
- (void)dismissWithMessage:(NSString *)message;

@end
