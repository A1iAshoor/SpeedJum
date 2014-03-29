//
//  MainScene.h
//  SpeedJum
//
//  Created by Ali on 3/28/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import <GameKit/GameKit.h>

// Google Analytics
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface MainScene : CCNode <CCPhysicsCollisionDelegate,GKGameCenterControllerDelegate,UIAlertViewDelegate>

-(void)authenticateLocalPlayer;
-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;
-(void)resetAchievements;

@end
