//
//  SMBAnnotation.m
//  Simbi
//
//  Created by flynn on 6/20/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBAnnotation.h"


@interface _SMBAnnotation ()

@property (nonatomic, strong) SMBUser *user;

@end


@implementation _SMBAnnotation

- (instancetype)initWithUser:(SMBUser *)user
{
    self = [super init];
    
    if (self)
    {
        _user = user;
        _coordinate = CLLocationCoordinate2DMake(user.geoPoint.latitude, user.geoPoint.longitude);
    }
    
    return self;
}


- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"Maps"];
    
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:NO];
    [annotationView setBackgroundColor:[UIColor simbiDarkGrayColor]];
    [annotationView.layer setBorderColor:[UIColor blackColor].CGColor];
    [annotationView.layer setBorderWidth:0.5f];
    [annotationView.layer setCornerRadius:22/2.f];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAction:)];
    [annotationView addGestureRecognizer:tapGesture];
    
    [_user.profilePicture.thumbnailImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if (data)
        {
            UIImage *image = [[[UIImage imageWithData:data] imageWithSize:CGSizeMake(22, 22)] imageWithRoundedCornerSize:11.f];
            [annotationView setImage:image];
        }
    }];
    
    return annotationView;
}


- (void)selectAction:(id)sender
{
    if (_delegate)
        [_delegate annotation:self didSelectUser:_user];
}


@end
