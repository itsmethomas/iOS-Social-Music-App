//
//  TSPlaylistViewController.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/14/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSPlaylistViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *categoryId;

- (void) reloadData;

@end
