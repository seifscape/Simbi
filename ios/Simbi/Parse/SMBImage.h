//
//  SMBImage.h
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>


@interface SMBImage : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) PFFile *originalImage;
@property (retain) PFFile *mediumImage;
@property (retain) PFFile *mediumSquareImage;
@property (retain) PFFile *thumbnailImage;
@property (retain) NSString *content;

@end
