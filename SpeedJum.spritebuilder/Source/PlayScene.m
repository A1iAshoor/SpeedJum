//
//  PlayScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "PlayScene.h"
#import "Obstacle.h"
#import <Social/Social.h>

static const CGFloat firstObstaclePosition = 380.f;
static const CGFloat distanceBetweenObstacles = 120.f;

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderGround,
    DrawingOrderBall,
    DrawingOrderBlocks
};

@implementation PlayScene {
    CCSprite *_ball;
    CCPhysicsNode *_physicsNode;
    
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    NSTimeInterval _sinceTouch;
    
    NSMutableArray *_obstacles;
    
    CGFloat _scrollSpeed;
    
    CCButton *_restartButton;
    CCButton *_backButton;
    CCButton *_shareButton;
    
    BOOL _gameOver;
    
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_gameOverScoreLabel;
    
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
    [tracker set:kGAIScreenName value:@"PlayScene"];

    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

    // set scrool and interaction options
    _scrollSpeed = 200.f;
    self.userInteractionEnabled = TRUE;
    
    // set the grounds zOrder
    _grounds = @[_ground1, _ground2];
    for (CCNode *ground in _grounds) {
        // set zorder
        ground.zOrder = DrawingOrderGround;
    }

    // set this class as delegate
    _physicsNode.collisionDelegate = self;

    // set collision txpe
    _ball.physicsBody.collisionType = @"ball";
    _ball.zOrder = DrawingOrderBall;
    
    // create obstacles
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
    [[CCDirector sharedDirector] startAnimation];
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        [_ball.physicsBody applyImpulse:ccp(0, 400.f)];
        [_ball.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
    }
}

#pragma mark - CCPhysicsCollisionDelegate

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball level:(CCNode *)level {
    [self gameOver];
    return true;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball goal:(CCNode *)goal {
    
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];
    
    return true;
}

#pragma mark - Game Actions

- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        
        _gameOverScoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];
        
        _gameOverScoreLabel.visible = TRUE;
        _restartButton.visible = TRUE;
        _backButton.visible = TRUE;
        _shareButton.visible = TRUE;
        _scoreLabel.visible = FALSE;
        
        _ball.rotation = 90.f;
        _ball.physicsBody.allowsRotation = FALSE;
        [_ball stopAllActions];
        [self reportScore];
        [self updateAchievements];
        
        NSInteger *_hightscore = (NSInteger*)[[[NSUserDefaults standardUserDefaults] objectForKey:@"score"] integerValue];
        
        if(_points > (int)_hightscore){
            [[NSUserDefaults standardUserDefaults] setInteger:_points forKey:@"score"];
        }
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"PlayScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)back {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

- (void)share {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Share your score with friends via.."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Facebook", @"Twitter", nil];
    [alertView show];
}

#pragma mark - Obstacle Spawning

- (void)spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [obstacle setupRandomPosition];
    obstacle.zOrder = DrawingOrderBlocks;
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

#pragma mark - Update

- (void)update:(CCTime)delta {
    // clamp velocity
    float yVelocity = clampf(_ball.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _ball.physicsBody.velocity = ccp(0, yVelocity);
    _ball.position = ccp(_ball.position.x + delta * _scrollSpeed, _ball.position.y);
    
    _sinceTouch += delta;
    
    _ball.rotation = clampf(_ball.rotation, -30.f, 90.f);
    
    if (_ball.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_ball.physicsBody.angularVelocity, -2.f, 1.f);
        _ball.physicsBody.angularVelocity = angularVelocity;
    }
    
    if ((_sinceTouch > 0.5f)) {
        [_ball.physicsBody applyAngularImpulse:-40000.f*delta];
    }
    
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed *delta), _physicsNode.position.y);

    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    NSMutableArray *offScreenObstacles = nil;
    
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];

        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacle];
    }
    
}

#pragma mark - GameKit Methods

-(void)reportScore{
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"SJ01"];
    score.value = _points;

    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)updateAchievements{
    NSString *achievementIdentifier;
    float progressPercentage = 0.0;

    GKAchievement *scoreAchievement = nil;
    
    if (_points == 1){
        progressPercentage = _points * 100 / 1;
        achievementIdentifier = @"FT01";
    }
    else if (_points <= 101){
        progressPercentage = _points * 100 / 101;
        achievementIdentifier = @"S01";
    }
    else if (_points <= 201){
        progressPercentage = _points * 100 / 201;
        achievementIdentifier = @"J01";
    }
    else if (_points <= 301){
        progressPercentage = _points * 100 / 301;
        achievementIdentifier = @"SJ01";
    }
    
    scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
    scoreAchievement.percentComplete = progressPercentage;
    
    NSArray *achievements = @[scoreAchievement];
    
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

#pragma mark - AlertView Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1)
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [facebookSheet setInitialText:[NSString stringWithFormat:@"I reached %ld points on SpeedJum, AWESOME FREE! game on Appstore https://itunes.apple.com/us/app/speedjum/id849128788?ls=1&mt=8 #AppStore @SpeedJum",(long)_points]];
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
            [tweetSheet setInitialText:[NSString stringWithFormat:@"I reached %ld points on SpeedJum, AWESOME FREE! game on Appstore https://itunes.apple.com/us/app/speedjum/id849128788?ls=1&mt=8 #AppStore @SpeedJum",(long)_points]];
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
