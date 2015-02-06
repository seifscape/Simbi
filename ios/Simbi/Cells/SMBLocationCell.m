//
//  SMBLocationCell.m
//  Simbi
//
//  Created by flynn on 7/25/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBLocationCell.h"

@implementation SMBLocationCell

+ (CGFloat)cellHeight
{
    return 55;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        CGFloat height = [SMBLocationCell cellHeight];
        
        UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake((height-28)/2.f, (height-28)/2.f, 28, 28)];
        [circleView setBackgroundColor:[UIColor simbiBlueColor]];
        [circleView.layer setCornerRadius:circleView.frame.size.width/2.f];
        [self.contentView addSubview:circleView];
        
        UIView *circleInnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        [circleInnerView setCenter:circleView.center];
        [circleInnerView setBackgroundColor:[UIColor simbiWhiteColor]];
        [circleInnerView.layer setCornerRadius:circleInnerView.frame.size.width/2.f];
        [self.contentView addSubview:circleInnerView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, 0, self.frame.size.width-66, 44)];
        [_titleLabel setTextColor:[UIColor simbiBlueColor]];
        [_titleLabel setFont:[UIFont simbiFontWithSize:14.f]];
        [self.contentView addSubview:_titleLabel];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, height-33, self.frame.size.width-66, 33)];
        [_detailLabel setTextColor:[UIColor simbiGrayColor]];
        [_detailLabel setFont:[UIFont simbiFontWithSize:10.f]];
        [self.contentView addSubview:_detailLabel];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(44, height-0.66f, self.frame.size.width-88, 0.66f)];
        [bottomLine setBackgroundColor:[UIColor simbiGrayColor]];
        [self.contentView addSubview:bottomLine];
    }
    
    return self;
}


@end
