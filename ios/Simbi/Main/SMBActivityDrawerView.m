//
//  SMBActivityDrawerView.m
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBActivityDrawerView.h"

#import "SMBActivityCell.h"
#import "SMBFriendsManager.h"

#import "Simbi-Swift.h"


@implementation SMBActivityDrawerView

- (id)initWithFrame:(CGRect)frame delegate:(id<SMBActivityDrawerDelegate>)delegate
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _activityTableView = [[SMBActivityTableView alloc] initWithFrame:CGRectMake(0,
                                                                                    88,
                                                                                    frame.size.width,
                                                                                    frame.size.height-44)];
        [_activityTableView setActivityDelegate:delegate];
        [self addSubview:_activityTableView];
        
        _friendsTableView = [[SMBFriendsListTableView alloc] initWithFrame:_activityTableView.frame];
        [_friendsTableView setActivityDelegate:delegate];
        [_friendsTableView setHidden:YES];
        [self addSubview:_friendsTableView];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake((self.frame.size.width-66)/2.f, 0, 66, 44)];
        [button addTarget:delegate action:@selector(toggleActivityDrawer) forControlEvents:UIControlEventTouchUpInside];
        [button.layer setShadowColor:[UIColor blackColor].CGColor];
        [button.layer setShadowOpacity:0.33f];
        [button.layer setShadowRadius:1.f];
        [button.layer setShadowOffset:CGSizeMake(1.f, 1.f)];
        
        // "Bullseye" view for button
        
        UIView *outerCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [outerCircleView setCenter:CGPointMake(button.frame.size.width/2.f, button.frame.size.height/2.f)];
        [outerCircleView setBackgroundColor:[UIColor simbiBlueColor]];
        [outerCircleView.layer setCornerRadius:outerCircleView.frame.size.width/2.f];
        [outerCircleView.layer setBorderColor:[UIColor simbiWhiteColor].CGColor];
        [outerCircleView.layer setBorderWidth:1.f];
        [outerCircleView.layer setShadowColor:[UIColor blackColor].CGColor];
        [outerCircleView.layer setShadowOffset:CGSizeMake(1, 1)];
        [outerCircleView.layer setShadowOpacity:0.25f];
        [outerCircleView setUserInteractionEnabled:NO];
        [button addSubview:outerCircleView];
        
        UIView *innerCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        [innerCircleView setCenter:CGPointMake(button.frame.size.width/2.f, button.frame.size.height/2.f)];
        [innerCircleView setBackgroundColor:[UIColor simbiGreenColor]];
        [innerCircleView.layer setCornerRadius:innerCircleView.frame.size.width/2.f];
        [innerCircleView setUserInteractionEnabled:NO];
        [button addSubview:innerCircleView];
        
        [self addSubview:button];
        
        
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
                       setDefaultTextAttributes:@{NSFontAttributeName:[UIFont simbiFontWithAttributes:kFontRegular size:14.f]}];
        
        // Add this behind the search bar because the search bar is slightly transparent and it's unclear how to unset
        UIView *searchBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 44)];
        [searchBarBackground setBackgroundColor:[UIColor simbiWhiteColor]];
        [self addSubview:searchBarBackground];
        
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 44)];
        [searchBar setDelegate:self];
        [searchBar setPlaceholder:@"Search for Friends"];
        [searchBar setTintColor:[UIColor simbiBlueColor]];
        [searchBar setBarTintColor:[UIColor simbiWhiteColor]];
        [searchBar.layer setBorderColor:[UIColor simbiWhiteColor].CGColor];
        [searchBar setShowsCancelButton:YES];
        [self addSubview:searchBar];
        
        
        // Lines to cover up the borders on the top and bottom of the search bar (can't get rid of them...)
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 1)];
        [topLine setBackgroundColor:[UIColor simbiWhiteColor]];
        [self addSubview:topLine];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 87, self.frame.size.width, 1)];
        [bottomLine setBackgroundColor:[UIColor simbiWhiteColor]];
        [self addSubview:bottomLine];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_friendsTableView setHidden:NO];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_friendsTableView filterUsers:searchText];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self endEditing:YES];
    
    [_friendsTableView setHidden:YES];
    [_friendsTableView filterUsers:@""];
    
    [searchBar setText:@""];
}


#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self setFrame:CGRectOffset(self.frame, 0, -keyboardHeight)];
                     }
                     completion:nil];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self setFrame:CGRectOffset(self.frame, 0, keyboardHeight)];
                     }
                     completion:nil];
}


@end
