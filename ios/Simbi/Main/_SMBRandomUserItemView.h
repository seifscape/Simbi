//
//  SMBRandomUserItemView.h
//  Simbi
//
//  Created by flynn on 8/12/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface _SMBRandomUserItemView : UIView

@property (nonatomic, strong) SMBUser *user;

- (instancetype)initWithFrame:(CGRect)frame user:(SMBUser *)user isRevealed:(BOOL)isRevealed;
- (void)setCurrentOffset:(CGFloat)currentOffset topOffset:(CGFloat)topOffset bottomOffset:(CGFloat)bottomOffset;

@end
