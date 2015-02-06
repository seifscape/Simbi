//
//  SMBRandomUsersView.m
//  Simbi
//
//  Created by flynn on 5/29/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBRandomUsersView.h"

#import "_SMBRandomUserItemView.h"
#import "_SMBMutualFriendsView.h"
#import "SMBUserView.h"
#import "SMBFriendsManager.h"

#import "Simbi-Swift.h"


@interface _SMBRandomUsersView ()

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *filteredUsers;
@property (nonatomic) SMBUserPreference preferenceMode;
@property (nonatomic, strong) iCarousel *carousel;

@property (nonatomic, strong) _SMBMutualFriendsView *mutualFriendsView;

@property (nonatomic, strong) UIButton *firstPreferenceButton;
@property (nonatomic, strong) UIButton *secondPreferenceButton;
@property (nonatomic, strong) UIButton *thirdPreferenceButton;

@property (nonatomic) CGFloat distance;

@property (nonatomic) BOOL carouselIsHidden;

@property (nonatomic, strong) UILabel *noResultsLabel;
@property (nonatomic, strong) UILabel *needToCheckInLabel;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *deselectButton;

@property (nonatomic, strong) UIView *sliderLabelView;

@property (nonatomic, strong) SMBUserView *selectedUserView;

@property (nonatomic) BOOL isViewingCarousel;

@end


@implementation _SMBRandomUsersView

