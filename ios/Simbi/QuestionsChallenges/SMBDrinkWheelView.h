//
//  SMBDrinkWheelView.h
//  Simbi
//
//  Created by flynn on 6/24/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBDrinkWheelView;

@protocol SMBDrinkWheelViewDelegate
- (void)drinkWheelView:(SMBDrinkWheelView *)drinkWheelView didStopAtDrink:(NSString *)drink;
@end


@interface SMBDrinkWheelView : UIImageView <UIGestureRecognizerDelegate>

- (void)spin;

@property (nonatomic, weak) id<SMBDrinkWheelViewDelegate> delegate;

@end
