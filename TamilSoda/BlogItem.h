//
//  BlogItem.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/13/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlogItem : NSObject

@property (nonatomic, copy) NSString *blogId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, copy) NSString *featuredImageUrl;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *author;
@property (nonatomic) BOOL isTamilcultureFeed;

- (id) initWithDictionary:(NSDictionary*) rawData;

@end
