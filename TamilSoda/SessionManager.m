//
//  SessionManager.m
//  TamilSoda
//
//  Created by Thomas Taussi on 1/15/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

static SessionManager *currentSession;

+ (SessionManager*) currentSession {
    if (currentSession == nil) {
        currentSession = [[SessionManager alloc] init];
    }
    
    return currentSession;
}

- (void) initSessionWithDictionary:(NSDictionary*)dic {
    _userId = dic[@"userId"];
    _userEmail = dic[@"userEmail"];
    _userName = dic[@"userName"];
    _placeholderData = dic[@"basic"];
}

@end
