//
//  SMBMapsView.m
//  Simbi
//
//  Created by flynn on 5/29/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBMapsView.h"

#import "SMBFriendsManager.h"
#import "SMBPinLocationButton.h"
#import "SMBFriendsManager.h"
#import "_SMBFriendCardView.h"


@interface _SMBMapsView ()

@property (nonatomic, weak) _SMBMainViewController *parent;
@property (nonatomic, strong) NSArray *annotations;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic) CGFloat distance;

@property (nonatomic, strong) UISlider *rangeSlider;
@property (nonatomic, strong) UIView *sliderLabelView;

@property (nonatomic, strong) UIView *shadeView;
@property (nonatomic, strong) _SMBFriendCardView *friendCardView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end


@implementation _SMBMapsView

static const CGFloat kFeetInMile = 5280;
static const CGFloat kMetersInMile = 1609.34;

- (id)initWithFrame:(CGRect)frame parent:(_SMBMainViewController *)parent
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _parent = parent;
        
        [[SMBFriendsManager sharedManager] addDelegate:self];
        
        // Set default distance values (in meters)
        
        _distance =  [self distanceForSliderValue:2.f];
        
        
        // Set up views
        
        [self setClipsToBounds:YES];
        
        CGFloat width  = frame.size.width;
        CGFloat height = frame.size.height;
        
        
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [_mapView setDelegate:self];
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
        {
            [_locationManager startUpdatingLocation];
            [_mapView setShowsUserLocation:[CLLocationManager locationServicesEnabled]];
        }
        else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
                 [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        {
            NSString *message = @"Simbi needs your location to work properly! Please enable location services for Simbi in\n\nSettings → Privacy → Location Services → Simbi\n\nWe promise we're chill.";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            [_locationManager requestWhenInUseAuthorization];
        }
        
        [_mapView setScrollEnabled:NO];
        [_mapView setShowsPointsOfInterest:NO];
        [self addSubview:_mapView];
        
        if ([SMBFriendsManager sharedManager].objects)
            [self createAnnotations];
        
        
        _rangeSlider = [[UISlider alloc] init];
        [_rangeSlider setTintColor:[UIColor simbiBlueColor]];
        [_rangeSlider setMinimumValue:0];
        [_rangeSlider setMaximumValue:11.f];
        [_rangeSlider setValue:2.f];
        [_rangeSlider addTarget:self action:@selector(rangeSliderDidChange:) forControlEvents:UIControlEventValueChanged];
        [_rangeSlider addTarget:self action:@selector(rangeSliderDidFinish:) forControlEvents:UIControlEventTouchUpInside];
        
        // Make slider vertical
        [_rangeSlider setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        [_rangeSlider setFrame:CGRectMake(0, height/4.f, 66, height/2.f)];
        
        [self addSubview:_rangeSlider];
        
        
        // Floating label next to the slider
        
        _sliderLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 38)];
        [_sliderLabelView setBackgroundColor:[UIColor simbiLightGrayColor]];
        [_sliderLabelView.layer setCornerRadius:4.f];
        [_sliderLabelView.layer setShadowColor:[UIColor blackColor].CGColor];
        [_sliderLabelView.layer setShadowOffset:CGSizeMake(2.f, 2.f)];
        [_sliderLabelView.layer setShadowOpacity:.25f];
        [_sliderLabelView setHidden:YES];
        
        UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 88, 36)];
        [sliderLabel setTextColor:[UIColor simbiDarkGrayColor]];
        [sliderLabel setFont:[UIFont simbiFontWithSize:14.f]];
        [sliderLabel setTextAlignment:NSTextAlignmentCenter];
        [sliderLabel.layer setCornerRadius:4.f];
        [sliderLabel.layer setMasksToBounds:YES];
        [_sliderLabelView addSubview:sliderLabel];
        
        UIView *sliderPoint = [[UIView alloc] initWithFrame:CGRectMake(-4, 14, 8, 8)];
        [sliderPoint setBackgroundColor:[UIColor simbiLightGrayColor]];
        [sliderPoint setTransform:CGAffineTransformMakeRotation(M_PI_4)];
        [_sliderLabelView insertSubview:sliderPoint belowSubview:sliderLabel];
        
        [self addSubview:_sliderLabelView];

        
