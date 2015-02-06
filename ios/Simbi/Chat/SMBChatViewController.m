//
//  SMBChatViewController.m
//  Simbi
//
//  Created by flynn on 5/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChatViewController.h"

#import "MBProgressHUD.h"

#import "JSQMessagesCollectionViewCell+Simbi.h"
#import "SMBChallengeViewController.h"
#import "SMBChatCircleTimerView.h"
#import "SMBImageFullscreenView.h"
#import "SMBImageView.h"
#import "SMBQuestionViewController.h"
#import "SMBTimerLabel.h"
#import "SMBMessagesBubbleImageFactory.h"


@interface SMBChatViewController ()

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *gameMessages;
@property (nonatomic) BOOL isViewingChat;

@property (nonatomic, strong) SMBChatCircleTimerView *timerView;
@property (nonatomic, strong) SMBImageView *profilePictureView;

@property (nonatomic, strong) NSMutableArray *chatStatusViews;

@property (nonatomic, strong) UIImage *thisUserAvatar;
@property (nonatomic, strong) UIImage *otherUserAvatar;
@property (nonatomic, strong) UIImage *silhouetteAvatar;

@property (nonatomic, strong) UIImageView *outgoingImageView;
@property (nonatomic, strong) UIImageView *outgoingActionImageViewPlain;
@property (nonatomic, strong) UIImageView *outgoingActionImageViewSpecial;
@property (nonatomic, strong) UIImageView *outgoingActionImageViewAccept;

@property (nonatomic, strong) UIImageView *incomingImageView;
@property (nonatomic, strong) UIImageView *incomingActionImageViewPlain;
@property (nonatomic, strong) UIImageView *incomingActionImageViewSpecial;
@property (nonatomic, strong) UIImageView *incomingActionImageViewAccept;

@property (nonatomic) BOOL isLoading;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) SMBTimerLabel *timerLabel;
@property (nonatomic, strong) UIButton *revealButton;
@property (nonatomic, strong) UIButton *removeButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) BOOL startedWithQuestionOrChallenge;

@property (nonatomic, strong) NSNumber *forcedRevealIndex;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSTimer *isTypingTimeout;

@end


typedef enum SMBChatViewAlertType : NSInteger
{
    kChatAlertTypeReveal,
    kChatAlertTypeRemove
} SMBChatViewAlertType;


@implementation SMBChatViewController

#pragma mark - View Lifecycle

