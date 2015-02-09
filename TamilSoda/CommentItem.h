//
//  CommentObject.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/15/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentItem : NSObject

@property (nonatomic, retain) NSString *commentId;
@property (nonatomic, retain) NSString *commentAuthor;
@property (nonatomic, retain) NSString *commentDate;
@property (nonatomic, retain) NSString *commentContent;

- (CommentItem*) initWithDictionary:(NSDictionary*)dic;

@end
