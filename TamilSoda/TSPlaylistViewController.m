//
//  TSPlaylistViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/8/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSPlaylistViewController.h"
#import "TSSongTableViewCell.h"
#import "JSON.h"
#import "UIImageView+AFNetworking.h"
#import "ActivityIndicator.h"
#import "MusicItem.h"
#import "ServiceApiHelper.h"
#import "TSFeaturedDetailViewController.h"

#define REFRESH_HEADER_HEIGHT 60.0f

@interface TSPlaylistViewController () {
    
    IBOutlet UITableView *listTableView;
    
    IBOutlet UIButton *kadahlButton;
    IBOutlet UIButton *localButton;

    NSInteger currentPlaylistIndex;
    NSMutableArray *musicArray;
    
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
    
    NSInteger curPageIndex;
}

@end

@implementation TSPlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];

    [self reloadData];
}

- (void) reloadData {
    if (!_categoryId) {
        _categoryId = CATEGORY_PLAYLIST;
    }
    
    if (musicArray == nil) {
        musicArray = [[NSMutableArray alloc] init];
    }
    
    if ([_categoryId isEqualToString:CATEGORY_KADAHL]) {
        kadahlButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        localButton.backgroundColor = [UIColor clearColor];
    } else if ([_categoryId isEqualToString:CATEGORY_LOCAL]) {
        kadahlButton.backgroundColor = [UIColor clearColor];
        localButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    } else {
        kadahlButton.backgroundColor = [UIColor clearColor];
        localButton.backgroundColor = [UIColor clearColor];
    }
    
    [musicArray removeAllObjects];
    curPageIndex = 1;
    [[ActivityIndicator currentIndicator] show];
    
    [NSThread detachNewThreadSelector:@selector(fetchAllMusicData) toTarget:self withObject:nil];
}

- (void) initUI {
    kadahlButton.clipsToBounds = YES;
    kadahlButton.layer.cornerRadius = 15;
    kadahlButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    kadahlButton.layer.borderWidth = 1;
    
    localButton.clipsToBounds = YES;
    localButton.layer.cornerRadius = 15;
    localButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    localButton.layer.borderWidth = 1;

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
    NSString *jsonStr = [ServiceApiHelper fetchPostsByCategory:_categoryId forPageIndex:0 forKeyword:@""];
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
    NSString *jsonStr = [ServiceApiHelper fetchPostsByCategory:_categoryId forPageIndex:curPageIndex forKeyword:@""];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FeaturedDetailView"]) {
        MusicItem *musicItem = [musicArray objectAtIndex:currentPlaylistIndex];
        ((TSFeaturedDetailViewController*) segue.destinationViewController).musicItem = musicItem;
    }
}

#pragma mark - Button Events
- (IBAction) categorySelected:(UIButton*)sender {
    if (sender.tag == 0) {
        _categoryId = CATEGORY_KADAHL;
    } else {
        _categoryId = CATEGORY_LOCAL;
    }
    
    [self reloadData];
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
                                       success:nil failure:nil];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [musicArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    currentPlaylistIndex = indexPath.row;
    [self performSegueWithIdentifier:@"FeaturedDetailView" sender:nil];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
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
        bottomSpinner.frame = CGRectMake([listTableView contentSize].width / 2 - 10, MAX([listTableView contentSize].height + 20, listTableView.frame.size.height + 20), 20, 20);
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
    } else if (isDragging && scrollView.contentOffset.y + scrollView.frame.size.height> bottomSpinner.frame.origin.y) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height> bottomSpinner.frame.origin.y + REFRESH_HEADER_HEIGHT) {
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
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height > bottomSpinner.frame.origin.y + REFRESH_HEADER_HEIGHT / 2){
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
