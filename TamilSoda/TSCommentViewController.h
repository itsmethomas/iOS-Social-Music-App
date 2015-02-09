//
//  TSCommentViewController.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/15/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCommentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *postId;
@property (nonatomic, copy) NSString *postTitle;

@end
