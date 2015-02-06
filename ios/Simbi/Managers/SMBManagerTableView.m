//
//  SMBManagerTableView.m
//  Simbi
//
//  Created by flynn on 7/2/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBManagerTableView.h"


@interface SMBManagerTableView ()

@property (nonatomic, strong) UILabel *noResultsLabel;
@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic, strong) NSString *noResultsMessage;
@property (nonatomic, strong) NSString *errorMessage;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end


@implementation SMBManagerTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style manager:(SMBManager *)manager
{
    self = [super initWithFrame:frame style:style];
    
    if (self)
    {
        _manager = manager;
        
        [_manager addDelegate:self];
        
        [self setDataSource:self];
        [self setDelegate:self];
        
        _noResultsMessage = @"No Results";
        _errorMessage = @"Error Loading Objects";
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:refreshControl];
        
        if (manager.isLoading)
        {
            _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [_activityIndicatorView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [_activityIndicatorView startAnimating];
            [self addSubview:_activityIndicatorView];
        }
        else if (manager.errorLoadingObjects)
        {
            [self showErrorLabel:YES];
        }
        else
        {
            _objects = _manager.objects;
            
            [self showNoResultsLabel:(_objects.count == 0)];
        }
        
        [self reloadData];
    }
    
    return self;
}


- (void)dealloc
{
    [_manager cleanDelegates];
}


#pragma mark - User Actions

- (void)reloadAction:(UIRefreshControl *)refreshControl
{
    [self setUserInteractionEnabled:NO];
    
    [_manager loadObjects:^(BOOL success) {
        [self setUserInteractionEnabled:YES];
        [refreshControl endRefreshing];
    }];
}


#pragma mark - SMBManagerDelegate

- (void)manager:(SMBManager *)manager didUpdateObjects:(NSArray *)objects
{
    _objects = objects;
    
    if (_activityIndicatorView)
    {
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
        _activityIndicatorView = nil;
    }
    
    [self showNoResultsLabel:(objects.count == 0)];
    [self showErrorLabel:NO];
    
    [self reloadData];
}


- (void)manager:(SMBManager *)manager didFailToLoadObjects:(NSError *)error
{
    _objects = NO;
    
    [self showNoResultsLabel:NO];
    [self showErrorLabel:YES];
}


#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_objects)
        return _objects.count;
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_managerDelegate)
        [_managerDelegate managerTableView:self didSelectObject:[_objects objectAtIndex:indexPath.row]];
}


#pragma mark - Public Methods

- (void)showNoResultsLabel:(BOOL)shouldShow
{
    if (!_noResultsLabel)
    {
        _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-88)];
        [_noResultsLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_noResultsLabel setFont:[UIFont simbiLightFontWithSize:22.f]];
        [_noResultsLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_noResultsLabel];
    }
    
    [_noResultsLabel setText:_noResultsMessage];
    [_noResultsLabel setHidden:!shouldShow];
}


- (void)showErrorLabel:(BOOL)shouldShow
{
    if (!_errorLabel)
    {
        _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-88)];
        [_errorLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [_errorLabel setFont:[UIFont simbiLightFontWithSize:22.f]];
        [_errorLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_errorLabel];
    }
    
    [_errorLabel setText:_errorMessage];
    [_errorLabel setHidden:!shouldShow];
}


- (void)setNoResultsMessage:(NSString *)noResultsMessage
{
    _noResultsMessage = noResultsMessage;
    
    if (_noResultsLabel)
        [_noResultsLabel setText:noResultsMessage];
}


- (void)setErrorMessage:(NSString *)errorMessage
{
    _errorMessage = errorMessage;
    
    if (_errorLabel)
        [_errorLabel setText:errorMessage];
}


@end
