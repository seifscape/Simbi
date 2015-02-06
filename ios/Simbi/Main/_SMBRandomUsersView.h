//
//  SMBRandomUsersView.h
//  Simbi
//
//  Created by flynn on 5/29/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "iCarousel.h"


@class _SMBRandomUsersView;

@protocol _SMBRandomUsersViewDelegate
- (void)randomUsersView:(_SMBRandomUsersView *)randomUsersView didSelectUserForChallenge:(SMBUser *)user;
- (void)randomUsersView:(_SMBRandomUsersView *)randomUsersView didSelectUserForQuestion:(SMBUser *)user;
@end


@class _SMBMainViewController;

@interface _SMBRandomUsersView : UIView <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, weak) id <_SMBRandomUsersViewDelegate> randomUsersViewDelegate;

- (id)initWithFrame:(CGRect)frame;

- (void)showBottomView;
- (void)hideBottomView;

@end
