//
//  SessionManager.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/15/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionManager : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userEmail;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, retain) NSDictionary *placeholderData;

+ (SessionManager*) currentSession;
- (void) initSessionWithDictionary:(NSDictionary*)dic;

@end
