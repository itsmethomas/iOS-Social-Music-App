//
//  TSPlaylistViewController.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/8/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "GAI.h"

enum {
    SOCIAL_SHARE_MAIL = 0,
    SOCIAL_SHARE_MESSAGE,
    SOCIAL_SHARE_FACEBOOK,
    SOCIAL_SHARE_TWITTER,
    SOCIAL_SHARE_WHATSAPP
};

@interface TSCommonViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *keyword;

- (void) stopPlaying;

@end
