//
//  TSMainViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/9/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSMainViewController.h"
#import "TSCommonViewController.h"
#import "TSPlaylistViewController.h"
#import "TSBlogViewController.h"
#import "ServiceApiHelper.h"
#import "TSFeaturedDetailViewController.h"
#import "SessionManager.h"
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

@interface TSMainViewController () {
    IBOutlet UIButton *topButton;
    IBOutlet UIButton *latestButton;
    IBOutlet UIButton *blogButton;
    IBOutlet UIButton *playlistButton;
    IBOutlet UIButton *otherButton;
    IBOutlet UIButton *logoutButton;
    
    UIButton *lastSelectedButton;
    
    IBOutlet UIView *otherView;
    IBOutlet UIView *transparentView;
    IBOutlet UIView *containerView;
    
    IBOutlet UITextField *searchTextField;
    
    UIViewController *lastViewController;
    
    NSMutableArray *viewsArray;
}

@end

@implementation TSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    otherView.alpha = 0;
    otherView.hidden = YES;
    
    lastSelectedButton = topButton;
    [transparentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTappedScreen)]];
    
    self.screenName = @"Main Screen";
    [self initializeViews];
    [self agreeWithTermsAndCondition];
}

- (void) agreeWithTermsAndCondition {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:[SessionManager currentSession].userEmail]) {
        [self performSegueWithIdentifier:@"Terms" sender:nil];
    }
}

- (void) initializeViews {
    viewsArray = [[NSMutableArray alloc] init];
    
    NSArray *viewStoryboardIds = @[@"CommonView", @"CommonView", @"BlogView", @"PlaylistView"];
    for (int i=0; i<[viewStoryboardIds count]; i++) {
        UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:[viewStoryboardIds objectAtIndex:i]];
        
        if (i == 0) {
            ((TSCommonViewController *)v).categoryId = CATEGORY_TOP;
        } else if (i == 1) {
            ((TSCommonViewController *)v).categoryId = CATEGORY_LATEST;
        } else if (i == 2) {
            ((TSBlogViewController *)v).categoryId = CATEGORY_BLOG;
        }
        
        UINavigationController *navview = [[UINavigationController alloc] initWithRootViewController:v];
        navview.navigationBarHidden = YES;
        
        [self addChildViewController:navview];
        [viewsArray addObject:navview];
    }
    
    [self setViewIndex:0];
}

- (void) setViewIndex:(NSInteger) index {
    if (lastViewController != nil) {
        [lastViewController.view removeFromSuperview];
        [lastViewController removeFromParentViewController];
        lastViewController = nil;
    }
    
    for (UIView *view in containerView.subviews) {
        [view removeFromSuperview];
    }
    
    for (UINavigationController* vc in viewsArray) {
        if ([vc.visibleViewController isKindOfClass:[TSCommonViewController class]]) {
            [vc.visibleViewController removeFromParentViewController];
        } else if ([vc.visibleViewController isKindOfClass:[TSFeaturedDetailViewController class]]) {
            [vc.visibleViewController removeFromParentViewController];
        }
        [vc removeFromParentViewController];
    }

    UINavigationController *v = [viewsArray objectAtIndex:index];
    v.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    
    [containerView addSubview:v.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events
- (IBAction) onMenuClicked:(id)sender {
    UIButton *menuButton = (UIButton*)sender;
    
    topButton.selected = NO;
    latestButton.selected = NO;
    blogButton.selected = NO;
    playlistButton.selected = NO;
    otherButton.selected = NO;
    
    menuButton.selected = YES;
    
    if (menuButton == otherButton) {
        if (transparentView.hidden) {
            otherView.alpha = 0;
            otherView.hidden = NO;
            transparentView.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                otherView.alpha = 1;
            }];
        } else {
            transparentView.hidden = YES;
            [UIView animateWithDuration:0.5 animations:^{
                otherView.alpha = 0;
            } completion:^(BOOL finished) {
                otherView.hidden = YES;
            }];            
        }
    } else {
        [self setViewIndex:menuButton.tag];
        
        lastSelectedButton = menuButton;
        if (otherView.hidden == NO) {
            transparentView.hidden = YES;
            [UIView animateWithDuration:0.5 animations:^{
                otherView.alpha = 0;
            } completion:^(BOOL finished) {
                otherView.hidden = YES;
            }];
        }
    }
}

