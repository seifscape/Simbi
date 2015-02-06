//
//  SMBFourSquareCategory.m
//  Simbi
//
//  Created by flynn on 6/26/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBFourSquareCategory.h"

#import "AFNetworking.h"


@interface SMBFourSquareCategory ()

@property (nonatomic, strong) NSArray *categories;

@end


@implementation SMBFourSquareCategory


+ (SMBFourSquareCategory *)instance
{
    // Singleton for this class since we only need one reference of the categories
    
    static SMBFourSquareCategory *fourSquareCategory = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        fourSquareCategory = [[self alloc] init];
    });
    
    return fourSquareCategory;
}


- (void)loadCategories:(void(^)(BOOL succeeded))callback
{
    if (_categories && _categories.count > 0)
    {
        // If already loaded, don't bother reloading
        
        callback(YES);
    }
    else
    {
        // Query all of the categories from FourSquare
        
        static NSString *baseURLString = @"https://api.foursquare.com/v2/venues/categories?";
        static NSString *client_id = @"client_id=HX243DGACCYXV0FWAVBCB4LKXEB2JQNPW0YYU3QPDJTIWTK1";
        static NSString *client_secret = @"&client_secret=0CAZZHWWHY4UH2IS0MM44K4413URQI2KRDBLJQHJRGJ4ZNQZ&v=20130815";
        
        NSString *requestURLString = [NSString stringWithFormat:@"%@%@%@", baseURLString, client_id, client_secret];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager GET:requestURLString
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 NSArray *topLevelCategories = responseObject[@"response"][@"categories"];
                 
                 NSMutableArray *categories = [NSMutableArray new];
                 
                 for (NSDictionary *topLevelCategory in topLevelCategories)
                 {
                     // Add all of the subcategories in each top-level category to an array
                     
                     NSMutableArray *subcategoryIds = [NSMutableArray new];
                     
                     [self addCategoryIdsFromArray:topLevelCategory[@"categories"] toArray:subcategoryIds];
                     
                     // Stuff it in a dictionary
                     
                     NSDictionary *topLevelDict = @{ @"id": topLevelCategory[@"id"],
                                                     @"name": topLevelCategory[@"name"],
                                                     @"pluralName": topLevelCategory[@"pluralName"],
                                                     @"subcategoryIds": subcategoryIds };
                     
                     [categories addObject:topLevelDict];
                 }
                 
                 _categories = [NSArray arrayWithArray:categories];
                 
                 callback(YES);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 _categories = nil;
                 callback(NO);
             }];
    }
}


- (void)addCategoryIdsFromArray:(NSArray *)array toArray:(NSMutableArray *)subcategoryIds
{
    for (NSDictionary *category in array)
    {
        [subcategoryIds addObject:category[@"id"]];
        
        // If there are more sub-sub-categories for this category, recursively add those ids as well
        if (category[@"categories"])
            [self addCategoryIdsFromArray:category[@"categories"] toArray:subcategoryIds];
    }
}


- (NSDictionary *)topLevelCategoryForCategoryId:(NSString *)categoryId
{
    for (NSDictionary *category in _categories)
    {
        if ([category[@"id"] isEqualToString:categoryId])
            return category;
        
        NSArray *subcategories = category[@"subcategoryIds"];
        
        for (NSString *subcategoryId in subcategories)
            if ([categoryId isEqualToString:subcategoryId])
                return category;
    }
    
    return nil;
}

@end
