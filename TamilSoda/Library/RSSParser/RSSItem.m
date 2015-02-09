//
//  RSSItem.m
//  RSSReader
//
//  Created by Imthiaz Rafiq @hmimthiaz
//  http://imthi.com
//  https://github.com/hmimthiaz/RSSReader
//


#import "RSSItem.h"

@implementation RSSItem

@synthesize title = _title;
@synthesize guid = _guid;
@synthesize summary = _summary;
@synthesize content = _content;
@synthesize author = _author;
@synthesize imageURL = _imageURL;
@synthesize linkURL = _linkURL;
@synthesize pubDate = _pubDate;
@synthesize categories = _categories;

- (NSString *)description{
    NSMutableString * description = [NSMutableString stringWithFormat:@"Title:%@",self.title];
    [description appendFormat:@"\nguid:%@",self.guid];
    [description appendFormat:@"\nLink:%@",self.linkURL];
    [description appendFormat:@"\nDate:%@",[self.pubDate description]];
    [description appendFormat:@"\nAuthor:%@",self.author];
    [description appendFormat:@"\nCategory:%@",self.categories];
    [description appendFormat:@"\nObject:%@",[super description]];
    return description;
}

- (void)addCategory:(NSString *)value{
    if (_categories==nil) {
        _categories = [[NSMutableArray alloc] init];
    }
    [_categories addObject:value];
}

@end
