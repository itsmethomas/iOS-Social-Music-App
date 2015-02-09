//
//  TSSignupViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/8/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSSignupViewController.h"
#import "ActivityIndicator.h"
#import "JSON.h"
#import "ServiceApiHelper.h"
#import "SessionManager.h"

@interface TSSignupViewController () {
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *confirmTextField;
    IBOutlet UITextField *fullnameTextField;
    
    IBOutlet UIScrollView *inputScrollView;
    
    IBOutlet FBLoginView *fbLoginView;
    BOOL isLoading;
}

@end

@implementation TSSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    fbLoginView.delegate = self;
    fbLoginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    isLoading = NO;
    
    // initializing ui elements...
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapedScreen)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events
- (void) onTapedScreen {
    [inputScrollView setContentOffset:CGPointMake(0, 0)];

    [usernameTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [confirmTextField resignFirstResponder];
    [fullnameTextField resignFirstResponder];
}

- (IBAction) onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onFBLogin:(id)sender {
    for(id object in fbLoginView.subviews){
        if([[object class] isSubclassOfClass:[UIButton class]]){
            UIButton* button = (UIButton*)object;
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (IBAction) onSignup:(UIButton*)sender {
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    NSString *confirm = confirmTextField.text;
    NSString *email = emailTextField.text;
    NSString *fullname = fullnameTextField.text;
    
    if ([username isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Please enter your user name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [usernameTextField becomeFirstResponder];
        return;
    } else if ([password isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Please enter your password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [passwordTextField becomeFirstResponder];
        return;
    } else if (![password isEqualToString:confirm]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Password does not match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [confirmTextField becomeFirstResponder];
        return;
    } else if ([email isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Please enter your email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [emailTextField becomeFirstResponder];
        return;
    } else if ([fullname isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Please enter your full name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [fullnameTextField becomeFirstResponder];
        return;
    }
    
    [[ActivityIndicator currentIndicator] show];
    [NSThread detachNewThreadSelector:@selector(signupRequest) toTarget:self withObject:nil];
}

- (void) signupRequest {
    NSString *result = [ServiceApiHelper signupWithEmail:usernameTextField.text forPassword:passwordTextField.text forEmail:emailTextField.text forName:fullnameTextField.text];
    NSDictionary *dic = [[SBJsonParser new] objectWithString:result];
    if ([dic[@"ResponseResult"] isEqualToString:@"YES"]) {
        [[SessionManager currentSession] initSessionWithDictionary:dic[@"ResponseContent"]];
        [self performSelector:@selector(signupSuccess) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    } else {
        [self performSelector:@selector(signupFailed:) onThread:[NSThread mainThread] withObject:dic[@"ResponseContent"] waitUntilDone:NO];
    }
}

- (void) signupSuccess {
    [[ActivityIndicator currentIndicator] hide];
    [self performSegueWithIdentifier:@"Login" sender:nil];
}

- (void) signupFailed:(NSString*)error {
    [[ActivityIndicator currentIndicator] hide];
    [[[UIAlertView alloc] initWithTitle:@"Warnning" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - FBLoginViewDelegate
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    if (isLoading)
        return;
    
    isLoading = YES;
    __block NSDictionary *temp = (NSDictionary *)user;
    
    [[ActivityIndicator currentIndicator] show];
    [NSThread detachNewThreadSelector:@selector(fbsignupRequest:) toTarget:self withObject:temp];
}

- (void) fbsignupRequest:(NSDictionary*)dic {
    NSString *result = [ServiceApiHelper signupWithFacebook:dic[@"email"] forFBId:dic[@"id"] forName:dic[@"name"]];
    isLoading = NO;
    dic = [[SBJsonParser new] objectWithString:result];
    if ([dic[@"ResponseResult"] isEqualToString:@"YES"]) {
        [[SessionManager currentSession] initSessionWithDictionary:dic[@"ResponseContent"]];
        [self performSelector:@selector(fbsignupSuccess) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    } else {
        [self performSelector:@selector(fbsignupFailed:) onThread:[NSThread mainThread] withObject:dic[@"ResponseContent"] waitUntilDone:NO];
    }
}

- (void) fbsignupSuccess {
    [[ActivityIndicator currentIndicator] hide];
    [self performSegueWithIdentifier:@"Login" sender:nil];
}

- (void) fbsignupFailed:(NSString*)error {
    [[ActivityIndicator currentIndicator] hide];
    [[[UIAlertView alloc] initWithTitle:@"Warnning" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == usernameTextField) {
        [textField resignFirstResponder];
        [emailTextField becomeFirstResponder];
        return false;
    } else if (textField == emailTextField) {
        [textField resignFirstResponder];
        [passwordTextField becomeFirstResponder];
        return false;
    } else if (textField == passwordTextField) {
        [textField resignFirstResponder];
        [confirmTextField becomeFirstResponder];
        return false;
    } else if (textField == confirmTextField) {
        [textField resignFirstResponder];
        [fullnameTextField becomeFirstResponder];
        return false;
    } else {
        [inputScrollView setContentOffset:CGPointMake(0, 0)];
        return [textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [inputScrollView setContentOffset:CGPointMake(0, textField.superview.frame.origin.y - 10) animated:YES];
    return YES;
}


@end