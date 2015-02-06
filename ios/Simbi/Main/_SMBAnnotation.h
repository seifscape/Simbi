//
//  SMBAnnotation.h
//  Simbi
//
//  Created by flynn on 6/20/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@import MapKit;


@class _SMBAnnotation;

@protocol SMBAnnotationDelegate
- (void)annotation:(_SMBAnnotation *)annotation didSelectUser:(SMBUser *)user;
@end



@interface _SMBAnnotation : NSObject <MKAnnotation>

- (instancetype)initWithUser:(SMBUser *)user;
- (MKAnnotationView *)annotationView;

@property (nonatomic, weak) id<SMBAnnotationDelegate> delegate;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
