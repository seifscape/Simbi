//
//  SMBManagerTableView.h
//  Simbi
//
//  Created by flynn on 7/2/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBManager.h"


@class SMBManagerTableView;

@protocol SMBManagerTableViewDelegate
- (void)managerTableView:(SMBManagerTableView *)tableView didSelectObject:(id)object;
@end


@interface SMBManagerTableView : UITableView <SMBManagerDelegate, UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style manager:(SMBManager *)manager;

- (void)showNoResultsLabel:(BOOL)shouldShow;
- (void)showErrorLabel:(BOOL)shouldShow;

- (void)setNoResultsMessage:(NSString *)noResultsMessage;
- (void)setErrorMessage:(NSString *)errorMessage;

@property (nonatomic, weak) SMBManager *manager;

@property (nonatomic, strong) NSArray *objects;

@property (nonatomic, weak) id<SMBManagerTableViewDelegate> managerDelegate;

@end
