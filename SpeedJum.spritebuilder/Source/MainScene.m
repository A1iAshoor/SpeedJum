//
//  MainScene.m
//  SpeedJum
//
//  Created by Ali on 3/28/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "MainScene.h"

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderGround,
    DrawingOrderBall
};

@implementation MainScene {
    CCSprite *_ball;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground;
    BOOL _gameCenterEnabled;
    NSString *_leaderboardIdentifier;
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
    [tracker set:kGAIScreenName value:@"MainScene"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    // set integaction
    self.userInteractionEnabled = TRUE;
    
    // set the grounds zOrder
    _ground.zOrder = DrawingOrderGround;
    
    // set this class as delegate
    _physicsNode.collisionDelegate = self;
    
    // authenticate local player
    [self authenticateLocalPlayer];
    
    // reset achievements
    // [self resetAchievements];
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [_ball.physicsBody applyImpulse:ccp(0, 400.f)];
//    [_ball.physicsBody applyAngularImpulse:10000.f];
}

#pragma mark - Button Triggers

- (void)play {
    CCScene *playScene = [CCBReader loadAsScene:@"PlayScene"];
    [[CCDirector sharedDirector] replaceScene:playScene];
}

- (void)leaderboard {
    CCScene *leaderboardScene = [CCBReader loadAsScene:@"LeaderboardScene"];
    [[CCDirector sharedDirector] replaceScene:leaderboardScene];
}

- (void)settings {
    CCScene *settingsScene = [CCBReader loadAsScene:@"SettingsScene"];
    [[CCDirector sharedDirector] replaceScene:settingsScene];
}

- (void)openFacebook {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"You are about to close the app, are you sure of this action?"
                                                       delegate:self
                                              cancelButtonTitle:@"No, stay here"
                                              otherButtonTitles:@"Yes", nil];
    [alertView show];
    alertView.tag=0;
}

- (void)openTwitter {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"You are about to close the app, are you sure of this action?"
                                                       delegate:self
                                              cancelButtonTitle:@"No, stay here"
                                              otherButtonTitles:@"Yes", nil];
    [alertView show];
    alertView.tag=1;
}

- (void)openGameCenter {
    [self showLeaderboardAndAchievements:YES];
}

#pragma mark - AlertView Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 0){
        if(buttonIndex == 1)
        {
            NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/476666129127597"]];
            NSURL *webURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://facebook.com/SpeedJum"]];
            
            if([[UIApplication sharedApplication] canOpenURL:appURL]){
                [[UIApplication sharedApplication] openURL:appURL];
            }else{
                [[UIApplication sharedApplication] openURL:webURL];
            }
        }
    }else if(alertView.tag == 1){
        if(buttonIndex == 1)
        {
            NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=SpeedJum"]];
            NSURL *webURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/SpeedJum"]];
            
            if([[UIApplication sharedApplication] canOpenURL:appURL]){
                [[UIApplication sharedApplication] openURL:appURL];
            }else{
                [[UIApplication sharedApplication] openURL:webURL];
            }
        }
    }
}

#pragma mark - GameKit Methods

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [[CCDirector sharedDirector] presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = _leaderboardIdentifier;
    }
    else{
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    [[CCDirector sharedDirector] presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)resetAchievements{
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

@end
