//
//  SMBFourSquareObject.m
//  Simbi
//
//  Created by Patrick Sutton on 6/3/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFourSquareObject.h"
#import "SMBFourSquareCategory.h"


@implementation SMBFourSquareObject

static NSString *baseURLString = @"https://api.foursquare.com/v2/venues/search?";
static NSString *client_id = @"client_id=4PGTU4NDUW1TCJVCUCIUG1XMJLIOWYNWBMXAVBGMT3PQSXJY";
static NSString *client_secret = @"&client_secret=NTOSULA5PDA051DYRJOHI4BMDBH2AAVWY1ZTE3N2B1ZEVU5W&v=20130815";

+ (void)getLocationsForGeoPoint:(PFGeoPoint *)geoPoint callback:(void (^)(SMBFourSquareObject *object, NSError *error))callback
{
    [[SMBFourSquareCategory instance] loadCategories:^(BOOL succeeded) {
        
        if (succeeded)
        {
            NSString *latLongString = [NSString stringWithFormat:@"ll=%f,%f&", geoPoint.latitude, geoPoint.longitude];
            NSString *requestURLString = [NSString stringWithFormat:@"%@%@%@%@", baseURLString, latLongString, client_id, client_secret];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            [manager GET:requestURLString
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     
                     NSDictionary *info = responseObject;
                 
                     SMBFourSquareObject *object = [[SMBFourSquareObject alloc] init];
                 
                     [object setJSONresponse: responseObject];
                 
                     NSMutableArray *locations = [NSMutableArray new];
                 
                     for(NSDictionary *location in info[@"response"][@"venues"])
                         [locations addObject:[[SMBFourSquareLocation alloc] initWithVenueEntry:location]];
                 
                     [object setLocations:[NSArray arrayWithArray:locations]];
                 
                     callback(object, nil);
                 
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                     callback(nil, error);
                 }
             ];
        }
        else
        {
            callback(nil, nil);
        }
    }];
}


@end
