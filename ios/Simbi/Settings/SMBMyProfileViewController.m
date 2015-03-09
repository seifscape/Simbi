//
//  SMBMyProfileViewController.m
//  Simbi
//
//  Created by flynn on 8/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBMyProfileViewController.h"

#import "SMBAppDelegate.h"
#import "SMBQuantizedColorSelector.h"
#import "UITableViewController+Simbi.h"


@interface SMBMyProfileViewController ()

@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UILabel *heightLabel;

@end


@implementation SMBMyProfileViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"My Profile"];
    [self.view setBackgroundColor:[UIColor redColor]];
    [self.tableView setBackgroundColor:[UIColor redColor]];
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
        [segmentedControl addTarget:self action:@selector(genderDidChange:) forControlEvents:UIControlEventValueChanged];
        [segmentedControl setSelectedSegmentIndex:[SMBUser currentUser].genderType];
        [cell.contentView addSubview:segmentedControl];
    }
    if (indexPath.row == 1)
    {
        [label setText:@"Age:"];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(22, 22, cell.frame.size.width-44-66, 88)];
        [slider setMinimumValue:18.f];
        [slider setMaximumValue:55.f];
        [slider setValue:[SMBUser currentUser].age.intValue];
        [slider setTintColor:[UIColor simbiBlueColor]];
        [slider addTarget:self action:@selector(ageDidChange:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:slider];
        
        if (!_ageLabel)
        {
            _ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-11-66, 22, 66, 88)];
            [_ageLabel setTextColor:[UIColor simbiDarkGrayColor]];
            [_ageLabel setFont:[UIFont simbiFontWithSize:18.f]];
            [_ageLabel setTextAlignment:NSTextAlignmentCenter];
        }
        [cell.contentView addSubview:_ageLabel];
        
        [self ageDidChange:slider];
    }
    if (indexPath.row == 2)
    {
        [label setText:@"Height:"];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(22, 22, cell.frame.size.width-44-66, 88)];
        [slider setMinimumValue:48.f];
        [slider setMaximumValue:84.f];
        [slider setValue:66.f];
        [slider setTintColor:[UIColor simbiBlueColor]];
        [slider addTarget:self action:@selector(heightDidChange:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:slider];
        
        if (!_heightLabel)
        {
            _heightLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-11-66, 22, 66, 88)];
            [_heightLabel setTextColor:[UIColor simbiDarkGrayColor]];
            [_heightLabel setFont:[UIFont simbiFontWithSize:18.f]];
            [_heightLabel setTextAlignment:NSTextAlignmentCenter];
        }
        [cell.contentView addSubview:_heightLabel];
        
        [self heightDidChange:slider];
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

- (void)genderDidChange:(UISegmentedControl *)segmentedControl
{
    SMBUserGenderType gender;
    
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:  gender = kSMBUserGenderMale;   break;
        case 1:  gender = kSMBUserGenderFemale; break;
        default: gender = kSMBUserGenderOther;  break;
    }
    [[SMBUser currentUser] setGenderType:gender];
}


- (void)ageDidChange:(UISlider *)slider
{
    if ((int)slider.value >= (int)slider.maximumValue)
        [_ageLabel setText:[NSString stringWithFormat:@"%d+", (int)slider.value]];
    else
        [_ageLabel setText:[NSString stringWithFormat:@"%d" , (int)slider.value]];
    
    [[SMBUser currentUser] setAge:[NSNumber numberWithInt:(int)slider.value]];
}


- (void)heightDidChange:(UISlider *)slider
{
    if ((int)slider.value >= (int)slider.maximumValue)
        [_heightLabel setText:[NSString stringWithFormat:@"≥ %d'", ((int)slider.value)/12]];
    else if ((int)slider.value <= (int)slider.minimumValue)
        [_heightLabel setText:[NSString stringWithFormat:@"≤ %d'", ((int)slider.value)/12]];
    else
        [_heightLabel setText:[NSString stringWithFormat:@"%d'%d\"", ((int)slider.value)/12, ((int)slider.value)%12]];
}


- (void)hairColorDidChange:(SMBQuantizedColorSelector *)colorSelector
{
    
}


- (void)eyeColorDidChange:(SMBQuantizedColorSelector *)colorSelector
{
    
}


@end
