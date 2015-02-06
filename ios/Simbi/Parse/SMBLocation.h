//
//  SMBLocation.h
//  Simbi
//
//  Created by flynn on 5/15/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>


@class SMBImage;


@interface SMBLocation : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *locationName;
@property (retain) PFGeoPoint *geoPoint;
@property (retain) SMBImage *image;

@end
