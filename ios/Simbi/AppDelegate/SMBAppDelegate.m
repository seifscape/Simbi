//
//  SMBAppDelegate.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBAppDelegate.h"

#import "MMDrawerController.h"

#import "SMBChatViewController.h"
#import "_SMBFriendsListViewController.h"
#import "SMBSideMenuViewController.h"
#import "SMBFriendsManager.h"
#import "SMBFriendRequestsManager.h"
#import "SMBActivityManager.h"
#import "MMDrawerVisualState.h"

#import "Simbi-Swift.h"


@interface SMBAppDelegate ()

@property (nonatomic, strong) MMDrawerController *drawerController;

@end


@implementation SMBAppDelegate

+ (SMBAppDelegate *)instance
{
    return (SMBAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (BOOL)isAtHomeOrChat
{
    if ([_drawerController.centerViewController isKindOfClass:[UINavigationController class]]
        || [_drawerController.centerViewController isKindOfClass:[SMBChatViewController class]])
    {
        UINavigationController *navController = (UINavigationController *)_drawerController.centerViewController;
        
        if ([navController.visibleViewController isKindOfClass:[SMBMainViewController class]])
            return YES;
    }
    
    return NO;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set up Parse
    
    [SMBActivity registerSubclass];
    [SMBChallenge registerSubclass];
    [SMBChat registerSubclass];
    [SMBFriendRequest registerSubclass];
    [SMBHairColor registerSubclass];
    [SMBImage registerSubclass];
    [SMBLocation registerSubclass];
    [SMBMessage registerSubclass];
    [SMBQuestion registerSubclass];
    [SMBReceipt registerSubclass];
    [SMBUser registerSubclass];
    [SMBUserCredits registerSubclass];
    [SMBUserPrivate registerSubclass];
    
    [Parse setApplicationId:kParseAppId clientKey:kParseClientKey];
    
    [SMBPurchase registerPurchases];
    
    // Set up Facebook
    
    [PFFacebookUtils initializeFacebook];
    
    // Set up pushes
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert)];
    }
    
    // Custom appearance
        
    [[UINavigationBar appearance] setBarTintColor:[UIColor simbiWhiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor simbiBlueColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSFontAttributeName:            [UIFont simbiBoldFontWithSize:18.f],
                                                            NSForegroundColorAttributeName: [UIColor blackColor] } ];
    
    [[UIToolbar appearance] setBarTintColor:[UIColor simbiBlueColor]];
    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
    
    // This will keep the back button titleless by pushing it away. If the title of the last view was too long, however, the
    // current view's title will be pushed aside.
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000)
                                                         forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTintColor:[UIColor simbiBlueColor]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSFontAttributeName: [UIFont simbiFontWithSize:18.f] } forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{ NSFontAttributeName: [UIFont simbiFontWithSize:16.f] } forState:UIControlStateNormal];
    
    [[UITextField appearance] setTextColor:[UIColor simbiDarkGrayColor]];
    [[UITextField appearance] setTintColor:[UIColor simbiDarkGrayColor]];
    
    
    
    
    // Start up the managers
    
    [SMBActivityManager sharedManager]; // Will load after friends
    [[SMBFriendsManager sharedManager] loadObjects:nil];
    [[SMBFriendRequestsManager sharedManager] loadObjects:nil];
    [[SMBChatManager sharedManager] loadObjects:nil];
    
    
    // Set up side menu
    
    SMBSideMenuViewController *sideMenuViewController = [[SMBSideMenuViewController alloc] init];
    
    _drawerController = [[MMDrawerController alloc] initWithCenterViewController:[[UIViewController alloc] init] leftDrawerViewController:sideMenuViewController];
    
    [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    SMBAppDelegate __weak *weakSelf = self;
    [_drawerController setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture)
    {
        // The following block will call "viewWillAppear" on an SMBMainViewController if it is visible. This is because
        // the menu and chat buttons on that view are added to the main window and need to be hidden manually (which I'm
        // not fond of - I'm not arguing over dumb UI requests though..)
        
        if (weakSelf)
        {
            id visible = ((UINavigationController *)weakSelf.drawerController.centerViewController).visibleViewController;
            
            if ([visible isKindOfClass:[SMBMainViewController class]])
                [((SMBMainViewController *)visible) viewWillAppear:YES];
        }
    }];
    
    
    [_drawerController setDrawerVisualStateBlock:[MMDrawerVisualState slideAndScaleVisualStateBlock]];
    
    if ([SMBUser exists])
    {
        if (![SMBUser currentUser].isConfirmed)
        {
            SMBEnterViewController *viewController = [[SMBEnterViewController alloc] init];
            [self setCenterViewController:viewController];
            [viewController pushToConfirmPhone];
        }
        else
            [self setCenterViewController:[[SMBMainViewController alloc] init]];
    }
    else
    {
        [self setCenterViewController:[[SMBEnterViewController alloc] init]];
    }
    
    
    // Create Window and launch
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor simbiWhiteColor]];
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:_drawerController];
    
    
    return YES;
}


