//
//  TSPlaylistViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/8/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSCommonViewController.h"
#import "TSSongTableViewCell.h"
#import "JSON.h"
#import "UIImageView+AFNetworking.h"
#import "ActivityIndicator.h"
#import "MusicItem.h"
#import "ServiceApiHelper.h"
#import "XCDYouTubeVideoPlayerViewController.h"
#import "AppDelegate.h"
#import "SessionManager.h"
#import "TTOpenInAppActivity.h"

#import <AVFoundation/AVFoundation.h>

#define REFRESH_HEADER_HEIGHT 60.0f

@interface TSCommonViewController () {
    
    IBOutlet UIView *detailView;
    IBOutlet UITableView *listTableView;
    
    IBOutlet UIButton *fbShareButton;
    IBOutlet UIButton *twitterShareButton;
    IBOutlet UIButton *whatsappShareButton;
    IBOutlet UIButton *emailShareButton;
    IBOutlet UIButton *messageShareButton;
    IBOutlet UIButton *blankShareButton;
    
    IBOutlet UIImageView *placeholderImageView;
    NSString *placeholderOpenUrl;
    
    IBOutlet UIButton *moreButton;
    IBOutlet UIButton *lessButton;
    
    // meta data labels...
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *categoryLabel;    
    IBOutlet UILabel *artistsLabel;
    IBOutlet UILabel *lyricsLabel;
    IBOutlet UILabel *musicLabel;
    IBOutlet UILabel *videoEditingLabel;
    IBOutlet UILabel *albumLabel;
    IBOutlet UILabel *labelLabel;
    IBOutlet UILabel *releaseDateLabel;
    
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UIView *metaView;
    
    // for Reload by pulling...
    UIView *refreshHeaderView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isDragging;
    BOOL isLoading;
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
    UIActivityIndicatorView *bottomSpinner;
    
    IBOutlet UIView *videoPlayView;
    
    NSMutableArray *musicArray;
    MusicItem *curMusicItem;
    NSInteger currentMusicIndex;
    BOOL isPlaying;
    
    NSInteger curPageIndex;
}

@end

@implementation TSCommonViewController

static XCDYouTubeVideoPlayerViewController *videoPlayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    // init data...
    isPlaying = NO;
    musicArray = [[NSMutableArray alloc] init];
    [[ActivityIndicator currentIndicator] show];
    
    curPageIndex = 1;
    currentMusicIndex = -1;
    if (!_keyword) {
        _keyword = @"";
    }
    [NSThread detachNewThreadSelector:@selector(fetchAllMusicData) toTarget:self withObject:nil];
    
    NSError *setCategoryErr;
    NSError *activationErr;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryErr];
    [[AVAudioSession sharedInstance] setActive: YES error: &activationErr];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.screenName = _categoryId;
    
    // set PlaceHolder Image...
    NSDictionary *placeholder = [[SessionManager currentSession].placeholderData objectForKey:_categoryId];
    if (placeholder) {
        placeholderOpenUrl = [placeholder objectForKey:@"open_url"];
        [placeholderImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPlaceholderTapped)]];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:placeholder[@"img_url"]]];
        [req addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        [placeholderImageView setImageWithURLRequest:req placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                           success:nil failure:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNextVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)removeFromParentViewController {
    isPlaying = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    if (videoPlayer != nil) {
        videoPlayer.isKilled = YES;
        [videoPlayer.moviePlayer stop];
        [videoPlayer.moviePlayer.view removeFromSuperview];
    }
}

- (void) didChangeOrientation {
    if (!isPlaying || !self.view.superview || videoPlayer == nil)
        return;
    
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        [videoPlayer.moviePlayer setFullscreen:YES animated:YES];
    } else {
        [videoPlayer.moviePlayer setFullscreen:NO animated:YES];
    }
}

- (void) initUI {
    detailView.layer.zPosition = 1000;
    
    detailView.frame = CGRectMake(0, videoPlayView.frame.origin.y + videoPlayView.frame.size.height, detailView.frame.size.width, detailView.frame.size.height);
    listTableView.frame = CGRectMake(0, detailView.frame.origin.y + detailView.frame.size.height, listTableView.frame.size.width, self.view.frame.size.height - (detailView.frame.origin.y + detailView.frame.size.height));
    
    [self setupStrings];
    [self addPullToRefreshHeader];
    
}

