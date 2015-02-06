//
//  SMBQuestionViewController.m
//  Simbi
//
//  Created by flynn on 5/23/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBQuestionViewController.h"

#import "SMBUserView.h"


@implementation SMBQuestionViewController

- (id)initWithQuestion:(SMBQuestion *)question
{
    self = [super init];
    
    if (self)
        _question = question;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationItem setTitle:@"Answer"];
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction:)];
    [self.navigationItem setLeftBarButtonItem:dismissButton];
    
    
    // Set up views
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20+44, width, 44)];
    [titleLabel setText:[NSString stringWithFormat:@"%@ answered a question!", _question.fromUser.name]];
    if ([[SMBUser currentUser].objectId isEqualToString:_question.fromUser.objectId])
        [titleLabel setText:@"You answered a question!"];
    [titleLabel setTextColor:[UIColor simbiRedColor]];
    [titleLabel setFont:[UIFont simbiBoldFontWithSize:14.f]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    // question 44
    // answer   32
    // textView 66
    // padding  16
    // button   44
    // padding  16
    
    CGFloat bottomViewHeight = 52+32+66+16+44+16;
    
    
    BOOL hasRevealed;
    
    if ([_question.fromUser.objectId isEqualToString:_question.chat.userOne.objectId])
        hasRevealed = _question.chat.userOneRevealed;
    else
        hasRevealed = _question.chat.userTwoRevealed;
    
    SMBUserView *userView = [[SMBUserView alloc] initWithFrame:CGRectMake(0, 20+44+44, width, height-20-44-44-bottomViewHeight) isRevealed:hasRevealed];
    [userView setUser:_question.fromUser];
    [self.view addSubview:userView];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height-bottomViewHeight, width, bottomViewHeight)];
    [bottomView setBackgroundColor:[UIColor simbiWhiteColor]];
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, width-88, 52)];
    [questionLabel setText:_question.questionText];
    [questionLabel setTextColor:[UIColor simbiDarkGrayColor]];
    [questionLabel setFont:[UIFont simbiBoldFontWithSize:15.f]];
    [questionLabel setTextAlignment:NSTextAlignmentCenter];
    [questionLabel setNumberOfLines:0];
    [bottomView addSubview:questionLabel];
    
    UILabel *answerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, questionLabel.frame.origin.y+questionLabel.frame.size.height, width-88, 32)];
    [answerTitleLabel setText:[NSString stringWithFormat:@"%@'s answer:", _question.fromUser.name]];
    if ([[SMBUser currentUser].objectId isEqualToString:_question.fromUser.objectId])
        [answerTitleLabel setText:@"Your answer:"];
    [answerTitleLabel setTextColor:[UIColor simbiBlueColor]];
    [answerTitleLabel setFont:[UIFont simbiBoldFontWithSize:15.f]];
    [answerTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [bottomView addSubview:answerTitleLabel];
    
    
    BOOL shouldShowButton = !([[SMBUser currentUser].objectId isEqualToString:_question.fromUser.objectId] || _question.accepted);

    
    UITextView *answerTextView = [[UITextView alloc] initWithFrame:CGRectMake(44, answerTitleLabel.frame.origin.y+answerTitleLabel.frame.size.height, width-88, (shouldShowButton ? 66 : 110))];
    [answerTextView setText:_question.answer];
    [answerTextView setEditable:NO];
    [answerTextView setTextColor:[UIColor simbiDarkGrayColor]];
    [answerTextView setFont:[UIFont simbiLightFontWithSize:14.f]];
    [answerTextView.layer setBorderColor:[UIColor simbiGrayColor].CGColor];
    [answerTextView.layer setBorderWidth:2.f];
    [bottomView addSubview:answerTextView];
    
    if (shouldShowButton)
    {
        UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [acceptButton setFrame:CGRectMake(44, answerTextView.frame.origin.y+answerTextView.frame.size.height+16, (width-88)/2.f, 44)];
        [acceptButton setBackgroundColor:[UIColor simbiBlueColor]];
        [acceptButton setTitle:@"✓" forState:UIControlStateNormal];
        [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [acceptButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:36.f]];
        [acceptButton addTarget:self action:@selector(acceptAction:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:acceptButton];
        
        UIButton *declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [declineButton setFrame:CGRectMake(width/2.f, answerTextView.frame.origin.y+answerTextView.frame.size.height+16, (width-88)/2.f, 44)];
        [declineButton setBackgroundColor:[UIColor simbiRedColor]];
        [declineButton setTitle:@"✕" forState:UIControlStateNormal];
        [declineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [declineButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:36.f]];
        [declineButton addTarget:self action:@selector(declineAction:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:declineButton];
    }
    
    [self.view addSubview:bottomView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}


#pragma mark - User Actions

- (void)dismissAction:(UIBarButtonItem *)barButtonItem
{
    if (self.presentingViewController)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}


- (void)acceptAction:(UIButton *)button
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Accepting..." parent:self];
    
    [PFCloud callFunctionInBackground:@"acceptQuestion" withParameters:@{ @"questionId" : _question.objectId } block:^(NSString *response, NSError *error) {
        
        if (response)
        {
            [_question setAccepted:YES];
            
            [hud dismissQuickly];
            
            [_delegate questionViewController:self didAcceptWithChatMessage:response];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [hud dismissWithError];
        }
    }];
}


- (void)declineAction:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (_delegate)
            [_delegate questionViewControllerDidDecline:self];
    }];
}


@end