#pragma mark - Side Menu Methods

- (void)animateToMain
{
    [_drawerController closeDrawerAnimated:NO completion:nil];
    
    SMBMainViewController *viewController = [[SMBMainViewController alloc] init];
    SMBNavigationController *navigationController = [[SMBNavigationController alloc] initWithRootViewController:viewController];
    
    [navigationController.view setAlpha:0.f];
    
    CGFloat width  = _drawerController.centerViewController.view.frame.size.width;
    CGFloat height = _drawerController.centerViewController.view.frame.size.height;
    
    [UIView animateWithDuration:0.35f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [_drawerController.centerViewController.view setFrame:CGRectMake(0, height, width, height)];
        
    } completion:^(BOOL finished) {
        
        [_drawerController setCenterViewController:navigationController];
        
        [UIView animateWithDuration:0.25f delay:0.05f options:UIViewAnimationOptionCurveLinear animations:^{
            [navigationController.view setAlpha:1.f];
        } completion:nil];
    }];
    
}


- (void)setCenterViewController:(UIViewController *)centerViewController
{
    SMBNavigationController *nav = [[SMBNavigationController alloc] initWithRootViewController:centerViewController];
    [nav setShowsMenu:YES];
    [nav setShowsChat:YES];
    
//    // Give the "root" view controller a menu button on the left
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
//    [centerViewController.navigationItem setLeftBarButtonItem:menuButton];
    
    [_drawerController setCenterViewController:nav];
    
    [_drawerController closeDrawerAnimated:YES completion:nil];
}


- (void)presentViewControllerFromCenter:(UIViewController *)viewController
{
    [_drawerController closeDrawerAnimated:YES completion:nil];
    [_drawerController.centerViewController presentViewController:viewController animated:YES completion:nil];
}


