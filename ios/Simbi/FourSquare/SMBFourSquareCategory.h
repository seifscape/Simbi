//
//  SMBFourSquareCategory.h
//  Simbi
//
//  Created by flynn on 6/26/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface SMBFourSquareCategory : NSObject

+ (SMBFourSquareCategory *)instance;
- (void)loadCategories:(void(^)(BOOL succeeded))callback;
- (NSDictionary *)topLevelCategoryForCategoryId:(NSString *)categoryId;

@end
