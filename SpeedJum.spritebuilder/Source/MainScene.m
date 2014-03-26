//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene {
    CCSprite *_ball;
    CCPhysicsNode *_physicsNode;
    
    NSTimeInterval _sinceTouch;
    
    CGFloat _scrollSpeed;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
}

- (void)didLoadFromCCB {
//    _scrollSpeed = 80.f;
    self.userInteractionEnabled = TRUE;

    // set this class as delegate
    _physicsNode.collisionDelegate = self;
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [_ball.physicsBody applyImpulse:ccp(0, 400.f)];
    [_ball.physicsBody applyAngularImpulse:999.f];
    _sinceTouch = 0.f;
}

#pragma mark - CCPhysicsCollisionDelegate

//-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
//    [self gameOver];
//    return true;
//}

//-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
//    [goal removeFromParent];
//    
//    return TRUE;
//}

#pragma mark - Game Actions

- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        
        _ball.rotation = 90.f;
        _ball.physicsBody.allowsRotation = FALSE;
        [_ball stopAllActions];
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        
        [self runAction:bounce];
    }
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

}

@end
