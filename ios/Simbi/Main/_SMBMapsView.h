//
//  SMBMapsView.h
//  Simbi
//
//  Created by flynn on 5/29/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@import CoreLocation;
@import MapKit;

#import "_SMBAnnotation.h"
#import "SMBManager.h"


@class _SMBMainViewController;

@interface _SMBMapsView : UIView <MKMapViewDelegate, SMBAnnotationDelegate, SMBManagerDelegate, CLLocationManagerDelegate>

- (id)initWithFrame:(CGRect)frame parent:(_SMBMainViewController *)parent;
- (void)hideFriendCardAction:(UIButton *)button;

@end
