//
//  SMBManager.m
//  Simbi
//
//  Created by flynn on 6/26/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBManager.h"


@interface SMBManager ()

- (PFQuery *)query;
- (void)objectsDidLoad;

@property (nonatomic, strong) NSPointerArray *delegates;

@property (nonatomic, strong) NSArray *objects;

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSArray *includes;
@property (nonatomic, strong) NSString *orderKey;
@property (nonatomic) NSComparisonResult comparisonResult;

@end


@implementation SMBManager

#pragma mark - Singleton Lifecycle

+ (instancetype)sharedManager
{
    NSAssert(NO, @"%s - +[SMBManager sharedManager] must be overridden!", __PRETTY_FUNCTION__);
    return nil;
}


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _delegates = [NSPointerArray weakObjectsPointerArray];
        
        _objects = [NSArray new];
        _isLoading = NO;
        _errorLoadingObjects = NO;
        
        _comparisonResult = NSOrderedAscending;
    }
    
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public Methods

- (void)registerClassName:(NSString *)className includes:(NSArray *)array orderKey:(NSString *)orderKey
{
    _className = className;
    _includes = array;
    _orderKey = orderKey;
}


- (void)setOrder:(NSComparisonResult)order
{
    _comparisonResult = order;
}


- (PFQuery *)query
{
    NSAssert(NO, @"%s - -[SMBManager query] must be overridden!", __PRETTY_FUNCTION__);
    return nil;
}


- (void)loadObjects:(void(^)(BOOL success))callback
{
    if ([SMBUser exists])
    {
        _isLoading = YES;
        
        PFQuery *query = [self query];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            _isLoading = NO;
            
            if (objects)
            {
                _objects = objects;
                _errorLoadingObjects = NO;
                
                if ([_className isEqualToString:@"Chat"])
                    [SMBChat drawConnectionsForChatsInArray:_objects];

                [self objectsDidLoad];
                [self updateDelegates];
                
                if (callback)
                    callback(YES);
            }
            else
            {
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                _errorLoadingObjects = YES;
                
                for (id<SMBManagerDelegate> delegate in _delegates)
                    [delegate manager:self didFailToLoadObjects:error];
                
                if (callback)
                    callback(NO);
            }
        }];
    }
    else
    {
        _objects = [NSArray new];
        _isLoading = NO;
        _errorLoadingObjects = NO;

        [self updateDelegates];
        
        if (callback)
            callback(YES);
    }
}


- (void)objectsDidLoad
{
    
}


- (void)clearObjects
{
    _objects = [NSArray new];
    _errorLoadingObjects = NO;
}


- (void)addObject:(PFObject *)object
{
    NSMutableArray *objects = [NSMutableArray arrayWithArray:_objects];
    
    if (_orderKey)
    {
        // Insert sorted if an order key's been set
        
        int i;
        
        for (i = 0; i < objects.count; i++)
        {
            PFObject *existingObject = [objects objectAtIndex:i];
            
            if ([object[_orderKey] compare:existingObject[_orderKey]] == _comparisonResult)
                break;
        }
        
        if (i == objects.count)
            [objects addObject:object];
        else
            [objects insertObject:object atIndex:i];
    }
    else
        [objects addObject:object];
    
    if ([_className isEqualToString:@"Chat"])
        [SMBChat drawConnectionsForChatsInArray:objects];
        
    _objects = [NSArray arrayWithArray:objects];
    
    [self updateDelegates];
}


- (void)addObjectWithId:(NSString *)userId
{
    PFQuery *query = [PFQuery queryWithClassName:_className];
    
    for (NSString *include in _includes)
        [query includeKey:include];
    
    [query getObjectInBackgroundWithId:userId block:^(PFObject *object, NSError *error) {
        
        if (object)
        {
            [self addObject:object];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
        }
    }];
}


- (void)removeObject:(PFObject *)object
{
    NSMutableArray *objects = [NSMutableArray arrayWithArray:_objects];
    [objects removeObject:object];
    _objects = [NSArray arrayWithArray:objects];
    
    [self updateDelegates];
}


- (void)removeObjectWithId:(NSString *)objectId
{
    PFObject *objectToRemove;
    
    for (PFObject *object in _objects)
        if ([object.objectId isEqualToString:objectId])
            objectToRemove = object;
    
    if (objectToRemove)
        [self removeObject:objectToRemove];
}


- (void)addDelegate:(id)delegate
{
    [_delegates addPointer:(__bridge void *)delegate];
}


- (void)cleanDelegates
{
    NSMutableArray *indicies = [NSMutableArray new];
    
    for (int i = 0; i < _delegates.count; i++)
        if ([_delegates pointerAtIndex:i] == nil)
            [indicies addObject:[NSNumber numberWithInt:i]];
        
    for (int i = (int)indicies.count-1; i >= 0; i--)
        [_delegates removePointerAtIndex:((NSNumber *)[indicies objectAtIndex:i]).intValue];
}


- (void)updateDelegates
{
    for (id<SMBManagerDelegate> delegate in _delegates)
        [delegate manager:self didUpdateObjects:_objects];
}


@end
