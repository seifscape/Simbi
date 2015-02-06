//
//  SMBSelectChallengeViewController.h
//  Simbi
//
//  Created by flynn on 5/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "iCarousel.h"


@interface SMBSelectChallengeViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

- (id)initWithUser:(SMBUser *)user;

@end