+ (instancetype)messagesViewControllerWithChat:(SMBChat *)chat isViewingChat:(BOOL)isViewingChat
{
    SMBChatViewController *chatViewController = [SMBChatViewController messagesViewController];
    [chatViewController setChat:chat];
    [chatViewController setIsViewingChat:isViewingChat];
    return chatViewController;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isLoading = NO;
    
    [self setTitle:[_chat otherUser].name];

    [self setSender:@"ME"];
    
    if (_chat.currentChallenge)
    {
        UIBarButtonItem *chatGamesButton = [[UIBarButtonItem alloc] initWithTitle:(_isViewingChat ? @"Game" : @"Chat") style:UIBarButtonItemStylePlain target:self action:@selector(chatGamesAction:)];
        [self.navigationItem setRightBarButtonItem:chatGamesButton];
    }
    
    // Add profile picture and timer to navigation bar
    
    CGFloat width = self.view.frame.size.width;
    
    _timerView = [[SMBChatCircleTimerView alloc] initWithFrame:CGRectMake(width-44+4, 4, 36, 36) chat:_chat];
    [_timerView setBackgroundColor:[UIColor clearColor]];
    [_timerView.layer setCornerRadius:_timerView.frame.size.width/2.f];
    [_timerView.layer setMasksToBounds:YES];
    [_timerView.layer setBorderColor:[UIColor clearColor].CGColor];
    [_timerView.layer setBorderWidth:.66f];
    [self.navigationController.navigationBar addSubview:_timerView];
    
    _profilePictureView = [[SMBImageView alloc] initWithFrame:CGRectMake(width-44+6, 6, 32, 32)];
    [_profilePictureView setBackgroundColor:[UIColor blackColor]];
    [_profilePictureView.layer setMasksToBounds:YES];
    [_profilePictureView.layer setCornerRadius:_profilePictureView.frame.size.width/2.f];
    [_profilePictureView setClipsToBounds:YES];
    
    if ([_chat otherUserHasRevealed] || _chat.forceRevealed)
        [_profilePictureView setParseImage:[_chat otherUser].profilePicture];
    else
        [_profilePictureView setRawImage:[UIImage imageNamed:@"Silhouette.png"]];
    
    [self.navigationController.navigationBar addSubview:_profilePictureView];
    
    
    // Configure JSQ
    
    [self.collectionView.collectionViewLayout setMessageBubbleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.f]];
    [self.inputToolbar.contentView.textView setDelegate:self];
    [self.inputToolbar.contentView.textView setFont:[UIFont simbiFontWithSize:16.f]];
    [self.inputToolbar.contentView.textView setBackgroundColor:[UIColor simbiWhiteColor]];
    [self.inputToolbar.contentView setBackgroundColor:[UIColor simbiWhiteColor]];
    [self.inputToolbar.contentView.textView.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.inputToolbar.contentView.textView setTintColor:[UIColor simbiBlueColor]];
    [self.inputToolbar.contentView.textView setPlaceHolder:@"Message"];
    [self.inputToolbar.contentView.textView setPlaceHolderTextColor:[UIColor simbiGrayColor]];
    [self.inputToolbar.contentView.textView setTextColor:[UIColor simbiDarkGrayColor]];
    [self.inputToolbar.contentView setLeftBarButtonItem:nil];
    [self.inputToolbar.contentView.rightBarButtonItem.titleLabel setFont:[UIFont simbiBoldFontWithSize:18.f]];
    [self.collectionView setBackgroundColor:[UIColor simbiWhiteColor]];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self setAutomaticallyScrollsToMostRecentMessage:YES];
    
    
    [self.inputToolbar setHidden:!_isViewingChat];
    
    
    // Bubble views
    
    _outgoingImageView = [SMBMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor simbiLightGrayColor]];
    _outgoingActionImageViewPlain = [SMBMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor simbiGrayColor]];
    _outgoingActionImageViewSpecial = [SMBMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor simbiGreenColor]];
    _outgoingActionImageViewAccept = [SMBMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor simbiYellowColor]];
    
    _incomingImageView = [SMBMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor simbiBlueColor]];
    _incomingActionImageViewPlain = [SMBMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor simbiGrayColor]];
    _incomingActionImageViewSpecial = [SMBMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor simbiGreenColor]];
    _incomingActionImageViewAccept = [SMBMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor simbiYellowColor]];
    
    
    // Add self as delegate to the chat manager to receive updates
    
    [[SMBChatManager sharedManager] addChatDelegate:self forChat:_chat];
    _messages = [NSMutableArray arrayWithArray:[[SMBChatManager sharedManager] messagesForChat:_chat]];
    _gameMessages = [NSMutableArray arrayWithArray:[[SMBChatManager sharedManager] gameMessagesForChat:_chat]];
    
    
    // Set up top view
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20+44, self.view.frame.size.width, 66)];
    [_topView setBackgroundColor:[UIColor simbiLightGrayColor]];
    
    _timerLabel = [[SMBTimerLabel alloc] initWithFrame:CGRectMake(0, 0, width/2.f-20, 66) chat:_chat];
    [_timerLabel setFont:[UIFont simbiFontWithSize:32.f]];
    [_timerLabel setTextAlignment:NSTextAlignmentCenter];
    [_topView addSubview:_timerLabel];
    
    _revealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_revealButton setFrame:CGRectMake(width/2.f-20, (66-32)/2.f, width/4.f, 32)];
    [_revealButton setBackgroundColor:[UIColor simbiBlueColor]];
    [_revealButton setTitle:@"Reveal" forState:UIControlStateNormal];
    [_revealButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_revealButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:16.f]];
    [_revealButton addTarget:self action:@selector(promptRevealAction:) forControlEvents:UIControlEventTouchUpInside];
    [_revealButton roundSide:kSMBSideLeft];
    [_topView addSubview:_revealButton];
    
    // Disable the revealed button if they have already revealed or the other user left
    if ([_chat otherUserHasRemoved] || [_chat thisUserHasRevealed] || [_timerLabel hasExpired] || _chat.forceRevealed)
    {
        [_revealButton setBackgroundColor:[UIColor simbiGrayColor]];
        [_revealButton setEnabled:NO];
        
        if ([_chat thisUserHasRevealed] || _chat.forceRevealed)
            [_revealButton setTitle:@"Revealed!" forState:UIControlStateNormal];
    }
    
    _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_removeButton setFrame:CGRectMake(_revealButton.frame.origin.x+_revealButton.frame.size.width, (66-32)/2.f, width/4.f, 32)];
    [_removeButton setBackgroundColor:[UIColor simbiRedColor]];
    [_removeButton setTitle:@"Remove" forState:UIControlStateNormal];
    [_removeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_removeButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:16.f]];
    [_removeButton addTarget:self action:@selector(promptRemoveAction:) forControlEvents:UIControlEventTouchUpInside];
    [_removeButton roundSide:kSMBSideRight];
    [_topView addSubview:_removeButton];
    
    [self.view addSubview:_topView];
    
    
    // Load the current user's profile picture
    
    if (![[SMBUser currentUser].profilePicture isDataAvailable])
    {
        NSLog(@"%s - WARNING: [SMBUser currentUser].profilePicture has no data. Fetching...", __PRETTY_FUNCTION__);
        [[SMBUser currentUser].profilePicture fetch];
    }
    
    [[SMBUser currentUser].profilePicture.thumbnailImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if (data)
            _thisUserAvatar = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageWithData:data]
                                                               diameter:self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width];
        else
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
        
        [self.collectionView reloadData];
    }];
    
    
    // Load the other user's profile picture if they are revealed, otherwise just use the silhouette view
    
    if ([_chat otherUserHasRevealed] || _chat.forceRevealed)
    {
        if (![[_chat otherUser].profilePicture isDataAvailable])
        {
            NSLog(@"%s - WARNING: [_chat otherUser].profilePicture has no data. Fetching...", __PRETTY_FUNCTION__);
            [[_chat otherUser].profilePicture fetch];
        }
        
        [[_chat otherUser].profilePicture.thumbnailImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            if (data)
                    _otherUserAvatar = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageWithData:data]
                                                                        diameter:self.collectionView.collectionViewLayout.incomingAvatarViewSize.width];
            else
                NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            
            [self.collectionView reloadData];
        }];
    }
    else
    {
        UIImage *image = [[UIImage imageNamed:@"Silhouette.png"] imageWithBackgroundColorForName:[_chat otherUser].name];
        _otherUserAvatar = [JSQMessagesAvatarFactory avatarWithImage:image
                                                            diameter:self.collectionView.collectionViewLayout.incomingAvatarViewSize.width];
    }
}