static const CGFloat kFeetInMile = 5280;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Set default values
        
        _distance = [self distanceForSliderValue:4.f];
        
        _carouselIsHidden = YES;
        
        _preferenceMode = kSMBUserPreferenceNone;
        _isViewingCarousel = YES;
        
        
        // Set up views
        
        [self setClipsToBounds:YES];
        [self setBackgroundColor:[UIColor simbiWhiteColor]];
        
        CGFloat width  = frame.size.width;
        CGFloat height = frame.size.height;
        
        BOOL is4inch = [UIScreen mainScreen].bounds.size.height > 480.f;
        
        
        // Carousel - have carousel go behind the status and nav bar to allow some vertical space between its views
        
        _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(66, 0, width-66, height)];
        [_carousel setDataSource:self];
        [_carousel setDelegate:self];
        [_carousel setVertical:YES];
        [_carousel setType:iCarouselTypeLinear];
        [_carousel setBounces:YES];
        [_carousel setAlpha:0.f];
        [_carousel setClipsToBounds:YES];
        [self addSubview:_carousel];

        
        _deselectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deselectButton setFrame:_carousel.frame];
        [_deselectButton addTarget:self action:@selector(deselectAction:) forControlEvents:UIControlEventTouchUpInside];
        [_deselectButton setHidden:YES];
        [self addSubview:_deselectButton];
        
        
        // Slider View
        
        UISlider *rangeSlider = [[UISlider alloc] init];
        [rangeSlider setTintColor:[UIColor simbiBlueColor]];
        [rangeSlider setMinimumValue:0];
        [rangeSlider setMaximumValue:9];
        [rangeSlider setValue:4];
        [rangeSlider addTarget:self action:@selector(rangeSliderDidChange:) forControlEvents:UIControlEventValueChanged];
        [rangeSlider addTarget:self action:@selector(rangeSliderDidFinish:) forControlEvents:UIControlEventTouchUpInside];
        
        // Make slider vertical
        [rangeSlider setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        [rangeSlider setFrame:CGRectMake(0, height/4.f, 66, height/2.f)];
        
        [self addSubview:rangeSlider];
        
        
        // Floating label next to the slider
        
        _sliderLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 38)];
        [_sliderLabelView setBackgroundColor:[UIColor simbiLightGrayColor]];
        [_sliderLabelView.layer setCornerRadius:4.f];
        [_sliderLabelView.layer setShadowColor:[UIColor blackColor].CGColor];
        [_sliderLabelView.layer setShadowOffset:CGSizeMake(2.f, 2.f)];
        [_sliderLabelView.layer setShadowOpacity:.25f];
        [_sliderLabelView setHidden:YES];
        
        UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 88, 36)];
        [sliderLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [sliderLabel setFont:[UIFont simbiFontWithSize:14.f]];
        [sliderLabel setTextAlignment:NSTextAlignmentCenter];
        [sliderLabel.layer setCornerRadius:4.f];
        [sliderLabel.layer setMasksToBounds:YES];
        [_sliderLabelView addSubview:sliderLabel];
        
        UIView *sliderPoint = [[UIView alloc] initWithFrame:CGRectMake(-4, 14, 8, 8)];
        [sliderPoint setBackgroundColor:[UIColor simbiLightGrayColor]];
        [sliderPoint setTransform:CGAffineTransformMakeRotation(M_PI_4)];
        [_sliderLabelView insertSubview:sliderPoint belowSubview:sliderLabel];
        
        [self addSubview:_sliderLabelView];
        
        
        // Bottom View
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height, width, (is4inch ? 44+88+20 : 88+32+8))];
        [_bottomView setBackgroundColor:[UIColor simbiWhiteColor]];
        
        UIButton *questionButton = [UIButton simbiBlueButtonWithFrame:CGRectMake(44, (is4inch ? 22 : 16), width-88, 44)];
        [questionButton setTitle:@"Answer Question" forState:UIControlStateNormal];
        [questionButton addTarget:self action:@selector(questionAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:questionButton];
        
        UIButton *challengeButton = [UIButton simbiRedButtonWithFrame:CGRectMake(44, questionButton.frame.origin.y+44+(is4inch ? 22 : 8), width-88, 44)];
        [challengeButton setTitle:@"Challenge" forState:UIControlStateNormal];
        [challengeButton addTarget:self action:@selector(challengeAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:challengeButton];
        
        [self addSubview:_bottomView];
        
        
        // No results label, hidden by default
        
        _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [_noResultsLabel setText:@"No Results!"];
        [_noResultsLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_noResultsLabel setFont:[UIFont simbiLightFontWithSize:22.f]];
        [_noResultsLabel setTextAlignment:NSTextAlignmentCenter];
        [_noResultsLabel setHidden:YES];
        [self addSubview:_noResultsLabel];
        
        _needToCheckInLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [_needToCheckInLabel setText:@"You need to check in first!"];
        [_needToCheckInLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_needToCheckInLabel setFont:[UIFont simbiLightFontWithSize:22.f]];
        [_needToCheckInLabel setTextAlignment:NSTextAlignmentCenter];
        [_needToCheckInLabel setNumberOfLines:2];
        [_needToCheckInLabel setHidden:YES];
        [self addSubview:_needToCheckInLabel];
        
        
        // Buttons
        
        CGFloat btnPad = 12;
        
        UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [helpButton setFrame:CGRectMake(width-btnPad-44, height-btnPad-44, 44, 44)];
        [helpButton setBackgroundColor:[[UIColor simbiWhiteColor] colorWithAlphaComponent:0.9f]];
        [helpButton setTitle:@"?" forState:UIControlStateNormal];
        [helpButton setTitleColor:[UIColor simbiGrayColor] forState:UIControlStateNormal];
        [helpButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:28.f]];
        [helpButton.layer setCornerRadius:helpButton.frame.size.width/2.f];
        [helpButton.layer setShadowOffset:CGSizeMake(1, 1)];
        [helpButton.layer setShadowColor:[UIColor blackColor].CGColor];
        [helpButton.layer setShadowOpacity:0.33f];
        [helpButton addTarget:self action:@selector(helpAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:helpButton];
        
        
        // Load the users
        
        [self loadUsers];
    }
    
    return self;
}


- (void)loadUsers
{
    [self hideCarousel];
    [_noResultsLabel setHidden:YES];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView setFrame:CGRectMake(0, 0, self.frame.size.width, _carousel.frame.size.height-44)];
    [activityIndicatorView startAnimating];
    [self addSubview:activityIndicatorView];
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    if ([SMBUser exists])
    {
        [query whereKey:@"objectId" notEqualTo:[SMBUser currentUser].objectId];
        if ([SMBUser currentUser].geoPoint)
            [query whereKey:@"geoPoint" nearGeoPoint:[SMBUser currentUser].geoPoint withinMiles:_distance];
    }
    [query includeKey:@"profilePicture"];
    [query includeKey:@"hairColor"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [activityIndicatorView stopAnimating];
        [activityIndicatorView removeFromSuperview];
        
        if (objects)
        {
            _users = objects;
            _filteredUsers = [NSArray arrayWithArray:_users];
            [self filterUsersForPreference:_preferenceMode];
        }
        else
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
    }];
}


