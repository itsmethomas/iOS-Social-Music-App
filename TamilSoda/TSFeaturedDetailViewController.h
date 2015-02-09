//
//  TSFeaturedDetailViewController.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/14/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicItem;

@interface TSFeaturedDetailViewController : UIViewController <NSXMLParserDelegate>

@property (nonatomic, retain) MusicItem *musicItem;

@end