- (void)dealloc
{
    [[SMBChatManager sharedManager] cleanDelegatesForChat:_chat];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.inputToolbar setBarTintColor:[UIColor simbiWhiteColor]];
    
    [_timerView setAlpha:0.f];
    [_profilePictureView setAlpha:0.f];
    
    [self.navigationController.navigationBar addSubview:_timerView];
    [self.navigationController.navigationBar addSubview:_profilePictureView];
    
    [UIView animateWithDuration:0.25f animations:^{
        [_timerView setAlpha:1.f];
        [_profilePictureView setAlpha:1.f];
    }];
    
    if (![_chat otherUserHasRemoved] && ![_timerLabel hasExpired])
    {
        // if the current question or challenge hasn't been accepted, present those views
        
        if (_chat.startedWithQuestion && [[SMBUser currentUser].objectId isEqualToString:_chat.currentQuestion.toUser.objectId])
        {
            SMBQuestionViewController *viewController = [[SMBQuestionViewController alloc] initWithQuestion:_chat.currentQuestion];
            [viewController setDelegate:[SMBChatManager sharedManager]];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [self.navigationController presentViewController:navigationController animated:NO completion:nil];
            _startedWithQuestionOrChallenge = YES;
        }
        else if (_chat.startedWithChallenge && [[SMBUser currentUser].objectId isEqualToString:_chat.currentChallenge.toUser.objectId])
        {
            if (!_chat.currentChallenge.accepted)
            {
                SMBChallengeViewController *viewController = [[SMBChallengeViewController alloc] initWithChallenge:_chat.currentChallenge];
                [viewController setDelegate:[SMBChatManager sharedManager]];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                [self.navigationController presentViewController:navigationController animated:NO completion:nil];
                _startedWithQuestionOrChallenge = YES;
            }
            else
            {
                [_chat setStartedWithChallenge:NO];
                [_chat saveEventually];
            }
        }
    }
    
    
    if ([_timerLabel hasExpired])
    {
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.inputToolbar setHidden:YES];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.collectionView.collectionViewLayout setSpringinessEnabled:NO];
    
    if ([_timerLabel hasExpired])
    {
        [self.navigationController setToolbarHidden:YES];
        [self.inputToolbar setHidden:YES];
    }
    
    if (_startedWithQuestionOrChallenge)
    {
        _startedWithQuestionOrChallenge = NO;
        
        if (_chat.startedWithChallenge || _chat.startedWithQuestion)
            [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_chat setThisUsersHasRead:YES];
    [_chat saveInBackground];
    
    // Stagger fades so we don't see the 'pie chart' of SMBChatCircleView
    [UIView animateWithDuration:0.125f animations:^{
        [_timerView setAlpha:0.f];
    } completion:^(BOOL finished) {
        [_timerView removeFromSuperview];
        
        [UIView animateWithDuration:0.125f animations:^{
            [_profilePictureView setAlpha:0.f];
        } completion:^(BOOL finished) {
            [_profilePictureView removeFromSuperview];
        }];
    }];
}


