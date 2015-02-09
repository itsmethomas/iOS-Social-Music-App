//
//  TSSongTableViewCell.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/8/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSSongTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *songImageView;
@property (nonatomic, retain) IBOutlet UILabel *songTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *songArtistLabel;
@property (nonatomic, retain) IBOutlet UILabel *songCategoryLabel;
@property (nonatomic, retain) IBOutlet UIImageView *pinkArrowView;

@end
