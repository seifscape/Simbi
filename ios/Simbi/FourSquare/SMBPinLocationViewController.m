//
//  SMBPinLocationViewController.m
//  Simbi
//
//  Created by flynn on 7/25/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBPinLocationViewController.h"

#import "SMBFourSquareCategory.h"
#import "SMBFourSquareObject.h"
#import "SMBLocationListViewController.h"


@interface SMBPinLocationViewController ()

@property (nonatomic, strong) NSMutableDictionary *locations;
@property (nonatomic, strong) NSArray *categoryNames;

@property (nonatomic, strong) PFGeoPoint *geoPoint;

@property (nonatomic, strong) UILabel *errorLabel;

@end


@implementation SMBPinLocationViewController

static NSString *category_nightlife     = @"Nightlife";
static NSString *category_food          = @"Food";
static NSString *category_events        = @"Events";
static NSString *category_entertainment = @"Arts & Entertainment";
static NSString *category_other         = @"Other";
static NSString *cateogry_uncategorized = @"Uncategorized";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    [self.view setBackgroundColor:[UIColor simbiWhiteColor]];

    
    _categoryNames = @[category_nightlife,
                       category_food,
                       category_events,
                       category_entertainment,
                       category_other,
                       cateogry_uncategorized];
    
    _locations = [NSMutableDictionary new];
    
    for (NSString *category in _categoryNames)
        [_locations setObject:[NSMutableArray new] forKey:category];

    // Short delay before loading, since this view will usually have a transition before it.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadLocations];
    });
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setTitle:@"Pin Location"];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self setTitle:@""];
}


- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)loadLocations
{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicatorView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [activityIndicatorView startAnimating];
    [self.view addSubview:activityIndicatorView];
    
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        if (geoPoint)
        {
            _geoPoint = geoPoint;
            
            [SMBFourSquareObject getLocationsForGeoPoint:geoPoint callback:^(SMBFourSquareObject *object, NSError *error) {
                
                [activityIndicatorView stopAnimating];
                [activityIndicatorView removeFromSuperview];
                
                if (object)
                {
                    if (object.locations.count > 0)
                    {
                        [self sortLocations:object.locations];
                        [self showTiles];
                    }
                    [self showError:(object.locations.count == 0)];
                }
                else
                {
                    NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                    [self showError:YES];
                }
            }];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [self showError:YES];
            
            [activityIndicatorView stopAnimating];
            [activityIndicatorView removeFromSuperview];
        }
    }];
}


- (void)showError:(BOOL)shouldShow
{
    if (shouldShow)
    {
        if (!_errorLabel)
        {
            _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 132)];
            [_errorLabel setText:@"No Nearby Locations"];
            [_errorLabel setTextColor:[UIColor simbiDarkGrayColor]];
            [_errorLabel setFont:[UIFont simbiFontWithSize:16.f]];
            [_errorLabel setTextAlignment:NSTextAlignmentCenter];
            [self.view addSubview:_errorLabel];
        }
        [_errorLabel setHidden:NO];
    }
    else if (_errorLabel)
        [_errorLabel setHidden:YES];
}


- (void)sortLocations:(NSArray *)locations
{
    for (SMBFourSquareLocation *location in locations)
    {
        if (location.categories.count > 0)
        {
            for (NSDictionary *category in location.categories)
            {
                NSDictionary *topLevelDict = [[SMBFourSquareCategory instance] topLevelCategoryForCategoryId:category[@"id"]];
                
                if (topLevelDict[@"pluralName"])
                {
                    if ([topLevelDict[@"pluralName"] isEqualToString:category_nightlife])
                        [_locations[category_nightlife] addObject:location];
                    else if ([topLevelDict[@"pluralName"] isEqualToString:category_food])
                        [_locations[category_food] addObject:location];
                    else if ([topLevelDict[@"pluralName"] isEqualToString:category_entertainment])
                        [_locations[category_entertainment] addObject:location];
                    else if ([topLevelDict[@"pluralName"] isEqualToString:category_events])
                        [_locations[category_events] addObject:location];
                    else
                        [_locations[category_other] addObject:location];
                }
                else
                    [_locations[cateogry_uncategorized] addObject:location];
            }
        }
        else
            [_locations[cateogry_uncategorized] addObject:location];
    }
}


