//
//  PlayScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"
#import <GameKit/GameKit.h>

// Google Analytics
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface PlayScene : CCNode <CCPhysicsCollisionDelegate, UIAlertViewDelegate>

-(void)reportScore;
-(void)updateAchievements;

@end