- (void) loadNextPage {
    curPageIndex++;
    [[ActivityIndicator currentIndicator] show];
    
    isLoading = YES;
    [NSThread detachNewThreadSelector:@selector(fetchAllMusicData) toTarget:self withObject:nil];
}

- (void) refresh {
    [[ActivityIndicator currentIndicator] show];
    
    isLoading = YES;
    [NSThread detachNewThreadSelector:@selector(loadNewItemMusics) toTarget:self withObject:nil];
}

- (void) loadNewItemMusics {
    NSString *jsonStr = [ServiceApiHelper fetchPostsByCategory:_categoryId forPageIndex:0 forKeyword:_keyword];
    NSArray *array = [[SBJsonParser new] objectWithString:jsonStr];
    for (NSDictionary *item in array) {
        MusicItem *mItem = [[MusicItem alloc] initWithDictionary:item];
        
        if ([self isExist:mItem])
            continue;
        
        [musicArray insertObject:mItem atIndex:0];
    }
    
    [listTableView reloadData];
    [[ActivityIndicator currentIndicator] hide];
    
    [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
    [self refreshBottomSpinnerPosition];
    
    isLoading = NO;
}

- (void) fetchAllMusicData {
    NSString *jsonStr = [ServiceApiHelper fetchPostsByCategory:_categoryId forPageIndex:curPageIndex forKeyword:_keyword];
    NSArray *array = [[SBJsonParser new] objectWithString:jsonStr];
    for (NSDictionary *item in array) {
        MusicItem *mItem = [[MusicItem alloc] initWithDictionary:item];
        
        if ([self isExist:mItem])
            continue;
        
        [musicArray addObject:mItem];
    }
    
    if ([array count] == 0 && curPageIndex > 0)
        curPageIndex--;
    
    [listTableView reloadData];
    [[ActivityIndicator currentIndicator] hide];
    
    [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
    [self refreshBottomSpinnerPosition];
    
    isLoading = NO;
}

- (BOOL) isExist:(MusicItem*) mItem {
    for(MusicItem *item in musicArray) {
        if ([item.musicId isEqualToString:mItem.musicId])
            return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Events
- (void) onPlaceholderTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:placeholderOpenUrl]];
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
    [self.parentViewController.parentViewController performSegueWithIdentifier:@"Terms" sender:nil];
}

- (IBAction) onReport:(id)sender {
    if (curMusicItem == nil)
        return;
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setMailComposeDelegate:self];
    [mailController setToRecipients:@[@"info@tamilsoda.com"]];
    [mailController setSubject:[NSString stringWithFormat:@"iOS: Report: %@", curMusicItem.title]];
    [mailController setMessageBody:[NSString stringWithFormat:@"I would like to report\n\
                                    Song name: %@\n\
                                    Song url: %@\n\
                                    Reason:", curMusicItem.title, curMusicItem.shareUrl] isHTML:NO];
    
    [self presentViewController:mailController animated:YES completion:nil];
}

- (IBAction) onMoreClicked:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        detailView.frame = CGRectMake(0, detailView.frame.origin.y, detailView.frame.size.width, 318);
        listTableView.frame = CGRectMake(0, detailView.frame.origin.y + 318, detailView.frame.size.width, self.view.frame.size.height - detailView.frame.origin.y - 318);
        moreButton.hidden = YES;
    }];
}

- (IBAction) onLessClicked:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        detailView.frame = CGRectMake(0, detailView.frame.origin.y, detailView.frame.size.width, 63);
        listTableView.frame = CGRectMake(0, detailView.frame.origin.y + 63, detailView.frame.size.width, self.view.frame.size.height - detailView.frame.origin.y - 63);
    } completion:^(BOOL finished) {
        moreButton.hidden = NO;
    }];
}

- (IBAction) onShare:(UIButton*)sender {
    if (curMusicItem == nil)
        return;
    [self shareContent:curMusicItem.title forContentUrl:curMusicItem.shareUrl forImage:curMusicItem.thumbnailImage shareType:sender.tag forViewController:self];
}

