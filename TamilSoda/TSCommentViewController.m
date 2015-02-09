//
//  TSCommentViewController.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/15/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "TSCommentViewController.h"
#import "ServiceApiHelper.h"
#import "ActivityIndicator.h"
#import "JSON.h"
#import "CommentItem.h"
#import "TSCommentTableViewCell.h"

@interface TSCommentViewController () {
    IBOutlet UIButton *backButton;
    IBOutlet UILabel *titleLabel;
    
    NSMutableArray *commentsArray;
    IBOutlet UITableView *commentTableView;
}

@end

@implementation TSCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void) initUI {
//    UIImage *backImage = [[UIImage imageNamed:@"ico_back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [backButton setImage:backImage forState:UIControlStateNormal];
//    backButton.tintColor = [UIColor darkGrayColor];
    
    titleLabel.text = _postTitle;
    commentsArray = [[NSMutableArray alloc] init];
    
    [[ActivityIndicator currentIndicator] show];
    [NSThread detachNewThreadSelector:@selector(fetchAllCommentsData) toTarget:self withObject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) fetchAllCommentsData {
    NSString *jsonStr = [ServiceApiHelper getComments:_postId];
    NSArray *array = [[SBJsonParser new] objectWithString:jsonStr];
    for (NSDictionary *item in array) {
        CommentItem *cItem = [[CommentItem alloc] initWithDictionary:item];
        [commentsArray addObject:cItem];
    }
    
    [commentTableView reloadData];
    [[ActivityIndicator currentIndicator] hide];
}

#pragma mark - Button Events
- (IBAction) onBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [commentsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    CommentItem *item = [commentsArray objectAtIndex:indexPath.row];
    NSString *content = item.commentContent;
    CGRect rect = [content boundingRectWithSize:(CGSize){cell.contentLabel.frame.size.width, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                        context:nil ];
    
    return rect.size.height + cell.contentLabel.frame.origin.y + 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    CommentItem *item = [commentsArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = item.commentAuthor;
    cell.dateLabel.text = item.commentDate;
    cell.contentLabel.text = item.commentContent;
    
    CGRect rect = [item.commentContent boundingRectWithSize:(CGSize){cell.contentLabel.frame.size.width, CGFLOAT_MAX}
                                                    options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                                    context:nil ];
    cell.contentLabel.frame = CGRectMake(cell.contentLabel.frame.origin.x, cell.contentLabel.frame.origin.y, rect.size.width, rect.size.height);
    return cell;
}

@end