- (IBAction) onLogout:(id)sender {
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PWD"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) onTappedScreen {
    topButton.selected = NO;
    latestButton.selected = NO;
    blogButton.selected = NO;
    playlistButton.selected = NO;
    otherButton.selected = NO;
    
    lastSelectedButton.selected = YES;
    
    if (otherView.hidden == NO) {
        transparentView.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            otherView.alpha = 0;
        } completion:^(BOOL finished) {
            otherView.hidden = YES;
        }];
    }
}

- (IBAction) onFacebookShare:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/tamilsodapage"]];
}

- (IBAction) onInstagramShare:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://instagram.com/tamilsoda"]];
}

- (IBAction) onTwitterkShare:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/tamilsoda"]];
}

- (IBAction) onWebsiteShare:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.tamilsoda.com"]];
}

- (IBAction) rateThisApp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id960174190"]];
    
}

- (IBAction) onTermsAndCondition:(id)sender {
    [self performSegueWithIdentifier:@"Terms" sender:nil];
}

- (IBAction) onReport:(id)sender {
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setMailComposeDelegate:self];
    [mailController setToRecipients:@[@"info@tamilsoda.com"]];
    [mailController setSubject:@"Report from iOS App"];
    [mailController setMessageBody:@"" isHTML:NO];

    [self presentViewController:mailController animated:YES completion:nil];
}

- (IBAction) onCategorySelected:(UIButton*)sender {
    transparentView.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        otherView.alpha = 0;
    } completion:^(BOOL finished) {
        otherView.hidden = YES;
    }];
    
    if (sender.tag == 0 || sender.tag == 1 || sender.tag == 2) {
        if (lastViewController != nil) {
            [lastViewController.view removeFromSuperview];
            lastViewController = nil;
        }
        
        UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:@"CommonView"];
        if (sender.tag == 0)
            ((TSCommonViewController *)v).categoryId = CATEGORY_MUSIC;
        else if (sender.tag == 1)
            ((TSCommonViewController *)v).categoryId = CATEGORY_COVERSONGS;
        else
            ((TSCommonViewController *)v).categoryId = CATEGORY_TRAILERS;
        
        UINavigationController *navview = [[UINavigationController alloc] initWithRootViewController:v];
        navview.navigationBarHidden = YES;
        navview.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        
        [self addChildViewController:navview];
        [containerView addSubview:navview.view];
        
        lastViewController = navview;
    } else if (sender.tag == 3) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setMailComposeDelegate:self];
        [mailController setToRecipients:@[@"info@tamilsoda.com"]];
        [mailController setSubject:@"Video Submission from iOS App"];
        [mailController setMessageBody:@"Submit Video Song\n\
         Please enter the full\n\
         Your Name*:\n\
         Your Email*:\n\
         Video Link*:\n\
         Dropdown:\n\
         > Music video\n\
         > Cover song\n\
         > Movie Trailer\n" isHTML:NO];
        
        [self presentViewController:mailController animated:YES completion:nil];
    } else if (sender.tag == 4) {
        if (lastViewController != nil) {
            [lastViewController.view removeFromSuperview];
            lastViewController = nil;
        }
        
        UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:@"BlogView"];
        ((TSBlogViewController *)v).categoryId = CATEGORY_TAMIL_BLOG;
        
        UINavigationController *navview = [[UINavigationController alloc] initWithRootViewController:v];
        navview.navigationBarHidden = YES;
        navview.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        
        [self addChildViewController:navview];
        [containerView addSubview:navview.view];
        
        lastViewController = navview;
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self search];
    return [textField resignFirstResponder];
}

- (IBAction) search {
    [searchTextField resignFirstResponder];
    if ([searchTextField.text isEqualToString:@""]) {
        [self onTappedScreen];
        return;
    }
    
    transparentView.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        otherView.alpha = 0;
    } completion:^(BOOL finished) {
        otherView.hidden = YES;
    }];
    
    if (lastViewController != nil) {
        [lastViewController.view removeFromSuperview];
        lastViewController = nil;
    }
    
    UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:@"CommonView"];
    ((TSCommonViewController *)v).categoryId = CATEGORY_SEARCH;
    ((TSCommonViewController *)v).keyword = searchTextField.text;
    
    UINavigationController *navview = [[UINavigationController alloc] initWithRootViewController:v];
    navview.navigationBarHidden = YES;
    navview.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    
    [self addChildViewController:navview];
    [containerView addSubview:navview.view];
    
    lastViewController = navview;
}

@end