- (IBAction) onNativeShare:(id)sender {
    if (curMusicItem == nil)
        return;
    NSURL *urlObj = [[NSURL alloc] initWithString:curMusicItem.shareUrl];
    
    TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:self.view andRect:((UIButton *)sender).frame];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[curMusicItem.title, urlObj] applicationActivities:@[openInAppActivity]];
    
    openInAppActivity.superViewController = activityViewController;
    [self presentViewController:activityViewController animated:YES completion:NULL];
}


- (IBAction) onOpenMobile:(id)sender {
    if (curMusicItem == nil)
        return;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:curMusicItem.shareUrl]];
}

- (void) shareContent:(NSString*)title forContentUrl:(NSString*)shareUrl forImage:(UIImage*)image shareType:(NSInteger) shareType forViewController:(UIViewController*) v{
    if (shareType == SOCIAL_SHARE_MAIL) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        [mailController setMailComposeDelegate:self];
        [mailController setSubject:title];
        [mailController setMessageBody:shareUrl isHTML:NO];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
        if(imageData.length)
        {
            [mailController addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"Your_Photo.jpg"];
            [v presentViewController:mailController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Image" message:@"The image couldn't be converted." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alert show];
        }
    } else if (shareType == SOCIAL_SHARE_MESSAGE) {
        MFMessageComposeViewController *msgController = [[MFMessageComposeViewController alloc] init];
        [msgController setMessageComposeDelegate:self];
        [msgController setBody:shareUrl];
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
        if(imageData.length)
        {
            [msgController addAttachmentData:imageData typeIdentifier:@"image/jpeg" filename:@"Your_Photo.jpg"];
            [v presentViewController:msgController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Image" message:@"The image couldn't be converted." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alert show];
        }
    } else if (shareType == SOCIAL_SHARE_WHATSAPP) {
        NSString * msg = curMusicItem.shareUrl;
        NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
        NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
        } else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no WhatsApp installed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } else if (shareType == SOCIAL_SHARE_FACEBOOK) {
        SLComposeViewController *slView = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [slView setInitialText:curMusicItem.title];
        [slView addImage:curMusicItem.thumbnailImage];
        [slView addURL:[NSURL URLWithString:curMusicItem.shareUrl]];
        [self presentViewController:slView animated:YES completion:nil];
    }  else if (shareType == SOCIAL_SHARE_TWITTER) {
        SLComposeViewController *slView = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [slView setInitialText:curMusicItem.title];
        [slView addImage:curMusicItem.thumbnailImage];
        [slView addURL:[NSURL URLWithString:curMusicItem.shareUrl]];
        [self presentViewController:slView animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate & DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSSongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    MusicItem *item = [musicArray objectAtIndex:indexPath.row];
    
    cell.songTitleLabel.text = item.title;
    cell.songCategoryLabel.text = item.category;
    cell.songArtistLabel.text = item.artists;
    
    cell.songTitleLabel.frame = CGRectMake(cell.songTitleLabel.frame.origin.x, cell.songTitleLabel.frame.origin.y, listTableView.frame.size.width -  cell.songTitleLabel.frame.origin.x - 40, cell.songTitleLabel.frame.size.height);
    cell.songCategoryLabel.frame = CGRectMake(cell.songCategoryLabel.frame.origin.x, cell.songCategoryLabel.frame.origin.y, cell.songTitleLabel.frame.size.width, cell.songTitleLabel.frame.size.height);
    cell.songArtistLabel.frame = CGRectMake(cell.songArtistLabel.frame.origin.x, cell.songArtistLabel.frame.origin.y, cell.songTitleLabel.frame.size.width, cell.songTitleLabel.frame.size.height);
    
    cell.pinkArrowView.frame = CGRectMake(listTableView.frame.size.width - 30, cell.pinkArrowView.frame.origin.y, cell.pinkArrowView.frame.size.width, cell.pinkArrowView.frame.size.height);
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:item.thumbnailUrl]];
    [req addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [cell.songImageView setImageWithURLRequest:req placeholderImage:[UIImage imageNamed:@"app-watermark.png"]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              item.thumbnailImage = image;
                                          } failure:nil];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [musicArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    currentMusicIndex = indexPath.row - 1;
    [self playNextVideo];
}

- (void) playNextVideo {
    currentMusicIndex++;
    if (currentMusicIndex < [musicArray count]) {
        curMusicItem = [musicArray objectAtIndex:currentMusicIndex];
//        if (videoPlayer != nil) {
//            [videoPlayer.moviePlayer stop];
//            [videoPlayer.moviePlayer.view removeFromSuperview];
//            videoPlayer = nil;
//        }
        
        if (curMusicItem.videoId == nil || [curMusicItem.videoId isEqualToString:@""]) {
            [self playNextVideo];
            return;
        }
        
        if (videoPlayer == nil) {
            videoPlayer = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:curMusicItem.videoId];
            videoPlayer.view.frame = CGRectMake(0, 0, videoPlayView.frame.size.width, videoPlayView.frame.size.height);
            [videoPlayer presentInView:videoPlayView];
        } else {
            [videoPlayer.moviePlayer stop];
            [videoPlayer.moviePlayer.view removeFromSuperview];
            [videoPlayer presentInView:videoPlayView];
        }
        videoPlayer.isKilled = NO;
        [videoPlayer setVideoIdentifier:curMusicItem.videoId];
        isPlaying = YES;
        
        ((AppDelegate*)[UIApplication sharedApplication].delegate).sharedMediaPlayer = videoPlayer.moviePlayer;
        
        [self setVideoMetadata:curMusicItem];
    }
}

