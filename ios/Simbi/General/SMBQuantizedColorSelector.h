//
//  SMBQuantizedColorSelector.h
//  SimbiHairColor
//
//  Created by flynn on 8/13/14.
//  Copyright (c) 2014 MAXX Potential. All rights reserved.
//

@interface SMBQuantizedColorSelector : UIControl

- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray *)colors;
- (void)setSelectedIndex:(NSUInteger)index;
- (void)setSelectorColor:(UIColor *)color;
- (void)setColors:(NSArray *)colors;

@property (nonatomic, strong) UIColor *selectedColor;

@end
