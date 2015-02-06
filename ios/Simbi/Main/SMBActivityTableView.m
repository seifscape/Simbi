//
//  SMBActivityTableView.m
//  Simbi
//
//  Created by flynn on 7/2/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBActivityTableView.h"

#import "SMBActivityCell.h"
#import "SMBActivityManager.h"


@implementation SMBActivityTableView

static NSString *cellIdentifier = @"ActivityCell";

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped manager:[SMBActivityManager sharedManager]];
    
    if (self)
    {
        [self setBackgroundColor:[UIColor simbiWhiteColor]];
        [self setSeparatorColor:[UIColor clearColor]];
        
        [self setNoResultsMessage:@"No Friend Activity"];
        [self setErrorMessage:@"Error Loading Activity"];
        
        [self registerClass:[SMBActivityCell class] forCellReuseIdentifier:cellIdentifier];
    }
    
    return self;
}


#pragma mark - UITableViewDataSource/Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2.f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SMBActivityCell cellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBActivity *activity = [self.objects objectAtIndex:indexPath.row];
    SMBActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell.profilePicture setParseImage:activity.user.profilePicture withType:kImageTypeThumbnail];
    [cell.nameLabel setText:activity.user.name];
    [cell.dateLabel setText:[activity.createdAt relativeDateString]];
    
    // Highlight the name of the location
    
    NSMutableAttributedString *activityText, *highlighted;
    
    activityText = [[NSMutableAttributedString alloc] initWithString:@"Checked in at "
                                                          attributes:@{ NSForegroundColorAttributeName: [UIColor simbiBlackColor] }];
    highlighted  = [[NSMutableAttributedString alloc] initWithString:activity.activityText
                                                          attributes:@{ NSForegroundColorAttributeName: [UIColor simbiBlueColor] }];
    [activityText appendAttributedString:highlighted];
    [cell.activityLabel setAttributedText:activityText];
    
    return cell;
}


@end
