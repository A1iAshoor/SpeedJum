//
//  AppDelegate.h
//  SpeedJum
//
//  Created by Ali on 3/17/14.
//  Copyright Ali Ashoor 2014. All rights reserved.
//

#import "cocos2d.h"

@interface SpeedJumAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, weak) IBOutlet NSWindow    *window;
@property (nonatomic, weak) IBOutlet CCGLView    *glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
