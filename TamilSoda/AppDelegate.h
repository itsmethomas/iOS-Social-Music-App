//
//  AppDelegate.h
//  TamilSoda
//
//  Created by Thomas Taussi on 1/8/15.
//  Copyright (c) 2015 Thomas Taussi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "GAI.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    MPMoviePlayerController *_sharedMediaPlayer;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) MPMoviePlayerController *sharedMediaPlayer;

@end

