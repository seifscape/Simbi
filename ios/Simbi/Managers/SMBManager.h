//
//  SMBManager.h
//  Simbi
//
//  Created by flynn on 6/26/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBManager;

@protocol SMBManagerDelegate
- (void)manager:(SMBManager *)manager didUpdateObjects:(NSArray *)objects;
- (void)manager:(SMBManager *)manager didFailToLoadObjects:(NSError *)error;
@end


@interface SMBManager : NSObject

+ (instancetype)sharedManager;

- (void)registerClassName:(NSString *)className includes:(NSArray *)array orderKey:(NSString *)orderKey;
- (void)setOrder:(NSComparisonResult)order;

- (void)loadObjects:(void(^)(BOOL success))callback;
- (void)clearObjects;

- (void)addObject:(PFObject *)object;
- (void)addObjectWithId:(NSString *)objectId;
- (void)removeObject:(PFObject *)object;
- (void)removeObjectWithId:(NSString *)objectId;

- (void)addDelegate:(id<SMBManagerDelegate>)delegate;
- (void)cleanDelegates; // Call this method in the delegate's dealloc to remove
- (void)updateDelegates;

@property (nonatomic, strong, readonly) NSArray *includes;
@property (nonatomic, strong, readonly) NSArray *objects;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL errorLoadingObjects;

@end
