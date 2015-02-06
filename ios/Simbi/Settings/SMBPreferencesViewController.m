//
//  SMBPreferencesViewController.m
//  Simbi
//
//  Created by flynn on 8/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBPreferencesViewController.h"

#import "NMRangeSlider.h"

#import "SMBAppDelegate.h"
#import "SMBQuantizedColorSelector.h"
#import "UITableViewController+Simbi.h"


@interface SMBPreferencesViewController ()

@property (nonatomic, strong) UILabel *agePreferenceLabel;
@property (nonatomic, strong) UILabel *heightPreferenceLabel;

@end


@implementation SMBPreferencesViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Preferences"];
    [self.view setBackgroundColor:[UIColor simbiWhiteColor]];
    [self.tableView setBackgroundColor:[UIColor simbiWhiteColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    if ([UIScreen mainScreen].bounds.size.height >= [self requiredHeightForTable]+44)
        [self.tableView setScrollEnabled:NO];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[SMBAppDelegate instance] enableSideMenuGesture:NO];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SMBUser currentUser] saveInBackground];
    [[SMBAppDelegate instance] enableSideMenuGesture:YES];
}


#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:  return  66;
        case 1:  return 110;
        case 2:  return 110;
        case 3:  return  88;
        case 4:  return  88;
        default: return   0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor simbiWhiteColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(22, 0, cell.frame.size.width-22, 22)];
    [label setTextColor:[UIColor simbiGrayColor]];
    [label setFont:[UIFont simbiFontWithSize:12.f]];
    [cell.contentView addSubview:label];
    
    if (indexPath.row == 0)
    {
        [label setText:@"Gender:"];
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Male", @"Female", @"+"]];
        [segmentedControl setFrame:CGRectMake(22, 22+(44-28)/2, cell.frame.size.width-44, 28)];
        [segmentedControl setTintColor:[UIColor simbiBlueColor]];
        [segmentedControl addTarget:self action:@selector(genderPreferenceDidChange:) forControlEvents:UIControlEventValueChanged];
        [segmentedControl setSelectedSegmentIndex:[SMBUser currentUser].genderPreferenceType];
        [cell.contentView addSubview:segmentedControl];
    }
    if (indexPath.row == 1)
    {
        [label setText:@"Age:"];
        
        NMRangeSlider *rangeSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(22, 22, cell.frame.size.width-44-66, 88)];
        [rangeSlider setMinimumValue:18.f];
        [rangeSlider setMaximumValue:55.f];
        [rangeSlider setMinimumRange:1.f];
        [rangeSlider setUpperValue:[SMBUser currentUser].upperAgePreference.intValue];
        
        // If lower age preference is greater than or equal to the upper, set upper as just above the lower.
        if ([SMBUser currentUser].lowerAgePreference.intValue >= [SMBUser currentUser].upperAgePreference.intValue)
            [rangeSlider setUpperValue:[SMBUser currentUser].lowerAgePreference.intValue+1];
        
        [rangeSlider setLowerValue:[SMBUser currentUser].lowerAgePreference.intValue];
        [rangeSlider setTintColor:[UIColor simbiBlueColor]];
        [rangeSlider addTarget:self action:@selector(agePreferenceDidChange:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:rangeSlider];
        
        if (!_agePreferenceLabel)
        {
            _agePreferenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-11-66, 22, 66, 88)];
            [_agePreferenceLabel setTextColor:[UIColor simbiDarkGrayColor]];
            [_agePreferenceLabel setFont:[UIFont simbiFontWithSize:18.f]];
            [_agePreferenceLabel setTextAlignment:NSTextAlignmentCenter];
        }
        [cell.contentView addSubview:_agePreferenceLabel];
        
        [self agePreferenceDidChange:rangeSlider];
    }
    if (indexPath.row == 2)
    {
        [label setText:@"Height:"];
        
        NMRangeSlider *rangeSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(22, 22, cell.frame.size.width-44-66, 88)];
        [rangeSlider setMinimumValue:48.f];
        [rangeSlider setMaximumValue:84.f];
        [rangeSlider setMinimumRange:1.f];
        [rangeSlider setUpperValue:72.f];
        [rangeSlider setLowerValue:60.f];
        [rangeSlider setTintColor:[UIColor simbiBlueColor]];
        [rangeSlider addTarget:self action:@selector(heightPreferenceDidChange:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:rangeSlider];
        
        if (!_heightPreferenceLabel)
        {
            _heightPreferenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-11-66-11, 22, 66+22, 88)];
            [_heightPreferenceLabel setTextColor:[UIColor simbiDarkGrayColor]];
            [_heightPreferenceLabel setFont:[UIFont simbiFontWithSize:15.f]];
            [_heightPreferenceLabel setTextAlignment:NSTextAlignmentCenter];
        }
        [cell.contentView addSubview:_heightPreferenceLabel];
        
        [self heightPreferenceDidChange:rangeSlider];
    }
    if (indexPath.row == 3)
    {
        [label setText:@"Hair Color:"];
        
        NSArray *colors = @[[UIColor yellowColor], [UIColor redColor], [UIColor brownColor], [UIColor blackColor]];
        CGRect frame = CGRectMake(22, 33, cell.frame.size.width-44, 44);
        
        SMBQuantizedColorSelector *colorSelector = [[SMBQuantizedColorSelector alloc] initWithFrame:frame colors:colors];
        [colorSelector setSelectedIndex:arc4random()%colors.count]; // Random selection for now..
        [colorSelector.layer setCornerRadius:4.f];
        [colorSelector.layer setMasksToBounds:YES];
        [cell.contentView addSubview:colorSelector];
    }
    if (indexPath.row == 4)
    {
        [label setText:@"Eye Color:"];
        
        NSArray *colors = @[[UIColor greenColor], [UIColor blueColor], [UIColor grayColor], [UIColor brownColor]];
        CGRect frame = CGRectMake(22, 33, cell.frame.size.width-44, 44);
        
        SMBQuantizedColorSelector *colorSelector = [[SMBQuantizedColorSelector alloc] initWithFrame:frame colors:colors];
        [colorSelector setSelectedIndex:arc4random()%colors.count]; // Random selection for now..
        [colorSelector.layer setCornerRadius:4.f];
        [colorSelector.layer setMasksToBounds:YES];
        [cell.contentView addSubview:colorSelector];
    }
    
    return cell;
}


