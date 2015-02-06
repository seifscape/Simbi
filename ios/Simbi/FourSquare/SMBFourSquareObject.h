//
//  SMBFourSquareObject.h
//  Simbi
//
//  Created by Patrick Sutton on 6/3/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

#import "SMBFourSquareLocation.h"

@interface SMBFourSquareObject : NSObject

+ (void)getLocationsForGeoPoint: (PFGeoPoint *) geoPoint callback:(void (^)(SMBFourSquareObject *object, NSError *error))callback;

@property (nonatomic, strong) id JSONresponse;
@property (nonatomic, strong) SMBFourSquareLocation *location;
@property (nonatomic, strong) NSArray *locations;

@end
