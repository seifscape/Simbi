//
//  SMBImageView.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "PFImageView+Simbi.h"
#import "SMBImageFullscreenView.h"

@interface SMBImageView : PFImageView <UIAlertViewDelegate>

@property (nonatomic, strong) UIImage *rawImage;
@property (nonatomic, strong) SMBImage *parseImage;

- (id)initWithFrame:(CGRect)frame rawImage:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame parseImage:(SMBImage *)image;

- (void)setRawImage:(UIImage *)image;
- (void)setParseImage:(SMBImage *)image;

- (void)saveImageInBackgroundWithBlock:(void (^)(SMBImage *savedImage))block;

@end
