//
//  TSBlogDetailViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/9/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSBlogDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "BlogItem.h"
#import "TSCommentAddViewController.h"
#import "TTOpenInAppActivity.h"

@interface TSBlogDetailViewController () {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *authorLabel;
    IBOutlet UIImageView *featuredImageView;
    IBOutlet UIWebView *contentWebView;
    
    IBOutlet UIButton *commentButton;
    IBOutlet UIButton *shareButton;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *openSiteButton;
}

@end

@implementation TSBlogDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
}

- (void) initUI {
    commentButton.clipsToBounds = YES;
    commentButton.layer.cornerRadius = 15;
    commentButton.layer.borderWidth = 1;
    commentButton.layer.borderColor = [[UIColor whiteColor] CGColor];

    shareButton.clipsToBounds = YES;
    shareButton.layer.cornerRadius = 15;
    shareButton.layer.borderWidth = 1;
    shareButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    openSiteButton.clipsToBounds = YES;
    openSiteButton.layer.cornerRadius = 15;
    openSiteButton.layer.borderWidth = 1;
    openSiteButton.layer.borderColor = [[UIColor whiteColor] CGColor];

    UIImage *backImage = [[UIImage imageNamed:@"ico_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backButton setImage:backImage forState:UIControlStateNormal];
    backButton.tintColor = [UIColor darkGrayColor];
    [backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    titleLabel.text = _blogItem.title;
    authorLabel.text = _blogItem.author;
    [contentWebView loadHTMLString:_blogItem.content baseURL:nil];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_blogItem.featuredImageUrl]];
    [req addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [featuredImageView setImageWithURLRequest:req placeholderImage:nil
                                       success:nil failure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"CommentAdd"]) {
        ((TSCommentAddViewController*)segue.destinationViewController).postId = _blogItem.blogId;
        ((TSCommentAddViewController*)segue.destinationViewController).postTitle = _blogItem.title;
    }
}

#pragma mark - Button Events
- (IBAction) onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onShare:(id)sender {
    NSURL *urlObj = [[NSURL alloc] initWithString:_blogItem.shareUrl];
    
    TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:self.view andRect:((UIButton *)sender).frame];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[_blogItem.title, urlObj] applicationActivities:@[openInAppActivity]];
    
    openInAppActivity.superViewController = activityViewController;
    [self presentViewController:activityViewController animated:YES completion:NULL];
}

- (IBAction) onOpenSite:(id)sender {
    [contentWebView loadHTMLString:@"" baseURL:nil];
    NSURL *urlObj = [[NSURL alloc] initWithString:_blogItem.shareUrl];
    [contentWebView loadRequest:[NSURLRequest requestWithURL:urlObj]];
//    [[UIApplication sharedApplication] openURL:urlObj];
}

@end