- (void)showMenu
{
    [_drawerController.centerViewController.view endEditing:YES];
    
    if (_drawerController.openSide == MMDrawerSideNone)
        [_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    else
        [_drawerController closeDrawerAnimated:YES completion:nil];
}


- (void)enableSideMenuGesture:(BOOL)enable
{
    if (enable)
        [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    else
        [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
}


#pragma mark - Parse Methods

- (void)syncUserInstallation
{
    PFInstallation *installation = [PFInstallation currentInstallation];
    
    if ([SMBUser exists])
    {
        if (!installation[@"user"])
        {
            NSLog(@"%s - WARNING: User not synced to current installation! Syncing...", __PRETTY_FUNCTION__);
            [installation setObject:[SMBUser currentUser] forKey:@"user"];
            [installation saveInBackground];
        }
        else if (![[SMBUser currentUser].objectId isEqualToString:((PFObject *)installation[@"user"]).objectId])
        {
            NSLog(@"%s - WARNING: User not synced to current installation! Syncing...", __PRETTY_FUNCTION__);
            [installation setObject:[SMBUser currentUser] forKey:@"user"];
            [installation saveInBackground];
        }
    }
    else if (installation[@"user"])
    {
        NSLog(@"%s - WARNING: User synced to current installation when there is no current user! Removing...", __PRETTY_FUNCTION__);
        [installation removeObjectForKey:@"user"];
        [installation saveInBackground];
    }
}


#pragma mark - Facebook Methods

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}


#pragma mark - Push Notification Handling

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation setChannels:[NSArray arrayWithObject:@"test"]];
    [currentInstallation saveInBackground];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Push received: %@", userInfo);
    
    
    // If inactive, don't handle it
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
    {
        NSLog(@"Application Inactive. Ignoring Push Notification");
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    
    if ([userInfo[@"pushType"] isEqualToString:@"MessageReceived"])
    {
        if (![self isAtHomeOrChat])
        {
            [[SMBUser currentUser] setUnreadMessageCount:[NSNumber numberWithInt:[SMBUser currentUser].unreadMessageCount.intValue+1]];
            [[SMBUser currentUser] setHasNewMessage:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationMessageReceived object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationShowChatIcon object:nil];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"QuestionReceived"])
    {
        if (![self isAtHomeOrChat])
        {
            [[SMBUser currentUser] setUnreadMessageCount:[NSNumber numberWithInt:[SMBUser currentUser].unreadMessageCount.intValue+1]];
            [[SMBUser currentUser] setHasNewMessage:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationQuestionReceived object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationShowChatIcon object:nil];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"ChallengeReceived"])
    {
        if (![self isAtHomeOrChat])
        {
            [[SMBUser currentUser] setUnreadMessageCount:[NSNumber numberWithInt:[SMBUser currentUser].unreadMessageCount.intValue+1]];
            [[SMBUser currentUser] setHasNewMessage:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationChallengeReceived object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationShowChatIcon object:nil];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"ChallengeAction"])
    {
        if (![self isAtHomeOrChat])
        {
            [[SMBUser currentUser] setUnreadMessageCount:[NSNumber numberWithInt:[SMBUser currentUser].unreadMessageCount.intValue+1]];
            [[SMBUser currentUser] setHasNewMessage:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationChallengeAction object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationShowChatIcon object:nil];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"ChatRevealed"])
    {
        if (![self isAtHomeOrChat])
        {
            [[SMBUser currentUser] setUnreadMessageCount:[NSNumber numberWithInt:[SMBUser currentUser].unreadMessageCount.intValue+1]];
            [[SMBUser currentUser] setHasNewMessage:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationChatRevealed object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationShowChatIcon object:nil];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"ChatRemoved"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationChatRemoved object:nil userInfo:userInfo];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"ChallengeAccepted"])
    {
        if (![self isAtHomeOrChat])
        {
            [[SMBUser currentUser] setUnreadMessageCount:[NSNumber numberWithInt:[SMBUser currentUser].unreadMessageCount.intValue+1]];
            [[SMBUser currentUser] setHasNewMessage:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationChallengeAccepted object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationShowChatIcon object:nil];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"QuestionAccepted"])
    {
        if (![self isAtHomeOrChat])
        {
            [[SMBUser currentUser] setUnreadMessageCount:[NSNumber numberWithInt:[SMBUser currentUser].unreadMessageCount.intValue+1]];
            [[SMBUser currentUser] setHasNewMessage:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationQuestionAccepted object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationShowChatIcon object:nil];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"UserStartedTyping"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationUserStartedTyping object:nil userInfo:userInfo];
        
        completionHandler(UIBackgroundFetchResultNoData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"UserStoppedTyping"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationUserStoppedTyping object:nil userInfo:userInfo];
        
        completionHandler(UIBackgroundFetchResultNoData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"FriendRequestReceived"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationFriendRequestReceived object:nil userInfo:userInfo];
        
        // Check to see if SMBFriendsListVC is in the navigation stack. If it is, don't do anything since that view will handle the
        // new request. If not, prompt the user with an alertView and ask if they would like to go to the friends list.
        
        if ([_drawerController.centerViewController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navController = (UINavigationController *)_drawerController.centerViewController;
            
            BOOL hasFriendsList = NO;
            
            for (UIViewController *viewController in navController.viewControllers)
                if ([viewController isKindOfClass:[_SMBFriendsListViewController class]])
                    hasFriendsList = YES;
            
            if (hasFriendsList)
            {
                completionHandler(UIBackgroundFetchResultNewData);
                return;
            }
        }
        
        // No SMBFriendsListVC, ask them if they want to go to it instead.
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Friend Request" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go to Friends", nil];
        [alertView show];
        
        completionHandler(UIBackgroundFetchResultNoData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"FriendRequestAccepted"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationFriendRequestAccepted object:nil userInfo:userInfo];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Friend Request" message:userInfo[@"aps"][@"alert"] delegate:nil cancelButtonTitle:@"Neat!" otherButtonTitles:nil];
        [alertView show];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"ChatDeclined"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationChatDeclined object:nil userInfo:userInfo];
        
        completionHandler(UIBackgroundFetchResultNoData);
    }
    else if ([userInfo[@"pushType"] isEqualToString:@"CheckInActivity"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationCheckInActivity object:nil userInfo:userInfo];
        
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else
        completionHandler(UIBackgroundFetchResultNoData);
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
    {
        // User wants to go to friends
        
        _SMBFriendsListViewController *viewController = [[_SMBFriendsListViewController alloc] init];
        [self setCenterViewController:viewController];
    }
}


#pragma mark - UIApplicationDelegate

- (void)applicationWillEnterForeground:(UIApplication *)application
{    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationWillEnterForeground object:nil];
    
    [[SMBFriendsManager sharedManager] loadObjects:nil];
    
    if ([SMBUser exists])
    {
        [[SMBUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            [self syncUserInstallation];
            
            if ([SMBUser currentUser].hasNewMessage)
                [[NSNotificationCenter defaultCenter] postNotificationName:kSMBNotificationShowChatIcon object:nil];
        }];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application { }
- (void)applicationDidEnterBackground:(UIApplication *)application { }
- (void)applicationWillTerminate:(UIApplication *)application { }


@end
