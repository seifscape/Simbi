//
//  SMBAnswerQuestionViewController.m
//  Simbi
//
//  Created by flynn on 11/16/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBAnswerQuestionViewController.h"

#import "SMBChatManager.h"
#import "SMBFriendsManager.h"

#import "Simbi-Swift.h"

@interface SMBAnswerQuestionViewController()

@property (nonatomic, strong) SMBUser *user;

@property (nonatomic, strong) NSMutableArray *viewedQuestions;
@property (nonatomic, strong) PFObject *currentQuestion;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UITextView *answerTextView;

@end


@implementation SMBAnswerQuestionViewController

- (instancetype)init:(SMBUser *)user
{
    self = [super init];
    
    if (self)
        _user = user;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Answer Question"];
    [self.view setBackgroundColor:[UIColor simbiLightGrayColor]];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(answerQuestionAction:)];
    [self.navigationItem setRightBarButtonItem:sendButton];
    
    
    // Set up subviews
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 20+44, self.view.frame.size.width, 132)];
    [topView setBackgroundColor:[UIColor simbiWhiteColor]];
    
    UIImageView *pictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 110, 110)];
    [pictureImageView setBackgroundColor:[UIColor simbiBlackColor]];
    [pictureImageView setImage:[UIImage imageNamed:@"random_user"]];
    [pictureImageView.layer setCornerRadius:pictureImageView.frame.size.width/2.f];
    [pictureImageView.layer setMasksToBounds:YES];
    [pictureImageView setTransform:CGAffineTransformMakeScale(0.95f, 0.95f)];
    [topView addSubview:pictureImageView];
    
    UIImageView *prefImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11+pictureImageView.frame.size.width-33, 11, 33, 33)];
    [prefImageView setBackgroundColor:[UIColor simbiBlackColor]];
    [prefImageView setImage:[UIImage imageNamed:@"1st_pref"]];
    [prefImageView.layer setCornerRadius:prefImageView.frame.size.width/2.f];
    [prefImageView.layer setMasksToBounds:YES];
    [topView addSubview:prefImageView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(11+pictureImageView.frame.size.width+16, 0, topView.frame.size.width-176-20, 132)];
    [nameLabel setText:_user.firstName];
    [nameLabel setTextColor:[UIColor simbiBlackColor]];
    [nameLabel setFont:[UIFont simbiFontWithSize:22.f]];
    [topView addSubview:nameLabel];
    
    [self.view addSubview:topView];
    
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 20+44+132, self.view.frame.size.width, self.view.frame.size.height-20-44-132)];
    [_bottomView setBackgroundColor:[UIColor simbiLightGrayColor]];
    
    _questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.view.frame.size.width-80, 88)];
    [_questionLabel setTextColor:[UIColor simbiBlackColor]];
    [_questionLabel setFont:[UIFont simbiFontWithAttributes:kFontLight size:16]];
    [_questionLabel setTextAlignment:NSTextAlignmentCenter];
    [_questionLabel setNumberOfLines:3];
    [_bottomView addSubview:_questionLabel];
    
    UIButton *tapOutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _bottomView.frame.size.width, _bottomView.frame.size.height)];
    [tapOutButton addTarget:self.view action:@selector(endEditing:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:tapOutButton];
    
    UIButton *newQuestionButton = [[UIButton alloc] initWithFrame:CGRectMake(_bottomView.frame.size.width-44, 22, 44, 44)];
    [newQuestionButton setImage:[UIImage imageNamed:@"refresh_icon"] forState:UIControlStateNormal];
    [newQuestionButton setAlpha:0.66f];
    [newQuestionButton addTarget:self action:@selector(showRandomQuestion:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:newQuestionButton];
    
    _answerTextView = [[UITextView alloc] initWithFrame:CGRectMake(44, _questionLabel.frame.size.height+11, self.view.frame.size.width-88, _bottomView.frame.size.height-_questionLabel.frame.size.height-44)];
    [_answerTextView setBackgroundColor:[UIColor simbiWhiteColor]];
    [_answerTextView setDelegate:self];
    [_answerTextView setTextColor:[UIColor blackColor]];
    [_answerTextView setFont:[UIFont simbiFontWithSize:18.f]];
    [_answerTextView.layer setCornerRadius:8.f];
    [_bottomView addSubview:_answerTextView];
    
    [self.view addSubview:_bottomView];
    
    
    // Subscribe to keyboard notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    [self showRandomQuestion:self];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - User Actions

- (void)dismissAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)answerQuestionAction:(id)sender
{
    if (_currentQuestion)
    {
        if (_answerTextView.text.length > 0)
        {
            MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Sending..." parent:self];
            
            SMBQuestion *question = [SMBQuestion object];
            [question setQuestionText:_currentQuestion[@"text"]];
            [question setAnswer:_answerTextView.text];
            [question setFromUser:[SMBUser currentUser]];
            [question setToUser:_user];
            
            [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    BOOL isFriend = NO;
                    for (SMBUser *user in [SMBFriendsManager sharedManager].objects)
                        if ([_user.objectId isEqualToString:user.objectId])
                            isFriend = YES;
                    
                    NSDictionary *params = @{ @"questionId" : question.objectId,
                                              @"isFriend"   : [NSNumber numberWithBool:isFriend] };
                    
                    [PFCloud callFunctionInBackground:@"createChatForQuestion" withParameters:params block:^(NSString *chatId, NSError *error) {
                        
                        if (chatId)
                        {
                            [[SMBChatManager sharedManager] addChatWithId:chatId callback:^(BOOL succeeded) {
                                
                                for (PFObject *skippedQuestion in _viewedQuestions)
                                    [skippedQuestion incrementKey:@"skips"];
                                
                                [PFObject saveAllInBackground:_viewedQuestions];
                                
                                [_currentQuestion incrementKey:@"answered"];
                                [_currentQuestion saveEventually];
                                
                                [hud dismissWithSuccess];
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }];
                        }
                        else
                        {
                            [hud dismissWithError];
                            [question deleteEventually];
                        }
                    }];
                }
                else
                {
                    [hud dismissWithError];
                }
            }];
        }
    }
}


