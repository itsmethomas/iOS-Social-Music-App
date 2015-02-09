//
//  TSTermsViewController.m
//  TamilSoda
//
//  Created by Yingcheng Li on 2/2/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSTermsViewController.h"
#import "ActivityIndicator.h"
#import "SessionManager.h"

@interface TSTermsViewController () {
    IBOutlet UIWebView *webView;
}

@end

@implementation TSTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[ActivityIndicator currentIndicator] show];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.tamilsoda.com/wp-admin/admin-ajax.php?action=termsofcondition"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events
- (IBAction) onCancel:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:@"Agree to TamilSoda's Terms and Condition and Privacy Policy" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Agree", nil] show];
}

- (IBAction) onAgree:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:[SessionManager currentSession].userEmail];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self onAgree:nil];
    }
}

#pragma mark - WebView
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[ActivityIndicator currentIndicator] hide];
}
@end
