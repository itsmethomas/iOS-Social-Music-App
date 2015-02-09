//
//  ServiceApiHelper.m
//  TamilSoda
//
//  Created by Yingcheng Li on 1/13/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "ServiceApiHelper.h"

@implementation ServiceApiHelper

+ (NSString*) fetchPostsByCategory:(NSString*)categoryId forPageIndex:(NSInteger)pageIndex forKeyword:(NSString*)keyword{
    NSString *urlStr = [NSString stringWithFormat:@"%@action=%@&category=%@&page=%ld&keyword=%@", API_SERVER_HOST, API_ACTION_ALL, categoryId, (long)pageIndex, keyword];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString*) fetchBlogsWithKeyword:(NSString*)keyword forCategory:(NSString*) categoryId {
    NSString *urlStr = [NSString stringWithFormat:@"%@action=%@&category=%@&keyword=%@", API_SERVER_HOST, API_ACTION_ALL, categoryId, keyword];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString*) loginWithEmail:(NSString*)userName forPassword:(NSString*)password {
    NSString *urlStr = [NSString stringWithFormat:@"%@action=%@&username=%@&password=%@", API_SERVER_HOST, API_ACTION_ELOGIN, userName, password];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString*) signupWithEmail:(NSString*)userName forPassword:(NSString*)password forEmail:(NSString*) email forName:(NSString*)fullName {
    NSString *urlStr = [NSString stringWithFormat:@"%@action=%@&username=%@&password=%@&email=%@&fullname=%@", API_SERVER_HOST, API_ACTION_ESIGNUP, userName, password, email, [fullName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString*) signupWithFacebook:(NSString*)email forFBId:(NSString*)fbId forName:(NSString*)fullName {
    NSString *urlStr = [NSString stringWithFormat:@"%@action=%@&password=%@&email=%@&fullname=%@", API_SERVER_HOST, API_ACTION_FBSIGNUP, fbId, email, [fullName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString*) getComments:(NSString*)postId {
    NSString *urlStr = [NSString stringWithFormat:@"%@action=%@&postId=%@", API_SERVER_HOST, API_ACTION_LIST_COMMENTS, postId];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString*) addComment:(NSString*)params {
    NSString *urlStr = [NSString stringWithFormat:@"%@action=%@&%@", API_SERVER_HOST, API_ACTION_ADD_COMMENT, params];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSString*) forgotPassword:(NSString*)email {
    NSString *urlStr = [NSString stringWithFormat:@"%@action=%@&user=%@", API_SERVER_HOST, API_ACTION_FORGOT_PASSWORD, email];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

@end
