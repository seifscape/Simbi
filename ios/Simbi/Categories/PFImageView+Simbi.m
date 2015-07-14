//
//  PFImageView+Simbi.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "PFImageView+Simbi.h"

#import <objc/runtime.h>





#pragma mark - Simbi_Private Implementation

@interface PFImageView (Simbi_Private)
    @property (nonatomic, strong) SMBImage *currentImage; // pointer to the current Parse Image that should be displayed
@end


@implementation PFImageView (Simbi_Private)

static const void * CURRENTIMAGE_KEY;

@dynamic currentImage;

- (void)setCurrentImage:(id)currentImage
{
    objc_setAssociatedObject(self, &CURRENTIMAGE_KEY, currentImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)currentImage
{
    return objc_getAssociatedObject(self, &CURRENTIMAGE_KEY);
}

@end





#pragma mark - Simbi Implementation

@implementation PFImageView (Simbi)

#pragma mark - Public Methods

- (void)setParseImage:(SMBImage *)image withType:(kImageType)type
{
    self.currentImage = image; // set currentImage pointer at beginning of callback
    
    if (image.objectId) // if the picture has an objectId, let's nab it from parse
    {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicatorView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [activityIndicatorView startAnimating];
        [self addSubview:activityIndicatorView];
        
        [self fetchImage:image withBlock:^(SMBImage *image, NSError *error)
        {
             
            // check if our currentImage was changed since the beginning of the callback
            if (image && image == self.currentImage)
            {
                switch (type)
                {
                    case kImageTypeThumbnail:
                        [self setFile:image.thumbnailImage];    break;
                    case kImageTypeMedium:
                        [self setFile:image.mediumImage];       break;
                    case kImageTypeMediumSquare:
                        [self setFile:image.mediumSquareImage]; break;
                    case kImageTypeOriginalImage:
                        [self setFile:image.originalImage];     break;
                }
                [self loadInBackground:^(UIImage *image, NSError *error) {
                    
                    [activityIndicatorView stopAnimating];
                    [activityIndicatorView removeFromSuperview];
                }];
            }
            // if it's not in scope anymore, then that's fine. the Image is now fetched and
            // the next time that Image is used for a PFImageView (for example, when scrolling
            // around on a tableView that's reusing cells), it should load much quicker \o/
        }];
    }
    else
    {
        // if there's no actual image, unset everything
        [self setFile:nil];
        [self setImage:nil];
    }
}

- (void)setParseImage:(SMBImage *)image withType:(kImageType)type withBlock:(PFImageSimbiBlock)callback
{
    self.currentImage = image; // set currentImage pointer at beginning of callback
    
    if (image.objectId) // if the picture has an objectId, let's nab it from parse
    {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicatorView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [activityIndicatorView startAnimating];
        [self addSubview:activityIndicatorView];
        
        [self fetchImage:image withBlock:^(SMBImage *image, NSError *error)
         {
             
             // check if our currentImage was changed since the beginning of the callback
             if (image && image == self.currentImage)
             {
                 switch (type)
                 {
                     case kImageTypeThumbnail:
                         [self setFile:image.thumbnailImage];    break;
                     case kImageTypeMedium:
                         [self setFile:image.mediumImage];       break;
                     case kImageTypeMediumSquare:
                         [self setFile:image.mediumSquareImage]; break;
                     case kImageTypeOriginalImage:
                         [self setFile:image.originalImage];     break;
                 }
                 [self loadInBackground:^(UIImage *image, NSError *error) {
                     
                     [activityIndicatorView stopAnimating];
                     [activityIndicatorView removeFromSuperview];
                     
                      callback(nil, nil);
                 }];
    
             }
             // if it's not in scope anymore, then that's fine. the Image is now fetched and
             // the next time that Image is used for a PFImageView (for example, when scrolling
             // around on a tableView that's reusing cells), it should load much quicker \o/
         }];
    }
    else
    {
        // if there's no actual image, unset everything
        [self setFile:nil];
        [self setImage:nil];
    }
}


#pragma mark - Private Methods

- (void)fetchImage:(SMBImage *)image withBlock:(PFImageSimbiBlock)callback
{
    if ([image isDataAvailable]) // if we have data, then return the image immediately
    {
        callback(image, nil);
    }
    else if (image.objectId)
    {
        // kick and shout if it has to fetch something - we *should* be prefetching with -[PFQuery includeKey:]
        NSLog(@"%s : Image has no data! - fetching", __PRETTY_FUNCTION__);
        
        [image fetchInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             if (object)
                 callback((SMBImage *)object, nil);
             else
                 callback(nil, error);
         }];
    }
    else
    {
        callback(nil, nil);
    }
}


@end