#pragma mark - User Actions

- (void)genderPreferenceDidChange:(UISegmentedControl *)segmentedControl
{
    SMBUserGenderType gender;
    
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:  gender = kSMBUserGenderMale;   break;
        case 1:  gender = kSMBUserGenderFemale; break;
        default: gender = kSMBUserGenderOther;  break;
    }
    [[SMBUser currentUser] setGenderPreferenceType:gender];
}


- (void)agePreferenceDidChange:(NMRangeSlider *)slider
{
    if ((int)slider.upperValue >= (int)slider.maximumValue)
        [_agePreferenceLabel setText:[NSString stringWithFormat:@"%d-%d+", (int)slider.lowerValue, (int)slider.upperValue]];
    else
        [_agePreferenceLabel setText:[NSString stringWithFormat:@"%d-%d" , (int)slider.lowerValue, (int)slider.upperValue]];
    
    [[SMBUser currentUser] setLowerAgePreference:[NSNumber numberWithInt:(int)slider.lowerValue]];
    [[SMBUser currentUser] setUpperAgePreference:[NSNumber numberWithInt:(int)slider.upperValue]];
}


- (void)heightPreferenceDidChange:(NMRangeSlider *)slider
{
    NSString *lowerString;
    NSString *upperString;
    
    if ((int)slider.lowerValue >= (int)slider.maximumValue)
        lowerString = [NSString stringWithFormat:@"%d'+", ((int)slider.lowerValue)/12];
    else if ((int)slider.lowerValue <= (int)slider.minimumValue)
        lowerString = [NSString stringWithFormat:@"%d'", ((int)slider.lowerValue)/12];
    else
        lowerString = [NSString stringWithFormat:@"%d'%d\"", ((int)slider.lowerValue)/12, ((int)slider.lowerValue)%12];
    
    if ((int)slider.upperValue >= (int)slider.maximumValue)
        upperString = [NSString stringWithFormat:@"%d'+", ((int)slider.upperValue)/12];
    else if ((int)slider.upperValue <= (int)slider.minimumValue)
        upperString = [NSString stringWithFormat:@"%d'", ((int)slider.upperValue)/12];
    else
        upperString = [NSString stringWithFormat:@"%d'%d\"", ((int)slider.upperValue)/12, ((int)slider.upperValue)%12];
    
    [_heightPreferenceLabel setText:[NSString stringWithFormat:@"%@-%@", lowerString, upperString]];
}


- (void)hairColorPreferenceDidChange:(SMBQuantizedColorSelector *)colorSelector
{
    
}


- (void)eyeColorPreferenceDidChange:(SMBQuantizedColorSelector *)colorSelector
{
    
}


@end
