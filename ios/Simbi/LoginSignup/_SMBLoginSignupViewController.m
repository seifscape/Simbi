//
//  SMBLoginSignupViewController.m
//  Simbi
//
//  Created by flynn on 5/13/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "_SMBLoginSignupViewController.h"

#import "MBProgressHUD.h"

#import "SMBAppDelegate.h"
#import "_SMBSignupInfoViewController.h"
#import "SMBFriendsManager.h"
#import "SMBFriendRequestsManager.h"
#import "SMBChatManager.h"


@interface _SMBLoginSignupViewController ()

@property (nonatomic, strong) UIView *logInView;
@property (nonatomic, strong) UIView *signUpView;
@property (nonatomic, strong) UIImageView *simbiLogo;

@property (nonatomic, strong) UIView *logInTextViewBackground;
@property (nonatomic) CGRect logInBackgroundFrame;
@property (nonatomic, strong) UIView *signUpTextViewBackground;
@property (nonatomic) CGRect signUpBackgroundFrame;

@property (nonatomic, strong) UITextField *logInEmailTextField;
@property (nonatomic, strong) UITextField *logInPasswordTextField;

@property (nonatomic, strong) UITextField *signUpNameTextField;
@property (nonatomic, strong) UITextField *signUpEmailTextField;
@property (nonatomic, strong) UITextField *signUpPasswordTextField;

@property (nonatomic, strong) UIButton *logInButton;
@property (nonatomic) CGRect logInButtonFrame;
@property (nonatomic, strong) UIButton *facebookSignInButton;
@property (nonatomic) CGRect facebookButtonFrame;
@property (nonatomic, strong) UIButton *signUpButton;
@property (nonatomic) CGRect signUpButtonFrame;

@end


