//
//  SMBRandomUserItemView.m
//  Simbi
//
//  Created by flynn on 8/12/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBRandomUserItemView.h"

#import "SMBImageView.h"


@interface _SMBRandomUserItemView ()

@property (nonatomic, strong) UIView *innerView;

@property (nonatomic) BOOL shouldDrawLines;

@property (nonatomic) CGFloat currentOffset;
@property (nonatomic) CGFloat bottomOffset;
@property (nonatomic) CGFloat topOffset;

@end


@implementation _SMBRandomUserItemView

- (instancetype)initWithFrame:(CGRect)frame user:(SMBUser *)user isRevealed:(BOOL)isRevealed
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _user = user;
        
        _shouldDrawLines = NO;
        
        [self.layer setMasksToBounds:NO];
        
        
        // The view that actually makes up the background color (so we can hide the line behind it)
        _innerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              (frame.size.height-frame.size.width)/2.f,
                                                              frame.size.width,
                                                              frame.size.width)];
        [_innerView makeLayerHexagonal];
        [self addSubview:_innerView];
        
        SMBImageView *imageView = [[SMBImageView alloc] initWithFrame:CGRectMake(_innerView.frame.size.width/4.f,
                                                                                 _innerView.frame.size.height/8.f,
                                                                                 _innerView.frame.size.width/2.f,
                                                                                 _innerView.frame.size.width/2.f)];
        if (isRevealed)
            [imageView setParseImage:user.profilePicture withType:kImageTypeMediumSquare];
        [imageView setBackgroundColor:[UIColor simbiWhiteColor]];
        [imageView.layer setCornerRadius:imageView.frame.size.width/2.f];
        [imageView.layer setMasksToBounds:YES];
        [_innerView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(11,
                                                                       _innerView.frame.size.height/2.f,
                                                                       _innerView.frame.size.width-22,
                                                                       _innerView.frame.size.height/2.f)];
        [nameLabel setText:user.name];
        [nameLabel setTextColor:[UIColor simbiWhiteColor]];
        [nameLabel setFont:[UIFont simbiFontWithSize:14.f]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setNumberOfLines:2];
        [_innerView addSubview:nameLabel];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_shouldDrawLines)
    {
        CGFloat width  = rect.size.width;
        CGFloat height = rect.size.height;
        
        CGFloat lineHeight = (height-width)/2.f;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetStrokeColorWithColor(context, [UIColor simbiDarkGrayColor].CGColor);
        CGContextSetLineWidth(context, 2.f);
        
        // Draw top line
        CGContextMoveToPoint(context, width/2.f, lineHeight+1);
        CGContextAddLineToPoint(context, width/2.f+_topOffset-_currentOffset, -lineHeight-1);
        CGContextDrawPath(context, kCGPathStroke);
        
        // Draw bottom line
        CGContextMoveToPoint(context, width/2.f, height-lineHeight-1);
        CGContextAddLineToPoint(context, width/2.f+_bottomOffset-_currentOffset, height+lineHeight+1);
        CGContextDrawPath(context, kCGPathStroke);
    }
}


- (void)setCurrentOffset:(CGFloat)currentOffset topOffset:(CGFloat)topOffset bottomOffset:(CGFloat)bottomOffset
{
    // In the carousel, each item is offset by a number of pixels. Set the current offsets and provide the offsets of the
    // items directly above and below it so it can draw a connecting line between them.
    
    //          item
    //           |
    //          /
    //         |
    //       item
    
    _shouldDrawLines = YES;
    
    _currentOffset = currentOffset;
    _topOffset = topOffset;
    _bottomOffset = bottomOffset;
    
    [self setNeedsDisplay];
}


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:[UIColor clearColor]];
    
    [_innerView setBackgroundColor:backgroundColor];
}


@end
