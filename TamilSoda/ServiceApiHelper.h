//
//  ServiceApiHelper.h
//  TamilSoda
//
//  Created by Yingcheng Li on 1/13/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define API_SERVER_HOST @"http://www.tamilsoda.com/wp-admin/admin-ajax.php?"

#define API_ACTION_ALL      @"realtime_update"
#define API_ACTION_ELOGIN   @"signin_for_mobile"
#define API_ACTION_ESIGNUP  @"signup_for_mobile"
#define API_ACTION_FBSIGNUP  @"fbsignup_for_mobile"

#define API_ACTION_LIST_COMMENTS  @"get_comments"
#define API_ACTION_ADD_COMMENT  @"add_comment"
#define API_ACTION_FORGOT_PASSWORD  @"forgot_password"

#define CATEGORY_TOP        @"top"
#define CATEGORY_LATEST     @"latest"
#define CATEGORY_BLOG       @"blog"
#define CATEGORY_PLAYLIST   @"playlist"
#define CATEGORY_MUSIC      @"music"
#define CATEGORY_COVERSONGS @"cover_songs"
#define CATEGORY_KADAHL     @"kadahl"
#define CATEGORY_LOCAL      @"local"
#define CATEGORY_TRAILERS   @"trailers"
#define CATEGORY_SEARCH     @"search"
#define CATEGORY_TAMIL_BLOG @"tamilsoda_blog"

@interface ServiceApiHelper : NSObject

+ (NSString*) fetchPostsByCategory:(NSString*)categoryId forPageIndex:(NSInteger)pageIndex forKeyword:(NSString*)keyword;
+ (NSString*) fetchBlogsWithKeyword:(NSString*)keyword forCategory:(NSString*) categoryId;
+ (NSString*) loginWithEmail:(NSString*)userName forPassword:(NSString*)password;
+ (NSString*) signupWithEmail:(NSString*)userName forPassword:(NSString*)password forEmail:(NSString*) email forName:(NSString*)fullName;
+ (NSString*) signupWithFacebook:(NSString*)email forFBId:(NSString*)fbId forName:(NSString*)fullName;
+ (NSString*) getComments:(NSString*)postId;
+ (NSString*) addComment:(NSString*)params;
+ (NSString*) forgotPassword:(NSString*)email;


@end