@implementation _SMBLoginSignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor simbiBlueColor]];
    
    
    // Set up views
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat comp = ([UIScreen mainScreen].bounds.size.height > 480.f ? 40 : -12); // compensation for 3.5 vs 4-inch screens
    
    
    _simbiLogo = [[UIImageView alloc] initWithFrame:CGRectMake(66, comp, width-66*2, width-66*2)];
    [_simbiLogo setImage:[UIImage imageNamed:@"simbilogo"]];
    [_simbiLogo setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_simbiLogo];
    
    _logInView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:_logInView];
    
    _signUpView = [[UIView alloc] initWithFrame:CGRectMake(width, 0, width, height)];
    [self.view addSubview:_signUpView];
    
    UIButton *tapOutLogInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tapOutLogInButton setFrame:CGRectMake(0, 0, width, height)];
    [tapOutLogInButton addTarget:self.view action:@selector(endEditing:) forControlEvents:UIControlEventTouchUpInside];
    [_logInView addSubview:tapOutLogInButton];
    
    UIButton *tapOutSignUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tapOutSignUpButton setFrame:CGRectMake(0, 0, width, height)];
    [tapOutSignUpButton addTarget:self.view action:@selector(endEditing:) forControlEvents:UIControlEventTouchUpInside];
    [_signUpView addSubview:tapOutSignUpButton];
    
    
    // LogIn view:
    
    
    // Background for the textViews
    
    _logInBackgroundFrame = CGRectMake(44, 176+comp*2, width-88, 88);
    
    _logInTextViewBackground = [[UIView alloc] initWithFrame:_logInBackgroundFrame];
    [_logInTextViewBackground setBackgroundColor:[UIColor whiteColor]];
    [_logInTextViewBackground.layer setCornerRadius:8.f];
    [_logInTextViewBackground.layer setBorderWidth:1.f];
    [_logInTextViewBackground.layer setBorderColor:[UIColor simbiGrayColor].CGColor];
    [_logInView addSubview:_logInTextViewBackground];
    
    UIView *middleLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5f, _logInTextViewBackground.frame.size.width, 1)];
    [middleLineView setBackgroundColor:[UIColor simbiGrayColor]];
    [_logInTextViewBackground addSubview:middleLineView];
    
    // Place the textViews in the container
    
    _logInEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 0, _logInTextViewBackground.frame.size.width-24, 44)];
    [_logInEmailTextField setPlaceholder:@"Email"];
    [_logInEmailTextField setDelegate:self];
    [_logInEmailTextField setFont:[UIFont simbiBoldFontWithSize:16.f]];
    [_logInEmailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [_logInTextViewBackground addSubview:_logInEmailTextField];
    
    _logInPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 44, _logInTextViewBackground.frame.size.width-24, 44)];
    [_logInPasswordTextField setPlaceholder:@"Password"];
    [_logInPasswordTextField setDelegate:self];
    [_logInPasswordTextField setFont:[UIFont simbiBoldFontWithSize:16.f]];
    [_logInPasswordTextField setSecureTextEntry:YES];
    [_logInPasswordTextField setReturnKeyType:UIReturnKeyGo];
    [_logInTextViewBackground addSubview:_logInPasswordTextField];
    
    // Log in buttons
    
    _logInButtonFrame = CGRectMake(44, height-52*3-22, width-88, 44);
    
    _logInButton = [UIButton simbiRedButtonWithFrame:_logInButtonFrame];
    [_logInButton setTitle:@"Log In" forState:UIControlStateNormal];
    [_logInButton addTarget:self action:@selector(logInWithEmailAction) forControlEvents:UIControlEventTouchUpInside];
    [_logInView addSubview:_logInButton];
    
    _facebookButtonFrame = CGRectMake(44, height-52*2-22, width-88, 44);
    
    _facebookSignInButton = [UIButton simbiFacebookButtonWithFrame:_facebookButtonFrame title:@"Sign In with Facebook"];
    [_facebookSignInButton setBackgroundColor:[UIColor simbiRedColor]];
    [_facebookSignInButton addTarget:self action:@selector(signInWithFacebookAction) forControlEvents:UIControlEventTouchUpInside];
    [_logInView addSubview:_facebookSignInButton];
    
    
    UIButton *showSignUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showSignUpButton setFrame:CGRectMake(width/2.f+44, height-52-22, (width-176)/2.f, 44)];
    [showSignUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showSignUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [showSignUpButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:18.f]];
    [showSignUpButton addTarget:self action:@selector(showSignUpAction) forControlEvents:UIControlEventTouchUpInside];
    [_logInView addSubview:showSignUpButton];
    
    
    // SignUp view:
    
    
    // Background for the textViews
    
    _signUpBackgroundFrame = CGRectMake(44, 176+comp*2-22, width-88, 132);
    
    _signUpTextViewBackground = [[UIView alloc] initWithFrame:_signUpBackgroundFrame];
    [_signUpTextViewBackground setBackgroundColor:[UIColor whiteColor]];
    [_signUpTextViewBackground.layer setCornerRadius:8.f];
    [_signUpTextViewBackground.layer setBorderWidth:1.f];
    [_signUpTextViewBackground.layer setBorderColor:[UIColor simbiGrayColor].CGColor];
    [_signUpView addSubview:_signUpTextViewBackground];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5f, _signUpTextViewBackground.frame.size.width, 1)];
    [topLineView setBackgroundColor:[UIColor simbiGrayColor]];
    [_signUpTextViewBackground addSubview:topLineView];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44+43.5f, _signUpTextViewBackground.frame.size.width, 1)];
    [bottomLineView setBackgroundColor:[UIColor simbiGrayColor]];
    [_signUpTextViewBackground addSubview:bottomLineView];
    
    // Place the textViews in the container
    
    _signUpNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 0, _signUpTextViewBackground.frame.size.width-24, 44)];
    [_signUpNameTextField setPlaceholder:@"Your First Name"];
    [_signUpNameTextField setDelegate:self];
    [_signUpNameTextField setFont:[UIFont simbiBoldFontWithSize:16.f]];
    [_signUpNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [_signUpTextViewBackground addSubview:_signUpNameTextField];
    
    _signUpEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 44, _signUpTextViewBackground.frame.size.width-24, 44)];
    [_signUpEmailTextField setPlaceholder:@"Email"];
    [_signUpEmailTextField setDelegate:self];
    [_signUpEmailTextField setFont:[UIFont simbiBoldFontWithSize:16.f]];
    [_signUpEmailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [_signUpTextViewBackground addSubview:_signUpEmailTextField];
    
    _signUpPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 88, _signUpTextViewBackground.frame.size.width-24, 44)];
    [_signUpPasswordTextField setPlaceholder:@"Password"];
    [_signUpPasswordTextField setDelegate:self];
    [_signUpPasswordTextField setFont:[UIFont simbiBoldFontWithSize:16.f]];
    [_signUpPasswordTextField setSecureTextEntry:YES];
    [_signUpPasswordTextField setReturnKeyType:UIReturnKeyGo];
    [_signUpTextViewBackground addSubview:_signUpPasswordTextField];
    
    // Sign up buttons
    
    _signUpButtonFrame = CGRectMake(44, _logInButton.frame.origin.y+22+4, width-88, 44);
    
    _signUpButton = [UIButton simbiRedButtonWithFrame:_signUpButtonFrame];
    [_signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [_signUpButton addTarget:self action:@selector(signUpWithEmailAction) forControlEvents:UIControlEventTouchUpInside];
    [_signUpView addSubview:_signUpButton];
    
    UIButton *showLogInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showLogInButton setFrame:CGRectMake(44, showSignUpButton.frame.origin.y, (width-176)/2.f-16, 44)];
    [showLogInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showLogInButton setTitle:@"Log In" forState:UIControlStateNormal];
    [showLogInButton.titleLabel setFont:[UIFont simbiBoldFontWithSize:16.f]];
    [showLogInButton addTarget:self action:@selector(showLogInAction) forControlEvents:UIControlEventTouchUpInside];
    [_signUpView addSubview:showLogInButton];
    
    
    // Keyboard Notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
}


