//
//  CommentObject.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/15/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "CommentItem.h"

@implementation CommentItem

- (CommentItem*) initWithDictionary:(NSDictionary*)dic {
    self = [super init];
    if (self) {
        _commentId = dic[@"comment_ID"];
        _commentAuthor = dic[@"comment_author"];
        _commentContent = dic[@"comment_content"];
        
        NSDateFormatter *srcFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter *dstFormatter = [[NSDateFormatter alloc] init];
        
        [srcFormatter setDateFormat:@"YYYY-mm-dd HH:mm:ss"];
        [dstFormatter setDateFormat:@"EEEE, MMM d, YYYY"];
        
        NSDate* postDate = [srcFormatter dateFromString:dic[@"comment_date_gmt"]];
        _commentDate = [dstFormatter stringFromDate:postDate];
        
    }
    
    return self;
}

@end
