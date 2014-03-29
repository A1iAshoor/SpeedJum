//
//  LeaderboardScene.m
//  SpeedJum
//
//  Created by Ali on 3/28/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "LeaderboardScene.h"

@implementation LeaderboardScene {
    CCLabelTTF *_highscore;
}

- (void)didLoadFromCCB {
    ////////////////////////////////////////////////////////////////////////
    // Google Analytics
    ////////////////////////////////////////////////////////////////////////
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:@"LeaderboardScene"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"score"]!=nil){
        _highscore.string = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"score"]];
    }else{
        _highscore.string = [NSString stringWithFormat:@"You didn't play yet :D"];
    }
}

- (void)back {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

@end