- (void)showRandomQuestion:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Disable and spin the button
    
    UIButton *button;
    if ([sender isKindOfClass:[UIButton class]])
        button = sender;
    
    if (button)
    {
        UIButton *button = sender;
        
        [button setUserInteractionEnabled:NO];
        
        [UIView animateWithDuration:0.33/2.f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [button setTransform:CGAffineTransformMakeRotation(M_PI)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.33/2.f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [button setTransform:CGAffineTransformMakeRotation(2*M_PI)];
            } completion:^(BOOL finished) {
                [button setTransform:CGAffineTransformMakeRotation(0)];
            }];
        }];
    }
    
    
    if (_currentQuestion)
        [_viewedQuestions addObject:_currentQuestion];
    _currentQuestion = nil;
    
    
    [UIView animateWithDuration:0.125f animations:^{
        [_questionLabel setAlpha:0.f];
    } completion:^(BOOL finished) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"QuestionSource"];
        [query selectKeys:@[@"text"]];
        [query setLimit:1000];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (objects)
            {
                _currentQuestion = [objects objectAtIndex:(arc4random() % objects.count)];
                _questionLabel.text = _currentQuestion[@"text"];
                
                [UIView animateWithDuration:0.125f animations:^{
                    [_questionLabel setAlpha:1.f];
                } completion:^(BOOL finished) {
                    if (button)
                        [button setUserInteractionEnabled:YES];
                }];
            }
            else
            {
                [_questionLabel setText:@""];
                [_questionLabel setAlpha:1.f];
                
                [[MBProgressHUD HUDwithMessage:@"" parent:self] dismissWithError];
                
                if (button)
                    [button setUserInteractionEnabled:YES];
            }
        }];
    }];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [_bottomView setFrame:CGRectMake(0, 20+44, self.view.frame.size.width, self.view.frame.size.height-20-44-frame.size.height)];
        
        [_answerTextView setFrame:CGRectMake(44, _questionLabel.frame.size.height+11, self.view.frame.size.width-88, _bottomView.frame.size.height-_questionLabel.frame.size.height-22)];
        
    } completion:nil];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [_bottomView setFrame:CGRectMake(0, 20+44+132, self.view.frame.size.width, self.view.frame.size.height-20-44-132)];
        
        [_answerTextView setFrame:CGRectMake(44, _questionLabel.frame.size.height+11, self.view.frame.size.width-88, _bottomView.frame.size.height-_questionLabel.frame.size.height-44)];
        
    } completion:nil];
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
        return YES;
}


@end