#pragma mark - User Actions

- (void)showSignUpAction
{
    [UIView animateWithDuration:0.33f animations:^{
        [_logInView setFrame:CGRectMake(-self.view.frame.size.width, 0, _logInView.frame.size.width, _logInView.frame.size.height)];
        [_signUpView setFrame:CGRectMake(0, 0, _signUpView.frame.size.width, _signUpView.frame.size.height)];
    }];
}


- (void)showLogInAction
{
    [UIView animateWithDuration:0.33f animations:^{
        [_logInView setFrame:CGRectMake(0, 0, _logInView.frame.size.width, _logInView.frame.size.height)];
        [_signUpView setFrame:CGRectMake(self.view.frame.size.width, 0, _signUpView.frame.size.width, _signUpView.frame.size.height)];
    }];
}


- (void)logInWithEmailAction
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Logging In..." parent:self];
    
    [SMBUser logInWithUsernameInBackground:_logInEmailTextField.text.lowercaseString password:_logInPasswordTextField.text block:^(PFUser *user, NSError *error) {
        
        [hud dismissQuickly];
        
        if (user)
        {
            [[SMBAppDelegate instance] syncUserInstallation];
            
            [[SMBFriendsManager sharedManager] loadObjects:nil];
            [[SMBFriendRequestsManager sharedManager] loadObjects:nil];
            [[SMBChatManager sharedManager] loadObjects:nil];
            
            [[SMBAppDelegate instance] animateToMain];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            
            if (error.code == kPFErrorObjectNotFound)
                [hud dismissWithMessage:@"Couldn't Log In!"];
            else
                [hud dismissWithError];
        }
    }];
}


- (void)signInWithFacebookAction
{
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Signing In..." parent:self];
    
    NSArray *permissions = @[@"email", @"public_profile", @"user_friends"];
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        
        if (user)
        {
            [[SMBAppDelegate instance] syncUserInstallation];
            
            [[SMBFriendsManager sharedManager] loadObjects:nil];
            [[SMBFriendRequestsManager sharedManager] loadObjects:nil];
            [[SMBChatManager sharedManager] loadObjects:nil];
            
            if (user.isNew)
            {
                // Get the user's Facebook information
                
                [[SMBUser currentUser] syncWithFacebook:^(BOOL succeeded) {
                    
                    if (succeeded)
                    {
                        [hud dismissQuickly];
                        _SMBSignupInfoViewController *viewController = [[_SMBSignupInfoViewController alloc] init];
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                    else
                    {
                        [hud dismissWithMessage:@"D'oh!"];
                    }
                }];
            }
            else
            {
                [hud dismissQuickly];

                [[SMBAppDelegate instance] animateToMain];
            }
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [hud dismissWithMessage:@"D'oh!"];
        }
    }];
}


