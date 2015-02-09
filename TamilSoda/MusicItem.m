//
//  MusicItem.m
//  TamilSoda
//
//  Created by Yingcheng Li on 1/13/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "MusicItem.h"

@implementation MusicItem

- (id) initWithDictionary:(NSDictionary*) rawData {
    self = [super init];
    if (self) {
        _musicId = rawData[@"id"];
        _title = rawData[@"title"];
        _content = rawData[@"content"];
        _shareUrl = rawData[@"share_url"];
        _category = rawData[@"category"];
        _thumbnailUrl = rawData[@"image_src"];
        _videoUrl = rawData[@"video_url"];
        _artists = rawData[@"artists"];
        _lyrics = rawData[@"lyrics"];
        _music = rawData[@"music"];
        _album = rawData[@"album"];
        _videoEditing = rawData[@"video_editing"];
        _label = rawData[@"label"];
        _releaseDate = rawData[@"release_date"];
        _featuredImageUrl = rawData[@"featured_img_src"];
        _author = rawData[@"author"];
        
        // Get Video Id...
        _videoId = @"";
        if (![_videoUrl isEqual:@""]) {
            NSArray *arr = [_videoUrl componentsSeparatedByString:@"?v="];
            if ([arr count] > 1)
                _videoId = [arr objectAtIndex:1];
        }
        
        NSString *playlist = rawData[@"playlist"];
        if (![playlist isEqualToString:@""]) {
            NSArray *arr = [playlist componentsSeparatedByString:@"?list="];
            if ([arr count] > 1)
                _playListId = [arr objectAtIndex:1];
            else
                _playListId = @"";
        }
    }
    
    return self;
}

@end
