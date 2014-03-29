//
//  SettingsScene.m
//  SpeedJum
//
//  Created by Ali on 3/28/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "SettingsScene.h"
#import <Social/Social.h>

@implementation SettingsScene{
    CCButton *_musicTrigger;
    OALSimpleAudio *audio;
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
    [tracker set:kGAIScreenName value:@"SettingsScene"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    // get audio
    audio = [OALSimpleAudio sharedInstance];
}

- (void)back {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

- (void)share {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Thanks for sharing SpeedJum via.."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Facebook", @"Twitter", nil];
    [alertView show];
}

- (void)musicTrigger {
    if(audio.bgPlaying)
    {
        [audio stopBg];
        _musicTrigger.title = [NSString stringWithFormat:@"MUSIC: OFF"];
    }
    else
    {
        [audio playBgWithLoop:TRUE];
        _musicTrigger.title = [NSString stringWithFormat:@"MUSIC: ON"];
    }
}

#pragma mark - AlertView Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1)
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [facebookSheet setInitialText:@"Check out SpeedJum, AWESOME FREE! game on Appstore https://itunes.apple.com/us/app/speedjum/id849128788?ls=1&mt=8 #AppStore @SpeedJum"];
            [[CCDirector sharedDirector] presentViewController:facebookSheet animated:YES completion:NULL];
        }
        else
        {
            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Ooooops!"
                                                             message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
        }
    }else if (buttonIndex == 2){
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController
                                                   composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:@"Check out SpeedJum, AWESOME FREE! game on Appstore https://itunes.apple.com/us/app/speedjum/id849128788?ls=1&mt=8 #AppStore @SpeedJum"];
            [[CCDirector sharedDirector] presentViewController:tweetSheet animated:YES completion:NULL];
        }
        else
        {
            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Ooooops!"
                                                             message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
