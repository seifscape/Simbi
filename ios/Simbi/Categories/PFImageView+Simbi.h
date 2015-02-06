//
//  PFImageView+Simbi.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBImage;


@interface PFImageView (Simbi)

// Methods to help interface with the "Image" class on Parse

// these methods will load the image safely without crashing the
// app if the image is not yet fetched.

typedef enum kImageType : NSInteger
{
    kImageTypeThumbnail,
    kImageTypeMedium,
    kImageTypeMediumSquare,
    kImageTypeOriginalImage
} kImageType;

typedef void (^PFImageSimbiBlock)(SMBImage *image, NSError *error);

@property (nonatomic, strong) id currentImage;

- (void)setParseImage:(SMBImage *)image withType:(kImageType)type;

@end