- (void)showCarousel
{
    _carouselIsHidden = NO;
    
    [_carousel setUserInteractionEnabled:YES];
    
    [UIView animateWithDuration:0.25f animations:^{
        [_carousel setAlpha:1.f];
    }];
}


- (void)hideCarousel
{
    _carouselIsHidden = YES;
    
    [_carousel setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:0.25f animations:^{
        [_carousel setAlpha:0.5f];
    }];
}


- (void)animateCarousel
{
    [_mutualFriendsView hideFriends];
    [_carousel scrollByNumberOfItems:arc4random()%16+16 duration:0.66f];
}


- (void)showBottomView
{
    [_carousel setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:0.33f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_bottomView setFrame:CGRectMake(0, self.frame.size.height-_bottomView.frame.size.height, _bottomView.frame.size.width, _bottomView.frame.size.height)];
                         [_carousel setAlpha:0.f];
                     }
                     completion:^(BOOL finished) {
                         [_deselectButton setHidden:NO];
                     }];
}


- (void)hideBottomView
{
    [_deselectButton setHidden:YES];
    
    [UIView animateWithDuration:0.33f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [_bottomView setFrame:CGRectMake(0, self.frame.size.height, _bottomView.frame.size.width, _bottomView.frame.size.height)];
                         [_carousel setAlpha:1.f];
                     }
                     completion:^(BOOL finished) {
                         _isViewingCarousel = YES;
                         [_selectedUserView removeFromSuperview];
                         _selectedUserView = nil;
                         [_carousel setUserInteractionEnabled:YES];
                     }];
}


- (CGFloat)distanceForSliderValue:(CGFloat)value
{
    int val = floor(value);
    
    switch (val)
    {
        case 0: return  100/kFeetInMile;
        case 1: return  500/kFeetInMile;
        case 2: return 1000/kFeetInMile;
        case 3: return 1.f;
        case 4: return 2.f;
        case 5: return 3.f;
        case 6: return 4.f;
        case 7: return 5.f;
        default: return 10000.f;
    }
}


- (NSString *)stringForSliderValue:(CGFloat)value
{
    int val = floor(value);
    
    switch (val)
    {
        case 0: return @"100 Feet";
        case 1: return @"500 Feet";
        case 2: return @"1000 Feet";
        case 3: return @"1 Mile";
        case 4: return @"2 Miles";
        case 5: return @"3 Miles";
        case 6: return @"4 Miles";
        case 7: return @"5 Miles";
        default: return @"Everyone";
    }
}


#pragma mark - User Actions

- (void)helpAction:(UIButton *)button
{
    
}


- (void)questionAction
{
    if (!_carouselIsHidden)
    {
        SMBUser *selectedUser = [_filteredUsers objectAtIndex:_carousel.currentItemIndex%_filteredUsers.count];
        [_randomUsersViewDelegate randomUsersView:self didSelectUserForQuestion:selectedUser];
    }
}


- (void)challengeAction
{
    if (!_carouselIsHidden)
    {
        SMBUser *selectedUser = [_filteredUsers objectAtIndex:_carousel.currentItemIndex%_filteredUsers.count];
        [_randomUsersViewDelegate randomUsersView:self didSelectUserForChallenge:selectedUser];
    }
}


- (void)rangeSliderDidChange:(UISlider *)rangeSlider
{
    [_mutualFriendsView hideFriends];
    
    if (!_carouselIsHidden)
        [self hideCarousel];
    
    if (_sliderLabelView.hidden)
    {
        [_sliderLabelView setAlpha:0.f];
        [_sliderLabelView setHidden:NO];
        [UIView animateWithDuration:0.125f animations:^{
            [_sliderLabelView setAlpha:1.f];
        }];
    }
    
    CGFloat percentValue = 1-(rangeSlider.value-rangeSlider.minimumValue)/(rangeSlider.maximumValue-rangeSlider.minimumValue);
    
    [_sliderLabelView setFrame:CGRectMake(rangeSlider.frame.origin.x+rangeSlider.frame.size.width,
                                          rangeSlider.frame.origin.y+(rangeSlider.frame.size.height-36)*percentValue,
                                          _sliderLabelView.frame.size.width,
                                          _sliderLabelView.frame.size.height)];
    
    for (id subview in _sliderLabelView.subviews)
        if ([subview isKindOfClass:[UILabel class]])
            [((UILabel *)subview) setText:[self stringForSliderValue:rangeSlider.value]];
    
    _distance = [self distanceForSliderValue:rangeSlider.value];
}


