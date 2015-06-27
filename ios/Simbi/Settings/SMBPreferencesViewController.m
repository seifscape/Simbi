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
@property (nonatomic, strong) UISegmentedControl *lookingtoSegmentedControl;
/*added by zhy at 2015-06-26*/
@property (nonatomic, strong) UIButton *lookingtoBtnFirst;
@property (nonatomic, strong) UIButton *lookingtoBtnSecond;
@property (nonatomic, strong) UIButton *lookingtoBtnThird;
/*end*/
@property (nonatomic, strong) UISegmentedControl *genderSegmentedControl;
@property (nonatomic, strong) NMRangeSlider *ageRangeSlider;
@property (nonatomic, strong) UIButton* saveButton;
@end


@implementation SMBPreferencesViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.lookingtoSegmentedControl = nil;
    self.lookingtoBtnFirst = nil;
    self.lookingtoBtnSecond = nil;
    self.lookingtoBtnThird = nil;
    self.genderSegmentedControl = nil;
    self.ageRangeSlider = nil;
    self.saveButton = nil;
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Preferences"];
    [self.view setBackgroundColor:[UIColor simbiWhiteColor]];
    [self.tableView setBackgroundColor:[UIColor simbiWhiteColor]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    self.saveButton = [UIButton new];
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setFrame:CGRectMake(0, 0, 70, 30)];
    [self.saveButton setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-100)];
    [self.saveButton setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:self.saveButton];

    [self.saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //add save button
//    saveButton.setTitle("Save", forState: UIControlState.allZeros)
//    saveButton.frame.size = CGSize(width: 70, height: 30)
//    saveButton.center = CGPoint(x: self.scrollInfoView.frame.size.width/2, y: self.scrollInfoView.contentSize.height - 50)
//    saveButton.backgroundColor = UIColor.greenColor()
//    
//    saveButton.addTarget(self, action: "saveButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
    if ([UIScreen mainScreen].bounds.size.height >= [self requiredHeightForTable]+44)
        [self.tableView setScrollEnabled:NO];
    //[self.view bringSubviewToFront:saveButton];
}
- (void)saveButtonClicked:(UIButton*)sender{
    NSString* obid = [[SMBUser currentUser] objectId];
    MBProgressHUD* hud =[MBProgressHUD HUDwithMessage:@"Saving ..." parent:self];
    if (obid==@"") {
        [hud dismissWithMessage:@"Save failed!"];
        return;
    }
    
    PFQuery* query = [PFQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:obid block:^(PFObject *object, NSError *error) {
//        object[@"lookingto"] = [NSString stringWithFormat:@"%ld",self.lookingtoSegmentedControl.selectedSegmentIndex];
        object[@"lookingto"] = [NSArray arrayWithObjects:self.lookingtoBtnFirst.isSelected?@"1":@"0", self.lookingtoBtnSecond.isSelected?@"1":@"0", self.lookingtoBtnThird.isSelected?@"1":@"0", nil];
        object[@"genderPreference"] = [NSString stringWithFormat:@"%ld",self.genderSegmentedControl.selectedSegmentIndex];
        object[@"upperAgePreference"] = [NSNumber numberWithInt:(int)self.ageRangeSlider.upperValue];
        object[@"lowerAgePreference"] = [NSNumber numberWithInt:(int)self.ageRangeSlider.lowerValue];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//           
//            UIAlertView* alert = [UIAlertView new];
//            [alert setTitle:@"Tip"];
//            [alert setMessage:succeeded?@"Save success!":@"Save failed!"];
//            [alert addButtonWithTitle:@"Ok"];
//            [alert show];
            if (succeeded == true){
                [hud dismissWithMessage:@"Save success!"];
            }else{
                [hud dismissWithMessage:@"Save failed!"];
            }
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    MBProgressHUD* hud =[MBProgressHUD HUDwithMessage:@"Loading ..." parent:self];
    [super viewWillAppear:animated];
    [[SMBAppDelegate instance] enableSideMenuGesture:NO];
    NSString* obid = [[SMBUser currentUser] objectId];
    if (obid==@"") {
        [hud dismissQuickly];
        return;
    }
    PFQuery* query = [PFQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:obid block:^(PFObject *object, NSError *error) {
        SMBUser* user = (SMBUser*)object;
        NSLog(@"%ld,%ld",(long)user.upperAgePreference.integerValue,(long)user.lowerAgePreference.integerValue);
//        [self.lookingtoSegmentedControl setSelectedSegmentIndex: [user.lookingto intValue]];
        
        //get lookingto preference
        NSArray *lookingtoArray = user.lookingto;
        if (lookingtoArray && lookingtoArray.count == 3) {
            self.lookingtoBtnFirst.selected = [lookingtoArray[0] isEqual:@"1"]?YES:NO;
            self.lookingtoBtnSecond.selected = [lookingtoArray[1] isEqual:@"1"]?YES:NO;
            self.lookingtoBtnThird.selected = [lookingtoArray[2] isEqual:@"1"]?YES:NO;
            [self refreshLookingtoBtn:self.lookingtoBtnFirst];
            [self refreshLookingtoBtn:self.lookingtoBtnSecond];
            [self refreshLookingtoBtn:self.lookingtoBtnThird];
        }
        
        [self.genderSegmentedControl setSelectedSegmentIndex: [user.genderPreference intValue]];
        [[SMBUser currentUser] setUpperAgePreference:user.upperAgePreference];
        [[SMBUser currentUser] setLowerAgePreference:user.lowerAgePreference];
        [self.ageRangeSlider setUpperValue:user.upperAgePreference.intValue];
        [self.ageRangeSlider setLowerValue:user.lowerAgePreference.intValue];
        [self agePreferenceDidChange:self.ageRangeSlider];
        [hud dismissQuickly];
    }];
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
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:  return  66;
        case 1:  return  66;
        case 2:  return 110;
        case 3:  return 110;
        case 4:  return  88;
        case 5:  return  88;
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
        [label setText:@"Looking To[Select 1+]"]; /*modified by zhy at 2015-06-05*/
#if 0
        if (self.lookingtoSegmentedControl==nil) {
            self.lookingtoSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Make Friends", @"Date", @"NetWork"]];
        }
        [self.lookingtoSegmentedControl setFrame:CGRectMake(22, 22+(44-28)/2, cell.frame.size.width-44, 28)];
        [self.lookingtoSegmentedControl setTintColor:[UIColor simbiBlueColor]];
        [self.lookingtoSegmentedControl addTarget:self action:@selector(genderPreferenceDidChange:) forControlEvents:UIControlEventValueChanged];
        [self.lookingtoSegmentedControl setSelectedSegmentIndex:[SMBUser currentUser].genderPreferenceType];
        [cell.contentView addSubview:self.lookingtoSegmentedControl];
#endif
        
        if (self.lookingtoBtnFirst == nil) {
            self.lookingtoBtnFirst = [UIButton buttonWithType:UIButtonTypeCustom];
            self.lookingtoBtnFirst.layer.masksToBounds = YES;
            self.lookingtoBtnFirst.layer.borderWidth = 1.f;
            self.lookingtoBtnFirst.layer.cornerRadius = 3.f;
            self.lookingtoBtnFirst.layer.borderColor = [UIColor simbiBlueColor].CGColor;
            self.lookingtoBtnFirst.titleLabel.font = [UIFont simbiFontWithSize:14];
            [self.lookingtoBtnFirst setTitleColor:[UIColor simbiWhiteColor] forState:UIControlStateSelected];
            [self.lookingtoBtnFirst setTitleColor:[UIColor simbiBlueColor] forState:UIControlStateNormal];
            [self.lookingtoBtnFirst setFrame:CGRectMake(22, 22+(44-28)/2, (cell.frame.size.width-44)/3.0, 28)];
            [self.lookingtoBtnFirst setTitle:@"Make Friends" forState:UIControlStateNormal];
            [self.lookingtoBtnFirst addTarget:self action:@selector(lookingtoPreferenceDidChange:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:self.lookingtoBtnFirst];

        }
        
        if (self.lookingtoBtnSecond == nil) {
            self.lookingtoBtnSecond = [UIButton buttonWithType:UIButtonTypeCustom];
            self.lookingtoBtnSecond.layer.masksToBounds = YES;
            self.lookingtoBtnSecond.layer.borderWidth = 1.f;
            self.lookingtoBtnSecond.layer.cornerRadius = 3.f;
            self.lookingtoBtnSecond.layer.borderColor = [UIColor simbiBlueColor].CGColor;
            self.lookingtoBtnSecond.titleLabel.font = [UIFont simbiFontWithSize:14];

            [self.lookingtoBtnSecond setTitleColor:[UIColor simbiWhiteColor] forState:UIControlStateSelected];
            [self.lookingtoBtnSecond setTitleColor:[UIColor simbiBlueColor] forState:UIControlStateNormal];            [self.lookingtoBtnSecond setFrame:CGRectMake(CGRectGetMaxX(self.lookingtoBtnFirst.frame), 22+(44-28)/2, (cell.frame.size.width-44)/3.0, 28)];
            [self.lookingtoBtnSecond setTitle:@"Date" forState:UIControlStateNormal];
            [self.lookingtoBtnSecond addTarget:self action:@selector(lookingtoPreferenceDidChange:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:self.lookingtoBtnSecond];

        }
        
        if (self.lookingtoBtnThird == nil) {
            self.lookingtoBtnThird = [UIButton buttonWithType:UIButtonTypeCustom];
            self.lookingtoBtnThird.layer.masksToBounds = YES;
            self.lookingtoBtnThird.layer.borderWidth = 1.f;
            self.lookingtoBtnThird.layer.cornerRadius = 3.f;
            self.lookingtoBtnThird.layer.borderColor = [UIColor simbiBlueColor].CGColor;
            self.lookingtoBtnThird.titleLabel.font = [UIFont simbiFontWithSize:14];

            [self.lookingtoBtnThird setTitleColor:[UIColor simbiWhiteColor] forState:UIControlStateSelected];
            [self.lookingtoBtnThird setTitleColor:[UIColor simbiBlueColor] forState:UIControlStateNormal];
            [self.lookingtoBtnThird setFrame:CGRectMake(CGRectGetMaxX(self.lookingtoBtnSecond.frame), 22+(44-28)/2, (cell.frame.size.width-44)/3.0, 28)];
            [self.lookingtoBtnThird setTitle:@"NetWork" forState:UIControlStateNormal];
            [self.lookingtoBtnThird addTarget:self action:@selector(lookingtoPreferenceDidChange:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:self.lookingtoBtnThird];

        }
        
    }
    if (indexPath.row == 1)
    {
        [label setText:@"Gender"];
        if (self.genderSegmentedControl==nil) {
            self.genderSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Male", @"Female", @"+"]];
        }
        [self.genderSegmentedControl setFrame:CGRectMake(22, 22+(44-28)/2, cell.frame.size.width-44, 28)];
        [self.genderSegmentedControl setTintColor:[UIColor simbiBlueColor]];
        [self.genderSegmentedControl addTarget:self action:@selector(genderPreferenceDidChange:) forControlEvents:UIControlEventValueChanged];
        [self.genderSegmentedControl setSelectedSegmentIndex:[SMBUser currentUser].genderPreferenceType];
        [cell.contentView addSubview:self.genderSegmentedControl];
    }
    if (indexPath.row == 2)
    {
        [label setText:@"Age"];
        
        if (self.ageRangeSlider==nil) {
            self.ageRangeSlider =[[NMRangeSlider alloc] initWithFrame:CGRectMake(22, 22, cell.frame.size.width-44-66, 88)];
        }
        [self.ageRangeSlider setMinimumValue:18.f];
        [self.ageRangeSlider setMaximumValue:55.f];
        [self.ageRangeSlider setMinimumRange:1.f];
        [self.ageRangeSlider setUpperValue:[SMBUser currentUser].upperAgePreference.intValue];
        
        // If lower age preference is greater than or equal to the upper, set upper as just above the lower.
        if ([SMBUser currentUser].lowerAgePreference.intValue >= [SMBUser currentUser].upperAgePreference.intValue)
            [self.ageRangeSlider setUpperValue:[SMBUser currentUser].lowerAgePreference.intValue+1];
        
        [self.ageRangeSlider setLowerValue:[SMBUser currentUser].lowerAgePreference.intValue];
        [self.ageRangeSlider setTintColor:[UIColor simbiBlueColor]];
        [self.ageRangeSlider addTarget:self action:@selector(agePreferenceDidChange:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:self.ageRangeSlider];
        
        if (!_agePreferenceLabel)
        {
            _agePreferenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-11-66, 22, 66, 88)];
            [_agePreferenceLabel setTextColor:[UIColor simbiDarkGrayColor]];
            [_agePreferenceLabel setFont:[UIFont simbiFontWithSize:18.f]];
            [_agePreferenceLabel setTextAlignment:NSTextAlignmentCenter];
        }
        [cell.contentView addSubview:_agePreferenceLabel];
        
        [self agePreferenceDidChange:self.ageRangeSlider];
    }
    if (indexPath.row==3) {
        [cell addSubview:self.saveButton];
        [self.saveButton setCenter:CGPointMake(self.view.frame.size.width/2, cell.frame.size.height/2)];
    }
    if (indexPath.row == 4)
    {
        [label setText:@"Height:"];
        if (self.ageRangeSlider==nil) {
            self.ageRangeSlider=[[NMRangeSlider alloc] initWithFrame:CGRectMake(22, 22, cell.frame.size.width-44-66, 88)];
        }
        [self.ageRangeSlider setMinimumValue:48.f];
        [self.ageRangeSlider setMaximumValue:84.f];
        [self.ageRangeSlider setMinimumRange:1.f];
        [self.ageRangeSlider setUpperValue:72.f];
        [self.ageRangeSlider setLowerValue:60.f];
        [self.ageRangeSlider setTintColor:[UIColor simbiBlueColor]];
        [self.ageRangeSlider addTarget:self action:@selector(heightPreferenceDidChange:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:self.ageRangeSlider];
        
        if (!_heightPreferenceLabel)
        {
            _heightPreferenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-11-66-11, 22, 66+22, 88)];
            [_heightPreferenceLabel setTextColor:[UIColor simbiDarkGrayColor]];
            [_heightPreferenceLabel setFont:[UIFont simbiFontWithSize:15.f]];
            [_heightPreferenceLabel setTextAlignment:NSTextAlignmentCenter];
        }
        [cell.contentView addSubview:_heightPreferenceLabel];
        
        [self heightPreferenceDidChange:self.ageRangeSlider];
    }
    if (indexPath.row == 4)
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
    if (indexPath.row == 5)
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
- (void)refreshLookingtoBtn:(UIButton *)button {
    if (button.isSelected) {
        [button setBackgroundColor:[UIColor simbiBlueColor]];
    } else {
        [button setBackgroundColor:[UIColor simbiWhiteColor]];
    }
  
}

- (void)lookingtoPreferenceDidChange:(UIButton *)button
{
    button.selected = !button.isSelected;
    if (button.isSelected) {
        [button setBackgroundColor:[UIColor simbiBlueColor]];
    } else {
        [button setBackgroundColor:[UIColor simbiWhiteColor]];
    }
}

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