- (void) stopPlaying {
    if (videoPlayer != nil) {
        [videoPlayer.moviePlayer stop];
        [videoPlayer.moviePlayer.view removeFromSuperview];
    }
}

- (void) setVideoMetadata:(MusicItem*) item {
    metaView.hidden = NO;
    descriptionLabel.hidden = YES;
    
    titleLabel.text = item.title;
    categoryLabel.text = item.category;
    artistsLabel.text = item.artists;
    lyricsLabel.text = item.lyrics;
    musicLabel.text = item.music;
    videoEditingLabel.text = item.videoEditing;
    albumLabel.text = item.album;
    labelLabel.text = item.label;
    releaseDateLabel.text = item.releaseDate;
}

#pragma mark Pulling Table...
- (void)setupStrings{
    textPull = @"Pull down to update new music...";
    textRelease = @"Release to update new muic...";
    textLoading = @"Loading...";
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 20) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 26) / 2),
                                    20, 26);
    
    bottomSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    bottomSpinner.frame = CGRectMake(-1000, -1000, 20, 20);
    bottomSpinner.hidesWhenStopped = NO;
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [listTableView addSubview:refreshHeaderView];
    [listTableView addSubview:bottomSpinner];
}

- (void) refreshBottomSpinnerPosition {
    refreshHeaderView.frame = CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT);
    
    if ([musicArray count] == 0) {
        bottomSpinner.frame = CGRectMake(-1000, -1000, 20, 20);
    } else {
        bottomSpinner.frame = CGRectMake([listTableView contentSize].width / 2 - 10, [listTableView contentSize].height + 20, 20, 20);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            listTableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            listTableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = textRelease;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = textPull;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    } else if (isDragging && scrollView.contentOffset.y + scrollView.frame.size.height> scrollView.contentSize.height) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height> scrollView.contentSize.height + REFRESH_HEADER_HEIGHT) {
            [bottomSpinner startAnimating];
        } else {
            [bottomSpinner stopAnimating];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        [self startLoading];
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height > listTableView.contentSize.height + REFRESH_HEADER_HEIGHT / 2){
        [self startNextLoading];
    }
}

- (void)startNextLoading {
    isLoading = YES;
    [self loadNextPage];
}

- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        listTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = textLoading;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        listTableView.contentInset = UIEdgeInsetsZero;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [self performSelectorInBackground:@selector(stopLoadingComplete) withObject:nil];
                     }];
}

- (void)stopLoadingComplete {
    // Reset the header
    refreshLabel.text = textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

@end