//        SMBPinLocationButton *pinLocationButton = [[SMBPinLocationButton alloc] initWithFrame:CGRectMake(44, height-22-44, width-88, 44)];
//        [pinLocationButton addTarget:_parent action:@selector(pinLocationAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:pinLocationButton];
    }
    
    return self;
}


- (void)dealloc
{
    [[SMBFriendsManager sharedManager] cleanDelegates];
}


- (CGFloat)lockedDistanceForSliderValue:(CGFloat)value
{
    int val = floor(value);
    
    switch (val)
    {
        case 0: return 500/kFeetInMile;
        case 1: return 1000/kFeetInMile;
        case 2: return 1.f;
        case 3: return 5.f;
        case 4: return 25.f;
        case 5: return 50.f;
        case 6: return 100.f;
        case 7: return 250.f;
        case 8: return 500.f;
        case 9: return 1000.f;
        default: return 10000.f;
    }
}


- (CGFloat)distanceForSliderValue:(CGFloat)value
{
    CGFloat percent = value - floor(value);
    
    CGFloat low = [self lockedDistanceForSliderValue:value];
    CGFloat high = [self lockedDistanceForSliderValue:value+1.f];
    
    return low+(high-low)*percent;
}


- (NSString *)stringForSliderValue:(CGFloat)value
{
    int val = floor(value);
    
    switch (val)
    {
        case 0: return @"500 Feet";
        case 1: return @"1000 Feet";
        case 2: return @"1 Mile";
        case 3: return @"5 Miles";
        case 4: return @"25 Miles";
        case 5: return @"50 Miles";
        case 6: return @"100 Miles";
        case 7: return @"250 Miles";
        case 8: return @"500 Miles";
        case 9: return @"1000 Miles";
        default: return @"The World";
    }
}


- (void)createAnnotations
{
    if (_annotations)
        [_mapView removeAnnotations:_annotations];
    
    NSMutableArray *annotations = [NSMutableArray new];
    
    for (SMBUser *friend in [SMBFriendsManager sharedManager].objects)
    {
        _SMBAnnotation *annotation = [[_SMBAnnotation alloc] initWithUser:friend];
        [annotation setDelegate:self];
        [_mapView addAnnotation:annotation];
        
        [annotations addObject:annotation];
    }
    
    _annotations = [NSArray arrayWithArray:annotations];
}


#pragma mark - User Actions

- (void)rangeSliderDidChange:(UISlider *)slider
{    
    if (_sliderLabelView.hidden)
    {
        [_sliderLabelView setAlpha:0.f];
        [_sliderLabelView setHidden:NO];
        [UIView animateWithDuration:0.125f animations:^{
            [_sliderLabelView setAlpha:1.f];
        }];
    }
    
    _distance = [self distanceForSliderValue:slider.value];
    
    CGFloat percentValue = 1-(slider.value-slider.minimumValue)/(slider.maximumValue-slider.minimumValue);
    
    [_sliderLabelView setFrame:CGRectMake(slider.frame.origin.x+slider.frame.size.width,
                                          slider.frame.origin.y+(slider.frame.size.height-36)*percentValue,
                                          _sliderLabelView.frame.size.width,
                                          _sliderLabelView.frame.size.height)];
    
    for (id subview in _sliderLabelView.subviews)
        if ([subview isKindOfClass:[UILabel class]])
            [(UILabel *)subview setText:[self stringForSliderValue:slider.value]];
    
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(_mapView.userLocation.coordinate, _distance*kMetersInMile, _distance*kMetersInMile)];
}


