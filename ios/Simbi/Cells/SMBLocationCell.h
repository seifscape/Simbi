//
//  SMBLocationCell.h
//  Simbi
//
//  Created by flynn on 7/25/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface SMBLocationCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end
