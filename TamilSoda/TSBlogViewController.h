//
//  TSBlogViewController.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/9/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSParser.h"
#import "RSSItem.h"

@interface TSBlogViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource,
                                    UITableViewDelegate, RSSParserDelegate>

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *categoryId;

@end
