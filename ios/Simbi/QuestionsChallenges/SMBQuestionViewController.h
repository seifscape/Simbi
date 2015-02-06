//
//  SMBQuestionViewController.h
//  Simbi
//
//  Created by flynn on 5/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//


@class SMBQuestionViewController;

@protocol SMBQuestionViewControllerDelegate
- (void)questionViewController:(SMBQuestionViewController *)viewController didAcceptWithChatMessage:(NSString *)chatMessage;
- (void)questionViewControllerDidDecline:(SMBQuestionViewController *)viewController;
@end


@interface SMBQuestionViewController : UIViewController

- (id)initWithQuestion:(SMBQuestion *)question;

@property (nonatomic, weak) id<SMBQuestionViewControllerDelegate> delegate;

@property (nonatomic, strong) SMBQuestion *question;

@end
