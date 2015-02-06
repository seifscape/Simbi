//
//  MBProgressHUD+Simbi.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "MBProgressHUD+Simbi.h"

#import <objc/runtime.h>


@implementation MBProgressHUD (Simbi)


#pragma mark - Objective-C Sorcery

static const void * PARENT_KEY;

@dynamic parent;

- (void)setParent:(id)parent
{
    objc_setAssociatedObject(self, &PARENT_KEY, parent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)parent
{
    return objc_getAssociatedObject(self, &PARENT_KEY);
}


#pragma mark - Custom Methods

+ (MBProgressHUD *)HUDwithMessage:(NSString *)message parent:(UIViewController *)parent
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:parent.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud setLabelText:message];
    
    hud.parent = parent;
    
    [hud enableParent:@NO];
    
    return hud;
}


+ (void)showMessage:(NSString *)message parent:(UIViewController *)parent
{
    // show hud and lock screen, but dismiss after delay
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:parent.view animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:message];
    
    hud.parent = parent;
    
    [hud enableParent:@NO];
    
    [hud performSelector:@selector(dismissQuickly) withObject:nil afterDelay:kHUDHideTime];
}


- (void)dismissQuickly
{
    [self hide:YES];
    
    [self enableParent:@YES];
}


- (void)dismissWithSuccess
{
    [self setMode:MBProgressHUDModeText];
    [self setLabelText:@"Success!"];
    [self hide:YES afterDelay:kHUDHideTime];
    
    [self performSelector:@selector(enableParent:) withObject:@YES afterDelay:kHUDHideTime];
}


- (void)dismissWithError
{
    [self setMode:MBProgressHUDModeText];
    [self setLabelText:kHUDErrorMessage];
    [self hide:YES afterDelay:kHUDHideTime];
    
    [self performSelector:@selector(enableParent:) withObject:@YES afterDelay:kHUDHideTime];
}


- (void)dismissWithMessage:(NSString *)message
{
    [self setMode:MBProgressHUDModeText];
    [self setLabelText:message];
    [self hide:YES afterDelay:kHUDHideTime];
    
    [self performSelector:@selector(enableParent:) withObject:@YES afterDelay:kHUDHideTime];
}


- (void)enableParent:(NSNumber *)enabled
{
    if ([[self.parent class] isSubclassOfClass:[UIViewController class]] || [[self.parent class] isSubclassOfClass:[UITableViewController class]])
    {
        UIViewController *parent = self.parent; // cast id to UIViewController
        
        [parent.view setUserInteractionEnabled:enabled.boolValue];
        [parent.navigationController.navigationBar setUserInteractionEnabled:enabled.boolValue];
        [parent.navigationController.toolbar setUserInteractionEnabled:enabled.boolValue];
        
        if ([[self.parent class] isSubclassOfClass:[UITableViewController class]])
        {
            [((UITableViewController *)parent).tableView setScrollEnabled:enabled.boolValue];
            [((UITableViewController *)parent).tableView setUserInteractionEnabled:enabled.boolValue];
        }
    }
    else
        NSLog(@"%s : WARNING! Parent is not a subclass of UIViewController", __PRETTY_FUNCTION__);
}


@end