#pragma mark - JSQMessagesCollectionViewDataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) // First message is empty
        return [JSQMessage messageWithText:@"\n\n\n" sender:@"___no one"];
    
    
    return ((SMBMessage *)[(_isViewingChat ? _messages : _gameMessages) objectAtIndex:indexPath.row]).JSQMessage;
}


- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) // First message is empty
        return nil;
    
    
    SMBMessage *message = [(_isViewingChat ? _messages : _gameMessages) objectAtIndex:indexPath.row];
    
    UIImageView *imageView;

    if ([message.fromUser.objectId isEqualToString:[SMBUser currentUser].objectId])
    {
        if (message.isAction)
        {
            if (message.isAccept)
                imageView = [[UIImageView alloc] initWithImage:_outgoingActionImageViewAccept.image highlightedImage:_outgoingActionImageViewAccept.highlightedImage];
            else if (message.challengeId || message.questionId)
                imageView = [[UIImageView alloc] initWithImage:_outgoingActionImageViewSpecial.image highlightedImage:_outgoingActionImageViewSpecial.highlightedImage];
            else
                imageView = [[UIImageView alloc] initWithImage:_outgoingActionImageViewPlain.image highlightedImage:_outgoingActionImageViewPlain.highlightedImage];
        }
        else
            imageView = [[UIImageView alloc] initWithImage:_outgoingImageView.image
                                      highlightedImage:_outgoingImageView.highlightedImage];
    }
    else
    {
        if (message.isAction)
        {
            if (message.isAccept)
                imageView = [[UIImageView alloc] initWithImage:_incomingActionImageViewAccept.image highlightedImage:_incomingActionImageViewAccept.highlightedImage];
            else if (message.challengeId || message.questionId)
                imageView = [[UIImageView alloc] initWithImage:_incomingActionImageViewSpecial.image highlightedImage:_incomingActionImageViewSpecial.highlightedImage];
            else
                imageView = [[UIImageView alloc] initWithImage:_incomingActionImageViewPlain.image highlightedImage:_incomingActionImageViewPlain.highlightedImage];
        }
        else
            imageView = [[UIImageView alloc] initWithImage:_incomingImageView.image
                                      highlightedImage:_incomingImageView.highlightedImage];
    }
    
    return imageView;
}


- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) // First message is empty
        return nil;
    
    
    SMBMessage *message = [(_isViewingChat ? _messages : _gameMessages) objectAtIndex:indexPath.row];

    if ([message.fromUser.objectId isEqualToString:[SMBUser currentUser].objectId])
        return [[UIImageView alloc] initWithImage:_thisUserAvatar];
    else
        return [[UIImageView alloc] initWithImage:_otherUserAvatar];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_messages && _isViewingChat)
        return _messages.count;
    else if (_gameMessages && !_isViewingChat)
        return _gameMessages.count;
    else
        return 0;
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    SMBMessage *message = [(_isViewingChat ? _messages : _gameMessages) objectAtIndex:indexPath.row];
    
    
    [cell setClipsToBounds:NO];
    [cell.textView setTextColor:[UIColor whiteColor]];
    
    
    if (indexPath.row == 0) // First message is empty
    {
        if (cell.selectButton)
            [cell.selectButton setEnabled:NO];
        if (cell.avatarButton)
            [cell.avatarButton setEnabled:NO];
        if (cell.chatStatusView)
            [cell.chatStatusView removeFromSuperview];
        
        return cell;
    }

    
    if ([message.fromUser.objectId isEqualToString:[SMBUser currentUser].objectId])
        [cell.textView setTextColor:[UIColor simbiDarkGrayColor]];
    
    if (message.isAction && (message.challengeId || message.questionId || message.isAccept))
        [cell.textView setTextColor:[UIColor blackColor]];
    
    
    if (!cell.selectButton)
    {
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectButton addTarget:self action:@selector(cellSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:selectButton];
        
        [cell setSelectButton:selectButton];
    }
    [cell.selectButton setEnabled:YES];
    [cell.selectButton setFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [cell.selectButton setTag:indexPath.row];
    
    
    if (!cell.avatarButton)
    {
        UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [avatarButton addTarget:self action:@selector(avatarSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:avatarButton];
        
        [cell setAvatarButton:avatarButton];
    }
    CGFloat avatarWidth = self.collectionView.collectionViewLayout.outgoingAvatarViewSize.width;
    
    [cell.avatarButton setFrame:CGRectMake(0, cell.frame.size.height-avatarWidth, avatarWidth, avatarWidth)];
    [cell.avatarButton setTag:indexPath.row];
    
    if ([[_chat otherUser].objectId isEqualToString:message.fromUser.objectId])
        [cell.avatarButton setEnabled:YES];
    else
        [cell.avatarButton setEnabled:NO];

    
    if (cell.chatStatusView) // remove the current one
        [cell.chatStatusView removeFromSuperview];
    
    if (_isViewingChat)
    {
        [cell setChatStatusView:[_chatStatusViews objectAtIndex:indexPath.row]];
        [cell addSubview:cell.chatStatusView];
        [cell.chatStatusView setFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    }

    
    return cell;
}


- (UICollectionReusableView *)collectionView:(JSQMessagesCollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (self.showTypingIndicator && [kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        UICollectionReusableView *typingView = [collectionView dequeueTypingIndicatorFooterViewIncoming:YES
                                                                                     withIndicatorColor:[UIColor simbiWhiteColor]
                                                                                            bubbleColor:[UIColor simbiLightGrayColor]
                                                                                           forIndexPath:indexPath];
        [typingView setBackgroundColor:[UIColor clearColor]];
        return typingView;
    }
    else if (self.showLoadEarlierMessagesHeader && [kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        return [collectionView dequeueLoadEarlierMessagesViewHeaderForIndexPath:indexPath];
    }
    
    return nil;
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
        return 16;
    else if (_isViewingChat
             && indexPath.row == _forcedRevealIndex.integerValue
             && (!_chat.userOneRevealed || !_chat.userTwoRevealed)
             && indexPath.row > 1)
        return 44;
    else
        return 0;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
    {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:12.f];
        
        UIColor *color = [UIColor simbiGrayColor];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        NSString *message;
        
        if (_chat.currentChallenge)
            message = @"Tap the green bubbles to play!";
        else if (_chat.currentQuestion)
            message = @"Tap the green bubbles to see!";
        else
        {
            message = @"";
            NSLog(@"%s - WARNING: Neither currentChallenge nor currentQuestion is set!", __PRETTY_FUNCTION__);
        }
        
        return [[NSAttributedString alloc] initWithString:message
                                               attributes:@{ NSFontAttributeName:            font,
                                                             NSForegroundColorAttributeName: color,
                                                             NSParagraphStyleAttributeName:  paragraphStyle }];
    }
    else if (_isViewingChat && indexPath.row == _forcedRevealIndex.integerValue && (!_chat.userOneRevealed || !_chat.userTwoRevealed) && indexPath.row > 1)
    {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14.f];
        
        UIColor *color = [UIColor simbiDarkGrayColor];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        return [[NSAttributedString alloc] initWithString:@"Talking much? Revealed!"
                                               attributes:@{ NSFontAttributeName:            font,
                                                             NSForegroundColorAttributeName: color,
                                                             NSParagraphStyleAttributeName:  paragraphStyle }];
    }
    else
        return nil;
}


#pragma mark - UIScrollView Delegate (Pull to refresh)

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -152.f && _messages.count > 1)
    {
        [_chat fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [[SMBChatManager sharedManager] reloadMessagesForChat:_chat];
        }];
    }
}