- (void)rangeSliderDidFinish:(UISlider *)rangeSlider
{
    [UIView animateWithDuration:0.125f animations:^{
        [_sliderLabelView setAlpha:0.f];
    } completion:^(BOOL finished) {
        [_sliderLabelView setHidden:YES];
    }];
}


- (void)hideFriendCardAction:(UIButton *)button
{
//    [_parent hideButtons:NO];
    
    [_rangeSlider setHidden:NO];
    
    [UIView animateWithDuration:0.33f animations:^{
        [_rangeSlider setAlpha:1.f];
        [_shadeView setAlpha:0.f];
        [_friendCardView setAlpha:0.f];
    } completion:^(BOOL finished) {
        [_shadeView removeFromSuperview];
        [_friendCardView removeFromSuperview];
    }];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [_mapView setShowsUserLocation:YES];
    }
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, _distance*kMetersInMile, _distance*kMetersInMile)];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[_SMBAnnotation class]])
    {
        _SMBAnnotation *smbAnnotation = (_SMBAnnotation *)annotation;
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Maps"];
        
        if (!annotationView)
            annotationView = [smbAnnotation annotationView];
        else
            [annotationView setAnnotation:smbAnnotation];
        
        return annotationView;
    }
    else
        return nil;
}


#pragma mark - SMBAnnotationDelegate

- (void)annotation:(_SMBAnnotation *)annotation didSelectUser:(SMBUser *)user
{
//    [_parent hideButtons:YES];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(annotation.coordinate.latitude+0.0015f,
                                                                   annotation.coordinate.longitude);
    
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, 1.f*kMetersInMile, 1.f*kMetersInMile) animated:YES];
    
    _shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_shadeView setBackgroundColor:[UIColor blackColor]];
    [_shadeView setAlpha:0.f];
    [self addSubview:_shadeView];
    
    UIButton *shadeHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shadeHideButton setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [shadeHideButton addTarget:self action:@selector(hideFriendCardAction:) forControlEvents:UIControlEventTouchUpInside];
    [_shadeView addSubview:shadeHideButton];
    
    _friendCardView = [[_SMBFriendCardView alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, self.frame.size.height/2.f-20) user:user];
    [_friendCardView setAlpha:0.f];
    [self addSubview:_friendCardView];
    
    UIButton *cardHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cardHideButton setFrame:CGRectMake(_friendCardView.frame.size.width-28-6, 6, 28, 28)];
    [cardHideButton setBackgroundColor:[UIColor simbiWhiteColor]];
    [cardHideButton setTitle:@"X" forState:UIControlStateNormal];
    [cardHideButton setTitleColor:[UIColor simbiGrayColor] forState:UIControlStateNormal];
    [cardHideButton.layer setCornerRadius:cardHideButton.frame.size.width/2.f];
    [cardHideButton.layer setShadowOffset:CGSizeMake(2, 2)];
    [cardHideButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [cardHideButton.layer setShadowOpacity:0.33f];
    [cardHideButton addTarget:self action:@selector(hideFriendCardAction:) forControlEvents:UIControlEventTouchUpInside];
    [_friendCardView addSubview:cardHideButton];
    
    [UIView animateWithDuration:0.25f animations:^{
        [_shadeView setAlpha:0.5f];
        [_rangeSlider setAlpha:0.f];
    } completion:^(BOOL finished) {
        [_rangeSlider setHidden:YES];
    }];
    
    [UIView animateWithDuration:0.25f delay:0.125f options:UIViewAnimationOptionCurveLinear animations:^{
        [_friendCardView setAlpha:1.f];
    } completion:nil];
}


#pragma mark - SMBFriendsManagerDelegate

- (void)manager:(SMBManager *)manager didUpdateObjects:(NSArray *)objects
{
    [self createAnnotations];
}


- (void)manager:(SMBManager *)manager didFailToLoadObjects:(NSError *)error
{
    
}


@end