- (void)showTiles
{
    int numColumns = 2;
    int numRows = ceil(_categoryNames.count/numColumns);
    
    CGFloat viewWidth  = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    CGFloat pad = 20;
    
    CGFloat tileWidth = (viewWidth-pad*(numColumns+1))/2.f;
    CGFloat tileHeight = (viewHeight-pad*(numRows+1)-44-20)/3.f;
    
    
    int row = 0;
    int column = 0;
    int index = 0;
    
    for (NSString *category in _categoryNames)
    {
        UIView *tileView = [[UIView alloc] initWithFrame:CGRectMake(pad + pad*column + tileWidth*column,
                                                                    44+20 + pad + pad*row + tileHeight*row,
                                                                    tileWidth,
                                                                    tileHeight)];
        [tileView setBackgroundColor:[UIColor simbiGrayColor]];
        if (((NSMutableArray *)_locations[category]).count > 0)
        {
            switch (index)
            {
                case 0: [tileView setBackgroundColor:[UIColor simbiRedColor]];      break;
                case 1: [tileView setBackgroundColor:[UIColor simbiOrangeColor]];   break;
                case 2: [tileView setBackgroundColor:[UIColor simbiYellowColor]];   break;
                case 3: [tileView setBackgroundColor:[UIColor simbiGreenColor]];    break;
                case 4: [tileView setBackgroundColor:[UIColor simbiSkyBlueColor]];  break;
                case 5: [tileView setBackgroundColor:[UIColor simbiBlueColor]];     break;
            }
        }
        [tileView setAlpha:0.f];
        [tileView setTag:index];
        
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        tileView.frame.size.width,
                                                                        3*tileView.frame.size.height/4)];
        [titleLable setText:category];
        [titleLable setTextAlignment:NSTextAlignmentCenter];
        [titleLable setFont:[UIFont simbiFontWithSize:16.f]];
        [titleLable setNumberOfLines:0];
        [tileView addSubview:titleLable];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                         tileView.frame.size.height/4.f,
                                                                         tileView.frame.size.width,
                                                                         3*tileView.frame.size.height/4.f)];
        if (((NSMutableArray *)_locations[category]).count > 0)
            [detailLabel setText:[NSString stringWithFormat:@"%ld locations", (long)((NSArray *)_locations[category]).count]];
        else
            [detailLabel setText:@"No locations"];
        [detailLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [detailLabel setTextAlignment:NSTextAlignmentCenter];
        [detailLabel setFont:[UIFont simbiFontWithSize:12.f]];
        [detailLabel setNumberOfLines:0];
        [tileView addSubview:detailLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, tileView.frame.size.width, tileView.frame.size.height)];
        [button setTag:index];
        [button addTarget:self action:@selector(locationTileAction:) forControlEvents:UIControlEventTouchUpInside];
        [tileView addSubview:button];
        
        [self.view addSubview:tileView];
        
        
        [UIView animateWithDuration:0.5f
                              delay:MAX(column, row)*0.125f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             if (((NSArray *)_locations[category]).count == 0)
                                 [tileView setAlpha:0.5f];
                             else
                                 [tileView setAlpha:1.f];
                         }
                         completion:nil];
        
        column = (column+1) % numColumns;
        
        if (column == 0)
            row++;
        
        index++;
    }
}


- (void)locationTileAction:(UIButton *)button
{
    NSString *category = [_categoryNames objectAtIndex:button.tag];
    NSArray *locations = [NSArray arrayWithArray:_locations[category]];
    
    if (locations.count > 0)
    {
        SMBLocationListViewController *viewController = [[SMBLocationListViewController alloc] initWithCategory:category
                                                                                                      locations:locations];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


@end