#pragma mark - JSQMessagesViewController

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date
{
    // Create a dummy message object
    
    SMBMessage *message = [[SMBMessage alloc] init];
    [message setFromUser:[SMBUser currentUser]];
    [message setToUser:[_chat otherUser]];
    [message setChat:_chat];
    [message setMessageText:text];
        
    
    // If this is the recipient user and the timer hasn't started yet, start the timer!
    
    if ([[SMBUser currentUser].objectId isEqualToString:_chat.userTwo.objectId] && ![_timerLabel hasTime])
        [_timerLabel setDate:[NSDate date]];
    
    
    // Add message to the chat list
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [_messages addObject:message];
    
    [self prepareCellStatusViews];
    
    [self.view endEditing:YES];
    
    [self finishSendingMessage];
    
    
    // Send the message through Parse
    
    [[SMBChatManager sharedManager] sendMessageForChat:_chat withText:text dummyMessage:message callback:nil];
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    else
    {
        [[SMBChatManager sharedManager] currentUserDidTypeForChat:_chat];
        return YES;
    }
}


#pragma mark - User Actions

- (void)chatGamesAction:(UIBarButtonItem *)button
{
    _isViewingChat = !_isViewingChat;
    [self setTitle:(_isViewingChat ? @"Chat" : @"Game")];
    [button setTitle:(_isViewingChat ? @"Game" : @"Chat")];
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
    
    [self.inputToolbar setHidden:!_isViewingChat];
}


- (void)cellSelectedAction:(UIButton *)button
{
    if (_isViewingChat)
    {
        if (button.tag > _messages.count)
        {
            NSLog(@"%s - WARNING: Button tag %ld is out of range!", __PRETTY_FUNCTION__, (long)button.tag);
            return;
        }
        
        SMBMessage *message = [_messages objectAtIndex:button.tag];
        
        if (message.isAction)
        {
            if (message.challengeId)
            {
                SMBChallengeViewController *viewController = [[SMBChallengeViewController alloc] initWithChallenge:_chat.currentChallenge];
                [viewController setDelegate:[SMBChatManager sharedManager]];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            }
            else if (message.questionId)
            {
                SMBQuestionViewController *viewController = [[SMBQuestionViewController alloc] initWithQuestion:_chat.currentQuestion];
                [viewController setDelegate:[SMBChatManager sharedManager]];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            }
        }
    }
    else
    {
        SMBChallengeViewController *viewController = [[SMBChallengeViewController alloc] initWithChallenge:_chat.currentChallenge];
        [viewController setDelegate:[SMBChatManager sharedManager]];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}


- (void)avatarSelectedAction:(UIButton *)button
{
    if ([_chat otherUserHasRevealed] || _chat.forceRevealed)
    {
        SMBMessage *message = [_messages objectAtIndex:button.tag];
        
        if ([[_chat otherUser].objectId isEqualToString:message.fromUser.objectId])
        {
            SMBImageFullscreenView *fullscreenView = [[SMBImageFullscreenView alloc] initWithImage:[_chat otherUser].profilePicture];
            [fullscreenView show];
        }
    }
}


- (void)promptRevealAction:(UIButton *)button
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reveal" message:@"Are you sure you want to reveal yourself?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setTag:kChatAlertTypeReveal];
    [alertView show];
}


