//
//  SMBQuantizedColorSelector.m
//  SimbiHairColor
//
//  Created by flynn on 8/13/14.
//  Copyright (c) 2014 MAXX Potential. All rights reserved.
//

#import "SMBQuantizedColorSelector.h"


@interface SMBQuantizedColorSelector ()

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *cgColors;
@property (nonatomic, strong) UIView *selectorView;

@end


@implementation SMBQuantizedColorSelector

- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray *)colors
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setColors:colors];
        
        _selectorView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.height-22)/2.f, (frame.size.height-22)/2.f, 22, 22)];
        [_selectorView setBackgroundColor:[UIColor clearColor]];
        [_selectorView.layer setCornerRadius:_selectorView.frame.size.width/2.f];
        [_selectorView.layer setBorderWidth:6.f];
        [_selectorView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [_selectorView.layer setShadowColor:[UIColor blackColor].CGColor];
        [_selectorView.layer setShadowOffset:CGSizeMake(1.f, 1.f)];
        [_selectorView.layer setShadowOpacity:0.33f];
        [self addSubview:_selectorView];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Draw a gradient of all of the colors
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGGradientRef gradient;
    CGColorSpaceRef colorspace;
    CGFloat locations[_cgColors.count];
    
    for (int i = 0; i < _cgColors.count; i++)
        locations[i] = i*(1/((float)_cgColors.count-1));
    
    colorspace = CGColorSpaceCreateDeviceRGB();
    
    gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)_cgColors, locations);
    
    CGPoint startPoint, endPoint;
    startPoint.x = 0.0;
    startPoint.y = 0.0;
    
    endPoint.x = rect.size.width;
    endPoint.y = 0;
    
    CGContextDrawLinearGradient(context, gradient,
                                startPoint, endPoint, 0);
}


#pragma mark - Public Methods

- (void)setSelectedIndex:(NSUInteger)index
{
    if (!_colors)
        NSAssert(NO, @"%s - Tried to select an index when colors have not been set!", __PRETTY_FUNCTION__);
    if (index >= _colors.count)
        NSAssert(NO, @"%s - Index %ld out of range of provided colors!", __PRETTY_FUNCTION__, (long)index);
    
    // Select the color at that index
    
    _selectedColor = [_colors objectAtIndex:index];
    
    // Move the selector to the middle of that color segment
    
    CGFloat left  = self.frame.size.width *   index   * (1.f/_colors.count);
    CGFloat right = self.frame.size.width * (index+1) * (1.f/_colors.count);
    
    CGPoint point = CGPointMake((left+right)/2.f, self.frame.size.height/2.f);
    
    [_selectorView setCenter:point];
}


- (void)setColors:(NSArray *)colors
{
    _colors = [NSArray arrayWithArray:colors];
    
    _selectedColor = [_colors firstObject];
    
    NSMutableArray *cgColors = [NSMutableArray new];
    
    for (UIColor *color in _colors)
        [cgColors addObject:(id)color.CGColor];
    
    _cgColors = [NSArray arrayWithArray:cgColors];
    
    [self setNeedsDisplay];
}


- (void)setSelectorColor:(UIColor *)color
{
    [_selectorView.layer setBorderColor:color.CGColor];
}


#pragma mark - Touch Event Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { [self newTouch:touches]; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { [self newTouch:touches]; }


void constrainPoint(CGPoint *point, CGRect rect, CGFloat radius)
{
    // Contrains a point inside a given rect so that it will be some
    // value (radius) away from the edge
    
    if (point->x+radius > rect.size.width)
        point->x = rect.size.width-radius;
    if (point->x-radius < 0)
        point->x = radius;
    
    if (point->y+radius > rect.size.height)
        point->y = rect.size.height-radius;
    if (point->y-radius < 0)
        point->y = radius;
}


- (void)newTouch:(NSSet *)touches
{
    // Move the selector view
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    constrainPoint(&point, self.frame, _selectorView.frame.size.width/2.f+2.f);
    
    [_selectorView setCenter:point];
    
    
    // Find the quantized color that they selected
    
    UIColor *selectedColor;
    
    CGFloat width = self.frame.size.width;
    
    for (int i = 0; i < _colors.count; i++)
        if (point.x >=   i   * (1.f/_colors.count)*width &&
            point.x <  (i+1) * (1.f/_colors.count)*width )
            selectedColor = [_colors objectAtIndex:i];
    
    if (selectedColor != _selectedColor)
    {
        // If it's a new color, fire a value changed event
        _selectedColor = selectedColor;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


@end
