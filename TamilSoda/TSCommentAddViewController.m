//
//  TSCommentAddViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/9/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSCommentAddViewController.h"
#import "TSCommentViewController.h"
#import "ServiceApiHelper.h"
#import "SessionManager.h"
#import "ActivityIndicator.h"

@interface TSCommentAddViewController () {
    IBOutlet UIButton *submitButton;
    IBOutlet UIButton *backButton;
    
    IBOutlet UITextView *commentTextView;
}

@end

@implementation TSCommentAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // initialize UI...
    submitButton.clipsToBounds = YES;
    submitButton.layer.cornerRadius = 15;
    submitButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    submitButton.layer.borderWidth = 1;
    
    UIImage *backImage = [[UIImage imageNamed:@"ico_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backButton setImage:backImage forState:UIControlStateNormal];
    backButton.tintColor = [UIColor darkGrayColor];
    
    commentTextView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    commentTextView.layer.borderWidth = 1;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapedScreen)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"CommentsView"]) {
        ((TSCommentViewController*)segue.destinationViewController).postId = _postId;
        ((TSCommentViewController*)segue.destinationViewController).postTitle = _postTitle;
    }
}

#pragma mark - Button Events
- (IBAction) onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onTapedScreen {
    [commentTextView resignFirstResponder];
}

- (IBAction) submit {
    NSString *content = commentTextView.text;
    if ([content isEqual:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Please input comment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    [[ActivityIndicator currentIndicator] show];
    [NSThread detachNewThreadSelector:@selector(requestSubmit:) toTarget:self withObject:content];
}

- (void) requestSubmit:(NSString*) content {
    NSString *param = [[NSString alloc] initWithFormat:@"postId=%@&userId=%@&author=%@&authorEmail=%@&comment=%@", _postId, [SessionManager currentSession].userId, [[SessionManager currentSession].userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [SessionManager currentSession].userEmail, [content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [ServiceApiHelper addComment:param];
    [self performSelector:@selector(didFinishedSubmit) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

- (void) didFinishedSubmit {
    [[ActivityIndicator currentIndicator] hide];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