- (void)revealAction
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Revealing..." parent:self];
    
    [PFCloud callFunctionInBackground:@"revealUserInChat" withParameters:@{ @"chatId" : _chat.objectId } block:^(id object, NSError *error) {
        
        if (object)
        {
            [_chat setThisUsersHasRevealed:YES];
            
            [hud dismissWithMessage:@"Revealed!"];
            
            [_revealButton setTitle:@"Revealed!" forState:UIControlStateNormal];
            [_revealButton setBackgroundColor:[UIColor simbiGrayColor]];
            [_revealButton setEnabled:NO];
            
            SMBMessage *message = [[SMBMessage alloc] init];
            [message setFromUser:[SMBUser currentUser]];
            [message setToUser:[_chat otherUser]];
            [message setMessageText:@"Revealed!"];
            [message setIsAction:YES];
            
            [_messages addObject:message];
            
            [self prepareCellStatusViews];
            
            [self finishSendingMessage];
            [self scrollToBottomAnimated:YES];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [hud dismissWithError];
        }
    }];
}


- (void)promptRemoveAction:(UIButton *)button
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove" message:@"Are you sure you want to remove this chat?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setTag:kChatAlertTypeRemove];
    [alertView show];
}


- (void)removeAction
{
    [PFCloud callFunctionInBackground:@"removeUserFromChat" withParameters:@{ @"chatId" : _chat.objectId } block:^(id object, NSError *error) {
        
        if (error)
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
    }];
    
    [_chat setThisUserRemoved:YES];
    
    [[SMBChatManager sharedManager] removeObject:_chat];
    
    if (_delegate)
        [_delegate chatViewController:self didDeclineChat:_chat];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
    {
        if (alertView.tag == kChatAlertTypeReveal)
        {
            [self revealAction];
        }
        else if (alertView.tag == kChatAlertTypeRemove)
        {
            [self removeAction];
        }
    }
}


#pragma mark - SMBChatManagerDelegate

- (void)chatManager:(SMBChatManager *)chatManager willLoadMessagesForChat:(SMBChat *)chat
{
    _chat = chat;
    
    if (_messages.count <= 1)
    {
        if (!_activityIndicatorView)
        {
            _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [_activityIndicatorView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        }
        [_activityIndicatorView startAnimating];
        [self.view addSubview:_activityIndicatorView];
        
        _messages = nil;
        [self.collectionView reloadData];
    }
}


- (void)chatManager:(SMBChatManager *)chatManager didLoadMessages:(NSMutableArray *)messages gameMessages:(NSMutableArray *)gameMessages forChat:(SMBChat *)chat
{
    _chat = chat;
    
    [_activityIndicatorView stopAnimating];
    [_activityIndicatorView removeFromSuperview];
    
    [_chatStatusViews removeAllObjects];
    
    _messages = [NSMutableArray arrayWithArray:messages];
    _gameMessages = [NSMutableArray arrayWithArray:gameMessages];
    
    [self prepareCellStatusViews];
    
    [self.collectionView reloadData];
}


- (void)chatManager:(SMBChatManager *)chatManager failedToLoadMessagesForChat:(SMBChat *)chat error:(NSError *)error
{
    _chat = chat;
    
    [MBProgressHUD showMessage:@"Network Error!" parent:self];
}


- (void)chatManager:(SMBChatManager *)chatManager didReceiveMessage:(SMBMessage *)message forChat:(SMBChat *)chat
{
    _chat = chat;
    
    if (!message.messageText || message.messageText.length == 0)
    {
        NSLog(@"%s - WARNING: Received message without any text! Discarding...", __PRETTY_FUNCTION__);
        return;
    }
    
    if (!_chat.dateStarted)
        [_timerView setTime:[NSDate date]];
    
    if (self.navigationController.visibleViewController == self)
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    
    [_messages addObject:message];
    
    if (_isViewingChat)
    {
        [self prepareCellStatusViews];
        
        if ([[SMBUser currentUser].objectId isEqualToString:message.fromUser.objectId])
            [self finishSendingMessage];
        else
            [self finishReceivingMessage];
    }
}


- (void)chatManager:(SMBChatManager *)chatManager didReceiveGameMessage:(SMBMessage *)message forChat:(SMBChat *)chat
{
    _chat = chat;
    
    if (!message.messageText || message.messageText.length == 0)
    {
        NSLog(@"%s - WARNING: Received message without any text! Discarding...", __PRETTY_FUNCTION__);
        return;
    }
    
    if (!_chat.dateStarted)
        [_timerView setTime:[NSDate date]];
    
    if (self.navigationController.visibleViewController == self)
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    
    [_gameMessages addObject:message];
    
    if (!_isViewingChat)
    {
        [self prepareCellStatusViews];
        
        if ([[SMBUser currentUser].objectId isEqualToString:message.fromUser.objectId])
            [self finishSendingMessage];
        else
            [self finishReceivingMessage];
    }
}


- (void)chatManager:(SMBChatManager *)chatManager chatDidExpire:(SMBChat *)chat
{
    _chat = chat;
    
    [_revealButton setBackgroundColor:[UIColor simbiGrayColor]];
    [_revealButton setEnabled:NO];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.inputToolbar setHidden:YES];
}


