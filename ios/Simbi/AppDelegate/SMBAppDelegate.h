//
//  SMBAppDelegate.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBChat;
@class SMBChatViewController;


@interface SMBAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

+ (SMBAppDelegate *)instance;
- (BOOL)isAtHomeOrChat;

- (void)animateToMain;
- (void)setCenterViewController:(UIViewController *)centerViewController;
- (void)presentViewControllerFromCenter:(UIViewController *)viewController;
- (void)showMenu;
- (void)enableSideMenuGesture:(BOOL)enable;
- (void)syncUserInstallation;

@property (strong, nonatomic) UIWindow *window;

@end