- (void)rangeSliderDidFinish:(UISlider *)rangeSlider
{
    [self loadUsers];
    
    [UIView animateWithDuration:0.125f animations:^{
        [_sliderLabelView setAlpha:0.f];
    } completion:^(BOOL finished) {
        [_sliderLabelView setHidden:YES];
    }];
}


- (void)deselectAction:(UIButton *)button
{
    [self hideBottomView];
    [_carousel setUserInteractionEnabled:YES];
    [_deselectButton setHidden:YES];
}


- (void)preferenceAction:(UIButton *)button
{
    if (button.tag == 1)
    {
        if (_preferenceMode != kSMBUserPreferenceFirst)
            _preferenceMode = kSMBUserPreferenceFirst;
        else
            _preferenceMode = kSMBUserPreferenceNone;
    }
    else if (button.tag == 2)
    {
        if (_preferenceMode != kSMBUserPreferenceSecond)
            _preferenceMode = kSMBUserPreferenceSecond;
        else
            _preferenceMode = kSMBUserPreferenceNone;
    }
    else if (button.tag == 3)
    {
        if (_preferenceMode != kSMBUserPreferenceThird)
            _preferenceMode = kSMBUserPreferenceThird;
        else
            _preferenceMode = kSMBUserPreferenceNone;
    }
    
    [UIView animateWithDuration:0.125f animations:^{
        
        switch (_preferenceMode)
        {
            case kSMBUserPreferenceFirst:
                [_firstPreferenceButton setBackgroundColor:[UIColor simbiRedColor]];
                [_secondPreferenceButton setBackgroundColor:[UIColor simbiGrayColor]];
                [_thirdPreferenceButton setBackgroundColor:[UIColor simbiGrayColor]];
                break;
            case kSMBUserPreferenceSecond:
                [_firstPreferenceButton setBackgroundColor:[UIColor simbiGrayColor]];
                [_secondPreferenceButton setBackgroundColor:[UIColor simbiYellowColor]];
                [_thirdPreferenceButton setBackgroundColor:[UIColor simbiGrayColor]];
                break;
            case kSMBUserPreferenceThird:
                [_firstPreferenceButton setBackgroundColor:[UIColor simbiGrayColor]];
                [_secondPreferenceButton setBackgroundColor:[UIColor simbiGrayColor]];
                [_thirdPreferenceButton setBackgroundColor:[UIColor simbiGreenColor]];
                break;
            case kSMBUserPreferenceNone:
                [_firstPreferenceButton setBackgroundColor:[UIColor simbiRedColor]];
                [_secondPreferenceButton setBackgroundColor:[UIColor simbiYellowColor]];
                [_thirdPreferenceButton setBackgroundColor:[UIColor simbiGreenColor]];
                break;
        }
    }];
    
    [self filterUsersForPreference:_preferenceMode];
}


#pragma mark - Preference Filtering

- (void)filterUsersForPreference:(SMBUserPreference)preference
{
    if (preference == kSMBUserPreferenceNone)
    {
        _filteredUsers = [NSArray arrayWithArray:_users];
    }
    else
    {
        NSMutableArray *filteredUsers = [NSMutableArray new];
        
        for (SMBUser *user in _users)
            if ([user userPreference] == preference)
                [filteredUsers addObject:user];
        
        _filteredUsers = [NSArray arrayWithArray:filteredUsers];
    }
        
    if (_filteredUsers.count == 0)
    {
        [_noResultsLabel setHidden:NO];
    }
    else
    {
        [self showCarousel];
        [_noResultsLabel setHidden:YES];
        [self animateCarousel];
    }
    
    [_carousel reloadData];
}


#pragma mark - iCarouselDataSource/Delegate

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap) // Make the carousel scroll endlessly
        return 1.0f;
    else
        return value;
}


- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    if (_filteredUsers.count > 6) // 7+ don't need repeat views
        return _filteredUsers.count;
    else if (_filteredUsers.count > 3) // 6 -> 12, 5 -> 10, 4 -> 8...
        return _filteredUsers.count*2;
    else if (_filteredUsers.count == 3) // 3 -> 9
        return 9;
    else if (_filteredUsers.count == 2) // 2 -> 8
        return 8;
    else if (_filteredUsers.count == 1) // 1 is just 1
        return 1;
    else
        return 0;
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.width, 132)];
    
    SMBUser *user = [_filteredUsers objectAtIndex:index%_filteredUsers.count];
    
    BOOL isFriend = NO;
    
    for (SMBUser *existingFriend in [SMBFriendsManager sharedManager].objects)
        if ([user.objectId isEqualToString:existingFriend.objectId])
            isFriend = YES;
    
    CGFloat offset = [self itemOffsetForUser:user maxOffset:32];
    
    SMBUser *topUser = (index > 0 ? [_filteredUsers objectAtIndex:(index-1)%_filteredUsers.count] : [_filteredUsers lastObject]);
    SMBUser *bottomUser = [_filteredUsers objectAtIndex:(index+1)%_filteredUsers.count];
    
    CGFloat topOffset = [self itemOffsetForUser:topUser maxOffset:32];
    CGFloat bottomOffset = [self itemOffsetForUser:bottomUser maxOffset:32];
    
    _SMBRandomUserItemView *userView = [[_SMBRandomUserItemView alloc] initWithFrame:CGRectMake((carousel.frame.size.width-110)/2.f+offset,
                                                                                              0,
                                                                                              110,
                                                                                              132)
                                                                              user:user
                                                                        isRevealed:isFriend];
    [userView setCurrentOffset:offset topOffset:topOffset bottomOffset:bottomOffset];
    [userView setBackgroundColor:[self colorForUser:user]];
    [containerView addSubview:userView];
    
    return containerView;
}


- (CGFloat)itemOffsetForUser:(SMBUser *)user maxOffset:(int)maxOffset
{
    int x = 0;
    
    for (int i = 0; i < user.name.length; i++)
        x += [user.name characterAtIndex:i];
    for (int i = 0; i < user.name.length; i++)
        x += [user.email characterAtIndex:i];
    
    return x % (maxOffset*2) - maxOffset;
}


- (UIColor *)colorForUser:(SMBUser *)user
{
    int x = 0;
    
    for (int i = 0; i < user.name.length; i++)
        x += [user.name characterAtIndex:i];
    for (int i = 0; i < user.name.length; i++)
        x += [user.email characterAtIndex:i];
    
    switch (x % 3)
    {
        case 0:  return [UIColor simbiSkyBlueColor];
        case 1:  return [UIColor simbiYellowColor];
        case 2:  return [UIColor simbiRedColor];
        default: return [UIColor simbiGrayColor];
    }
}


- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
    [_mutualFriendsView hideFriends];
}


- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    if (_filteredUsers && carousel.currentItemIndex < _filteredUsers.count)
    {
        SMBUser *user = [_filteredUsers objectAtIndex:carousel.currentItemIndex%_filteredUsers.count];
        [_mutualFriendsView loadFriendsForUser:user];
    }
}


- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if (_isViewingCarousel)
    {
        _isViewingCarousel = NO;
        
        SMBUser *user = [_filteredUsers objectAtIndex:index%_filteredUsers.count];
        
        UIView *currentItemView = [_carousel currentItemView];
        
        _SMBRandomUserItemView *currentUserView;
        
        for (id subview in currentItemView.subviews)
            if ([subview isKindOfClass:[_SMBRandomUserItemView class]])
                currentUserView = subview;
        
        if (!currentUserView)
        {
            NSLog(@"%s - WARNING: No SMBUserView found in subviews!", __PRETTY_FUNCTION__);
            _isViewingCarousel = YES;
            return;
        }
        
        BOOL isFriend = NO;
        
        for (SMBUser *existingFriend in [SMBFriendsManager sharedManager].objects)
            if ([user.objectId isEqualToString:existingFriend.objectId])
                isFriend = YES;
        
        _selectedUserView = [[SMBUserView alloc] initWithFrame:CGRectMake((self.frame.size.width-currentUserView.frame.size.width)/2.f, currentUserView.frame.origin.y, currentUserView.frame.size.width, currentUserView.frame.size.height) isRevealed:isFriend];
        [_selectedUserView setUser:user];
        [_selectedUserView setUserInteractionEnabled:NO];
        [self addSubview:_selectedUserView];
        
        [self showBottomView];
    }
}


@end
