//
//  TSFeaturedDetailViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/14/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSFeaturedDetailViewController.h"
#import "MusicItem.h"
#import "UIImageView+AFNetworking.h"
#import "XCDYouTubeVideoPlayerViewController.h"
#import "TSCommentAddViewController.h"
#import "TTOpenInAppActivity.h"
#import "ActivityIndicator.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface TSFeaturedDetailViewController () {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *authorLabel;
    IBOutlet UIImageView *featuredImageView;
    IBOutlet UIView *videoPlayView;
    
    IBOutlet UIButton *commentButton;
    IBOutlet UIButton *shareButton;
    IBOutlet UIButton *backButton;
    
    NSMutableArray *videosArray;
    BOOL isStartedEntry;
    NSInteger currentVideoIndex;
    
    XCDYouTubeVideoPlayerViewController* videoPlayer;
    BOOL isPlaying;
}

@end

@implementation TSFeaturedDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    videosArray = [[NSMutableArray alloc] init];
    [self initUI];
    isPlaying = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    NSError *setCategoryErr;
    NSError *activationErr;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryErr];
    [[AVAudioSession sharedInstance] setActive: YES error: &activationErr];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)removeFromParentViewController {
    isPlaying = NO;
    
    if (videoPlayer != nil) {
        [videoPlayer.moviePlayer.view removeFromSuperview];
        videoPlayer = nil;
    }
    ((AppDelegate*)[UIApplication sharedApplication].delegate).sharedMediaPlayer = nil;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) didChangeOrientation {
    if (!isPlaying)
        return;
    
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        [videoPlayer.moviePlayer setFullscreen:YES animated:YES];
    } else {
        [videoPlayer.moviePlayer setFullscreen:NO animated:YES];
    }
}

- (void) initUI {
    UIImage *backImage = [[UIImage imageNamed:@"ico_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backButton setImage:backImage forState:UIControlStateNormal];
    backButton.tintColor = [UIColor darkGrayColor];

    commentButton.clipsToBounds = YES;
    commentButton.layer.cornerRadius = 15;
    commentButton.layer.borderWidth = 1;
    commentButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    shareButton.clipsToBounds = YES;
    shareButton.layer.cornerRadius = 15;
    shareButton.layer.borderWidth = 1;
    shareButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    titleLabel.text = _musicItem.title;
    authorLabel.text = _musicItem.author;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_musicItem.featuredImageUrl]];
    [req addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [featuredImageView setImageWithURLRequest:req placeholderImage:nil
                                      success:nil failure:nil];
    [[ActivityIndicator currentIndicator] show];
    [NSThread detachNewThreadSelector:@selector(downloadVideosFromPlaylist) toTarget:self withObject:nil];
}

- (void) downloadVideosFromPlaylist {
    NSString *playlistFeedUrl = [NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/playlists/%@", _musicItem.playListId];
    NSURL *url = [NSURL URLWithString:playlistFeedUrl];
    NSXMLParser *parser = [[NSXMLParser alloc]initWithContentsOfURL:url];
    [parser setDelegate:self];
    
    isStartedEntry = NO;
    [parser parse];
    [self performSelector:@selector(didFinishedFetchVideos) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"entry"])
    {
        isStartedEntry = YES;
    } else if ([elementName isEqualToString:@"link"]) {
        if (isStartedEntry && [attributeDict[@"rel"] isEqualToString:@"alternate"]) {
            NSString *videoUrl = [attributeDict objectForKey:@"href"];
            videoUrl = [videoUrl stringByReplacingOccurrencesOfString:@"&feature=youtube_gdata" withString:@""];
            NSArray *arr = [videoUrl componentsSeparatedByString:@"?v="];
            if ([arr count] > 1)
                [videosArray addObject:arr[1]];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"entry"]) {
        isStartedEntry = NO;
    }
}

- (void) didFinishedFetchVideos {
    [[ActivityIndicator currentIndicator] hide];
    
    if ([videosArray count] > 0) {
        currentVideoIndex = 0;
        videoPlayer = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:[videosArray objectAtIndex:0]];
        videoPlayer.view.frame = CGRectMake(0, 0, videoPlayView.frame.size.width, videoPlayView.frame.size.height);
        [videoPlayer presentInView:videoPlayView];
        [videoPlayer setVideoIdentifier:[videosArray objectAtIndex:0]];

        ((AppDelegate*)[UIApplication sharedApplication].delegate).sharedMediaPlayer = videoPlayer.moviePlayer;
        isPlaying = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNextVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
}

- (void) playNextVideo {
    currentVideoIndex++;
    if (videoPlayer != nil) {
        [videoPlayer.moviePlayer.view removeFromSuperview];
    }
    
    if (currentVideoIndex < [videosArray count]) {
        videoPlayer = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:[videosArray objectAtIndex:0]];
        videoPlayer.view.frame = CGRectMake(0, 0, videoPlayView.frame.size.width, videoPlayView.frame.size.height);
        [videoPlayer presentInView:videoPlayView];
        [videoPlayer setVideoIdentifier:[videosArray objectAtIndex:currentVideoIndex]];
        ((AppDelegate*)[UIApplication sharedApplication].delegate).sharedMediaPlayer = videoPlayer.moviePlayer;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"CommentAdd"]) {
        ((TSCommentAddViewController*)segue.destinationViewController).postId = _musicItem.musicId;
        ((TSCommentAddViewController*)segue.destinationViewController).postTitle = _musicItem.title;
    }
}

#pragma mark - Button Events
- (IBAction) onBackPressed:(id)sender {
    ((AppDelegate*)[UIApplication sharedApplication].delegate).sharedMediaPlayer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onShare:(id)sender {
    NSURL *urlObj = [[NSURL alloc] initWithString:_musicItem.shareUrl];
    
    TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:self.view andRect:((UIButton *)sender).frame];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[_musicItem.title, urlObj] applicationActivities:@[openInAppActivity]];
    
    openInAppActivity.superViewController = activityViewController;
    [self presentViewController:activityViewController animated:YES completion:NULL];
}
@end
