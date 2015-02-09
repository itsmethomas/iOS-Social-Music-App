//
//  TSLoginViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/8/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSLoginViewController.h"
#import "ActivityIndicator.h"
#import "ServiceApiHelper.h"
#import "JSON.h"
#import "SessionManager.h"

@interface TSLoginViewController () {
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    
    IBOutlet FBLoginView *fbLoginView;
    BOOL isLoading;
}

@end

@implementation TSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    fbLoginView.delegate = self;
    fbLoginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    isLoading = NO;
    
    // initializing ui elements...
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapedScreen)]];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER"];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"PWD"];
    if (username && pwd) {
        usernameTextField.text = username;
        passwordTextField.text = pwd;
        [self onLogin:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events
- (void) onTapedScreen {
    [usernameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

- (IBAction) onLogin:(UIButton*)sender {
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    
    if ([username isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Please enter your user name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [usernameTextField becomeFirstResponder];
        return;
    } else if ([password isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Please enter your password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [passwordTextField becomeFirstResponder];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"USER"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"PWD"];
    
    [[ActivityIndicator currentIndicator] show];
    [NSThread detachNewThreadSelector:@selector(loginRequest) toTarget:self withObject:nil];
}

- (IBAction) onFBLogin:(id)sender {
    for(id object in fbLoginView.subviews){
        if([[object class] isSubclassOfClass:[UIButton class]]){
            UIButton* button = (UIButton*)object;
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void) loginRequest {
    NSString *result = [ServiceApiHelper loginWithEmail:usernameTextField.text forPassword:passwordTextField.text];
    NSDictionary *dic = [[SBJsonParser new] objectWithString:result];
    if ([dic[@"ResponseResult"] isEqualToString:@"YES"]) {
        [[SessionManager currentSession] initSessionWithDictionary:dic[@"ResponseContent"]];
        [self performSelector:@selector(loginSuccess) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    } else {
        [self performSelector:@selector(loginFailed:) onThread:[NSThread mainThread] withObject:dic[@"ResponseContent"] waitUntilDone:NO];
    }
}

- (void) loginSuccess {
    [[ActivityIndicator currentIndicator] hide];
    [self performSegueWithIdentifier:@"Login" sender:nil];
}

- (void) loginFailed:(NSString*)error {
    [[ActivityIndicator currentIndicator] hide];
    [[[UIAlertView alloc] initWithTitle:@"Warnning" message:(error ? error : @"Can not connect to server. Please check your internet connection.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
        [passwordTextField becomeFirstResponder];
        return false;
    } else {
        return [textField resignFirstResponder];
    }
}

@end
