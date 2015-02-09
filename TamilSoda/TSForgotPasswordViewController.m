//
//  TSForgotPasswordViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/8/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSForgotPasswordViewController.h"
#import "ActivityIndicator.h"
#import "JSON.h"
#import "ServiceApiHelper.h"
#import "SessionManager.h"

@interface TSForgotPasswordViewController () {    
    IBOutlet FBLoginView *fbLoginView;
    BOOL isLoading;
    
    IBOutlet UITextField *userNameField;
    IBOutlet UITextField *humanTextField;
}

@end

@implementation TSForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    fbLoginView.delegate = self;
    fbLoginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    isLoading = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button Events
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

- (IBAction) onRequestHelp:(id)sender {
    if ([userNameField.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your user name or email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    } else if (![humanTextField.text isEqualToString:@"9"]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your answer of annti-spam question is not correct." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [[ActivityIndicator currentIndicator] show];
    [NSThread detachNewThreadSelector:@selector(sendRequestHelp) toTarget:self withObject:nil];
}

- (void) sendRequestHelp {
    [ServiceApiHelper forgotPassword:userNameField.text];
    [self performSelectorOnMainThread:@selector(didFinishedRequest) withObject:nil waitUntilDone:NO];
}

- (void) didFinishedRequest {
    [[ActivityIndicator currentIndicator] hide];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"We sent password reset link to your email. Please check your email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == userNameField) {
        [userNameField resignFirstResponder];
        [humanTextField becomeFirstResponder];
        return NO;
    } else {
        return [humanTextField resignFirstResponder];
    }
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

@end
