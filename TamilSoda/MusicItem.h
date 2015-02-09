//
//  MusicItem.h
//  TamilSoda
//
//  Created by Yingcheng Li on 1/13/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MusicItem : NSObject

@property (nonatomic, copy) NSString *musicId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, copy) NSString *featuredImageUrl;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *artists;
@property (nonatomic, copy) NSString *lyrics;
@property (nonatomic, copy) NSString *music;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, copy) NSString *videoEditing;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *releaseDate;
@property (nonatomic, copy) NSString *playListId;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, copy) NSString *author;

- (id) initWithDictionary:(NSDictionary*) rawData;

@end
