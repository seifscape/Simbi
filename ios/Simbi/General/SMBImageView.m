//
//  SMBImageView.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBImageView.h"

#import "SMBImageFullscreenView.h"


@interface SMBImageView()

@property (nonatomic, strong) UIButton *viewImageButton;
@property (nonatomic, strong) UIButton *retrySaveButton;

@end


@implementation SMBImageView

- (id)initWithFrame:(CGRect)frame rawImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setup];
        [self setImage:image];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame parseImage:(SMBImage *)image
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setup];
        [self setParseImage:image];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
        [self setup];
    
    return self;
}


- (void)setup
{
    [self setBackgroundColor:[UIColor simbiDarkGrayColor]];
    
//    _viewImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_viewImageButton setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    [_viewImageButton addTarget:self action:@selector(viewImage) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_viewImageButton];
    
    _retrySaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_retrySaveButton setFrame:CGRectMake(self.frame.size.width/4.f, self.frame.size.height/4.f, self.frame.size.width/2.f, self.frame.size.height/2.f)];
    [_retrySaveButton setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.66f]];
    [_retrySaveButton.layer setCornerRadius:MIN(_retrySaveButton.frame.size.width, _retrySaveButton.frame.size.height)/2.f];
    [_retrySaveButton setTitle:@"!" forState:UIControlStateNormal];
    [_retrySaveButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:MIN(_retrySaveButton.frame.size.width, _retrySaveButton.frame.size.height)/2.f]];
    [_retrySaveButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_retrySaveButton addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_retrySaveButton];
    
    [_viewImageButton setHidden:YES];
    [_retrySaveButton setHidden:YES];
}


- (void)setParseImage:(SMBImage *)parseImage
{
    [_viewImageButton setHidden:NO];
    [_retrySaveButton setHidden:YES];
    
    _parseImage = parseImage;
    _rawImage = nil;
    
    [self setParseImage:_parseImage withType:kImageTypeMediumSquare];
}


- (void)setRawImage:(UIImage *)rawImage
{
    [_viewImageButton setHidden:NO];
    [_retrySaveButton setHidden:YES];
    
    _rawImage = rawImage;
    _parseImage = nil;
    
    [self setImage:_rawImage];
}


- (void)unsetImage
{
    _rawImage = nil;
    _parseImage = nil;
    self.image = nil;
    
    [_viewImageButton setHidden:YES];
    [_retrySaveButton setHidden:YES];
}


- (void)saveImageInBackgroundWithBlock:(void (^)(SMBImage *savedImage))block
{
    [_viewImageButton setHidden:YES];
    [_retrySaveButton setHidden:YES];
    
    if (_parseImage || _rawImage)
    {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:activityIndicator];
        
        [activityIndicator startAnimating];
        
        SMBImage *imageToSave;
        
        if (_parseImage)
        {
            imageToSave = _parseImage;
        }
        else if (_rawImage)
        {
            imageToSave = [[SMBImage alloc] init];
            [imageToSave setOriginalImage:[PFFile fileWithData:UIImageJPEGRepresentation(_rawImage, 0.6f)]];
        }
        
        [self unsetImage];
        
        [imageToSave saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
             
            if (succeeded)
            {
                [self setParseImage:imageToSave];
                block(_parseImage);
            }
            else
            {
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
                [_retrySaveButton setHidden:NO];
                block(nil);
            }
        }];
    }
    else
    {
        NSLog(@"%s - Tried to save image when an image isn't set!", __PRETTY_FUNCTION__);
        block(nil);
    }

}


- (void)retryAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload Failed" message:@"Would you like to try to upload again?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
        [self saveImageInBackgroundWithBlock:nil];
}



@end
