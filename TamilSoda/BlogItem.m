//
//  BlogItem.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/13/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "BlogItem.h"

@implementation BlogItem

- (id) initWithDictionary:(NSDictionary*) rawData {
    self = [super init];
    if (self) {
        _blogId = rawData[@"id"];
        _title = rawData[@"title"];
        _content = rawData[@"content"];
        _shareUrl = rawData[@"share_url"];
        _category = rawData[@"category"];
        _thumbnailUrl = rawData[@"image_src"];
        _featuredImageUrl = rawData[@"featured_img_src"];
        _author = rawData[@"author"];
        
        _isTamilcultureFeed = NO;
    }
    
    return self;
}


@end
