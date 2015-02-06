//
//  SMBGameView.h
//  Simbi
//
//  Created by flynn on 6/11/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

@class SMBGameView;

@protocol SMBGameViewDelegate
- (void)gameViewShouldDismiss:(SMBGameView *)gameView;
- (void)gameView:(SMBGameView *)gameView gameDidFinishWithVictory:(BOOL)didWin;
@end


@interface SMBGameView : UIView

- (instancetype)initWithFrame:(CGRect)frame challenge:(SMBChallenge *)challenge;

@property (nonatomic, readonly) NSMutableDictionary *challengeInfo;
@property (nonatomic, readonly) SMBUser *otherUser;
@property (nonatomic, readonly) BOOL otherUserRevealed;
@property (nonatomic, readonly) BOOL isPlayingAlone;

- (void)executeChallengeAction:(NSString *)challengeAction parameters:(NSDictionary *)params withCallback:(void(^)(NSString *response, NSError *error))callback;
- (void)postChatNotificationWithMessage:(NSString *)chatMessage;

@property (nonatomic, weak) id<SMBGameViewDelegate> delegate;

@property (nonatomic, strong) SMBChallenge *challenge;

// Implement these methods when subclassing to handle the start and endpoints of the game.

+ (UIView *)cardWithFrame:(CGRect)frame;
- (void)setUpGame;
- (void)startGame;
- (void)stopGame;
- (void)challengeActionReceived:(NSString *)actionType;
- (void)otherUserDidReveal;

@end
