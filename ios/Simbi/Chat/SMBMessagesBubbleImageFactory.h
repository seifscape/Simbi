//
//  SMBMessagesBubbleImageFactory.h
//  Simbi
//
//  Created by flynn on 8/18/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@interface SMBMessagesBubbleImageFactory : NSObject

// Custom re-implementation of JSQMessagesBubbleImageFactory so we can use our own bubbles

+ (UIImageView *)outgoingMessageBubbleImageViewWithColor:(UIColor *)color;
+ (UIImageView *)incomingMessageBubbleImageViewWithColor:(UIColor *)color;

@end
