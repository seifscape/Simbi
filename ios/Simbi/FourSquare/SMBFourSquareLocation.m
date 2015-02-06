//
//  SMBFourSquareVenue.m
//  Simbi
//
//  Created by Patrick Sutton on 6/3/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFourSquareLocation.h"

@implementation SMBFourSquareLocation

- (id)initWithVenueEntry:(NSDictionary *)venueEntry
{
    self = [super init];
    
    if (self)
    {
        [self setFourSquareId:venueEntry[@"id"]];
        [self setName:venueEntry[@"name"]];
        [self setDistance:venueEntry[@"location"][@"distance"]];
        [self setCity:venueEntry[@"location"][@"city"]];
        [self setState:venueEntry[@"location"][@"state"]];
        [self setCategories:venueEntry[@"categories"]];
        
        NSString *lat = venueEntry[@"location"][@"lat"];
        NSString *lng = venueEntry[@"location"][@"lng"];
        
        PFGeoPoint *geoPoint = [[PFGeoPoint alloc] init];
        [geoPoint setLatitude:lat.doubleValue];
        [geoPoint setLongitude:lng.doubleValue];
        
        [self setGeoPoint:geoPoint];
    }
    return self;
}

@end