- (void)signUpWithEmailAction
{
    // Validate name
    
    if (_signUpNameTextField.text.length < 2)
    {
        [MBProgressHUD showMessage:@"Please enter your name" parent:self];
        return;
    }
    
    // Validate email
    
    if (_signUpEmailTextField.text.length == 0)
    {
        [MBProgressHUD showMessage:@"Please enter your email" parent:self];
        return;
    }

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
    if (![emailTest evaluateWithObject:_signUpEmailTextField.text])
    {
        [MBProgressHUD showMessage:@"Please enter a valid email" parent:self];
        return;
    }
    
    // Validate password
    
    if (_signUpPasswordTextField.text.length < 6)
    {
        [MBProgressHUD showMessage:@"Passwords needs to be longer" parent:self];
        return;
    }
    
    // User's all good - sign up and push to next view
    
    SMBUser *newUser = [[SMBUser alloc] init];
    [newUser setFirstName:_signUpNameTextField.text];
    [newUser setUsername:_signUpEmailTextField.text.lowercaseString];
    [newUser setEmail:_signUpEmailTextField.text.lowercaseString];
    [newUser setPassword:_signUpPasswordTextField.text];
    
    MBProgressHUD *hud = [MBProgressHUD HUDwithMessage:@"Signing Up..." parent:self];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            [[SMBFriendsManager sharedManager] loadObjects:nil];
            [[SMBFriendRequestsManager sharedManager] loadObjects:nil];
            [[SMBChatManager sharedManager] loadObjects:nil];
            
            [hud dismissQuickly];
            _SMBSignupInfoViewController *signupInfoViewController = [[_SMBSignupInfoViewController alloc] init];
            [self.navigationController pushViewController:signupInfoViewController animated:YES];
        }
        else
        {
            NSLog(@"%s - ERROR: %@", __PRETTY_FUNCTION__, error);
            [hud dismissWithError];
        }
    }];
}


#pragma mark - UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField == _logInPasswordTextField)
        [self logInWithEmailAction];
    else if (textField == _signUpPasswordTextField)
        [self signUpWithEmailAction];
    
    return YES;
}


#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGFloat height = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_simbiLogo setAlpha:0.f];
                         
                         [_logInTextViewBackground setFrame:CGRectMake(_logInBackgroundFrame.origin.x,
                                                                       (height-keyboardHeight-_logInBackgroundFrame.size.height-44-20)/2.f,
                                                                       _logInBackgroundFrame.size.width,
                                                                       _logInBackgroundFrame.size.height)];
                         
                         [_signUpTextViewBackground setFrame:CGRectMake(_signUpBackgroundFrame.origin.x,
                                                                        (height-keyboardHeight-_signUpBackgroundFrame.size.height-44-20)/2.f,
                                                                        _signUpBackgroundFrame.size.width,
                                                                        _signUpBackgroundFrame.size.height)];
                         
                         [_logInButton setFrame:CGRectMake(_logInButtonFrame.origin.x,
                                                           _logInTextViewBackground.frame.origin.y+_logInTextViewBackground.frame.size.height+20,
                                                           _logInButtonFrame.size.width,
                                                           _logInButtonFrame.size.height)];
                         
                         [_facebookSignInButton setFrame:CGRectMake(_facebookButtonFrame.origin.x,
                                                                    _logInButton.frame.origin.y+_logInButton.frame.size.height+8,
                                                                    _facebookButtonFrame.size.width,
                                                                    _facebookButtonFrame.size.height)];
                         
                         [_signUpButton setFrame:CGRectMake(_signUpButtonFrame.origin.x,
                                                            _signUpTextViewBackground.frame.origin.y+_signUpTextViewBackground.frame.size.height+20,
                                                            _signUpButtonFrame.size.width,
                                                            _signUpButtonFrame.size.height)];
                     }
                     completion:nil];
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view endEditing:YES];
                         [_simbiLogo setAlpha:1.f];
                         [_logInTextViewBackground setFrame:_logInBackgroundFrame];
                         [_signUpTextViewBackground setFrame:_signUpBackgroundFrame];
                         [_logInButton setFrame:_logInButtonFrame];
                         [_facebookSignInButton setFrame:_facebookButtonFrame];
                         [_signUpButton setFrame:_signUpButtonFrame];
                     } completion:^(BOOL finished) {
                         if (finished)
                             [self.view endEditing:YES];
                     }];
}


@end
