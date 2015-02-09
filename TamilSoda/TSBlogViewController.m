//
//  TSBlogViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/9/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSBlogViewController.h"
#import "TSSongTableViewCell.h"
#import "JSON.h"
#import "UIImageView+AFNetworking.h"
#import "ActivityIndicator.h"
#import "BlogItem.h"
#import "ServiceApiHelper.h"
#import "TSBlogDetailViewController.h"

#define RSS_FEED_URL    @"http://tamilculture.ca/feed/"

@interface TSBlogViewController () {
    IBOutlet UITableView *blogTableView;
    IBOutlet UITextField *searchTextField;
    
    NSInteger currentBlogIndex;
    NSMutableArray *blogArray;
    
    RSSParser *parser;
}

@end

@implementation TSBlogViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // init data...
    if (_keyword) {
        searchTextField.text = _keyword;
    } else {
        _keyword = @"";
    }
    [self reloadData];
}

- (void) reloadData {
    blogArray = [[NSMutableArray alloc] init];
    [[ActivityIndicator currentIndicator] show];
    
    [NSThread detachNewThreadSelector:@selector(fetchAllBlogData) toTarget:self withObject:nil];
}

- (void) fetchAllBlogData {
    NSString *jsonStr = [ServiceApiHelper fetchBlogsWithKeyword:_keyword forCategory:_categoryId];
    NSArray *array = [[SBJsonParser new] objectWithString:jsonStr];
    for (NSDictionary *item in array) {
        BlogItem *bItem = [[BlogItem alloc] initWithDictionary:item];
        [blogArray addObject:bItem];
    }
    
    [blogTableView reloadData];
    if ([_categoryId isEqualToString:CATEGORY_BLOG]) {
        [self performSelectorOnMainThread:@selector(startDownloadRSS) withObject:nil waitUntilDone:NO];
    } else {
        [[ActivityIndicator currentIndicator] hide];
    }
}

- (void) startDownloadRSS {
    parser = [[RSSParser alloc] initWithRSSURL:RSS_FEED_URL];
    parser.rssDelegate = self;
    [parser start];
}

- (void)RSSParserDidCompleteParsing {
    [[ActivityIndicator currentIndicator] hide];
    
    for (RSSItem *item in parser.rssItems) {
        BlogItem *bItem = [[BlogItem alloc] init];
        
        if (![_keyword isEqualToString:@""] && ![item.title containsString:_keyword] && ![item.content containsString:_keyword])
            continue;
        bItem.blogId = item.guid;
        bItem.title = item.title;
        bItem.category = @"Tamilculture";
        bItem.content = item.content;
        bItem.thumbnailUrl = item.imageURL;
        bItem.featuredImageUrl = item.imageURL;
        bItem.author = item.author;
        bItem.shareUrl = item.linkURL;
        bItem.isTamilcultureFeed = YES;
        
        [blogArray addObject:bItem];
    }
    [blogTableView reloadData];
}

- (void)RSSParserHasError:(NSError *)error {
    [[ActivityIndicator currentIndicator] hide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BlogDetailView"]) {
        BlogItem *blogItem = [blogArray objectAtIndex:currentBlogIndex];
        ((TSBlogDetailViewController*) segue.destinationViewController).blogItem = blogItem;
    } else if ([segue.identifier isEqualToString:@"OtherDetailView"]) {
        BlogItem *blogItem = [blogArray objectAtIndex:currentBlogIndex];
        ((TSBlogDetailViewController*) segue.destinationViewController).blogItem = blogItem;
    }
}

#pragma - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    _keyword = textField.text;
    [self reloadData];
    return [textField resignFirstResponder];
}

- (IBAction) onSearch:(id)sender {
    _keyword = searchTextField.text;
    [self reloadData];
}

#pragma mark - UITableViewDelegate & DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSSongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    BlogItem *item = [blogArray objectAtIndex:indexPath.row];
    cell.songTitleLabel.text = item.title;
    cell.songArtistLabel.text = item.author;
    cell.songCategoryLabel.text = item.category;
    
    cell.songTitleLabel.frame = CGRectMake(cell.songTitleLabel.frame.origin.x, cell.songTitleLabel.frame.origin.y, blogTableView.frame.size.width -  cell.songTitleLabel.frame.origin.x - 40, cell.songTitleLabel.frame.size.height);
    cell.songCategoryLabel.frame = CGRectMake(cell.songCategoryLabel.frame.origin.x, cell.songCategoryLabel.frame.origin.y, cell.songTitleLabel.frame.size.width, cell.songTitleLabel.frame.size.height);
    cell.songArtistLabel.frame = CGRectMake(cell.songArtistLabel.frame.origin.x, cell.songArtistLabel.frame.origin.y, cell.songTitleLabel.frame.size.width, cell.songTitleLabel.frame.size.height);
    
    cell.pinkArrowView.frame = CGRectMake(blogTableView.frame.size.width - 30, cell.pinkArrowView.frame.origin.y, cell.pinkArrowView.frame.size.width, cell.pinkArrowView.frame.size.height);

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:item.thumbnailUrl]];
    [req addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [cell.songImageView setImageWithURLRequest:req placeholderImage:[UIImage imageNamed:@"app-watermark.png"]
                                       success:nil failure:nil];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [blogArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    currentBlogIndex = indexPath.row;
    BlogItem *bItem = [blogArray objectAtIndex:indexPath.row];
    
    if (bItem.isTamilcultureFeed) {
        [self performSegueWithIdentifier:@"OtherDetailView" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"BlogDetailView" sender:nil];
    }
}

@end
