//
//  SMBUserView.h
//  Simbi
//
//  Created by flynn on 5/22/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBUser;


@interface SMBUserView : UIView

- (id)initWithFrame:(CGRect)frame isRevealed:(BOOL)isRevealed;
- (void)setUser:(SMBUser *)user;

@property (nonatomic, strong) SMBUser *user;
@property (nonatomic, strong) SMBImageView *profilePictureView;
@end
