//
//  SMBChallengeViewController.h
//  Simbi
//
//  Created by flynn on 5/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBGameView.h"


@class SMBChallengeViewController;

@protocol SMBChallengeViewControllerDelegate
- (void)challengeViewController:(SMBChallengeViewController *)viewController didAcceptWithChatMessage:(NSString *)chatMessage;
- (void)challengeViewControllerDidDecline:(SMBChallengeViewController *)viewController;
@end


@interface SMBChallengeViewController : UIViewController <SMBGameViewDelegate>

- (id)initWithChallenge:(SMBChallenge *)challenge;

@property (nonatomic, weak) id<SMBChallengeViewControllerDelegate> delegate;

@property (nonatomic, strong) SMBChallenge *challenge;
@property (nonatomic, strong) SMBGameView *gameView;

@end
