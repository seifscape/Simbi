//
//  SMBFourSquareVenue.h
//  Simbi
//
//  Created by Patrick Sutton on 6/3/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface SMBFourSquareLocation : NSObject

- (id)initWithVenueEntry: (NSDictionary *)venueEntry;

@property (nonatomic, strong) NSString *fourSquareId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic, strong) NSArray *categories;

@end