- (void)chatManager:(SMBChatManager *)chatManager otherUserDidRevealWithImage:(UIImage *)image inChat:(SMBChat *)chat
{
    _chat = chat;
    
    _otherUserAvatar = [JSQMessagesAvatarFactory avatarWithImage:image
                                                        diameter:self.collectionView.collectionViewLayout.incomingAvatarViewSize.width];
    
    [self.collectionView reloadData];
}


- (void)chatManager:(SMBChatManager *)chatManager otherUserLeftChat:(SMBChat *)chat
{
    _chat = chat;
    
    if (_delegate)
        [_delegate chatViewController:self didDeclineChallengeFromChat:_chat];
}


- (void)chatManager:(SMBChatManager *)chatManager didDeclineChat:(SMBChat *)chat
{
    _chat = chat;
    
    if (_delegate)
        [_delegate chatViewController:self didDeclineChat:_chat];
}


- (void)chatManager:(SMBChatManager *)chatManager otherUserIsTyping:(BOOL)isTyping forChat:(SMBChat *)chat
{
    if (_isTypingTimeout)
        [_isTypingTimeout invalidate];
    
    if (isTyping)
        _isTypingTimeout = [NSTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(isTypingTimeout:) userInfo:self repeats:NO];
    
    [self setShowTypingIndicator:isTyping];
}


- (void)chatManager:(SMBChatManager *)chatManager forcedRevealAtIndex:(NSInteger)index forChat:(SMBChat *)chat
{
    _chat = chat;
    
    _forcedRevealIndex = [NSNumber numberWithInteger:index];
    
    [_revealButton setBackgroundColor:[UIColor simbiGrayColor]];
    [_revealButton setEnabled:NO];
    [_revealButton setTitle:@"Revealed!" forState:UIControlStateNormal];
}


#pragma mark - Private Methods

- (void)prepareCellStatusViews
{
    if (!_chatStatusViews)
        _chatStatusViews = [NSMutableArray new];
    
    if (_chatStatusViews.count < _messages.count)
    {
        for (int i = 0; i < _messages.count; i++)
        {
            if (i >= _chatStatusViews.count)
            {
                SMBMessage *message = [_messages objectAtIndex:i];
                
                SMBChatStatusView *chatStatusView = [[SMBChatStatusView alloc] initWithFrame:CGRectZero message:message delegate:[SMBChatManager sharedManager]];
                [_chatStatusViews addObject:chatStatusView];
            }
        }
    }
}


- (void)isTypingTimeout:(NSTimer *)timer
{
    [self setShowTypingIndicator:NO];
}


@end
