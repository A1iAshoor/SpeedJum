/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "AppDelegate.h"
#import "CCBuilderReader.h"

// Appirater
#import "Appirater.h"

// Harpy (New App Update Notifier)
#import "Harpy.h"

// Parse for push notifications
#import <Parse/Parse.h>

static NSString *const kTrackingId = @"UA-49485120-1";

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure Cocos2d with the options set in SpriteBuilder
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"];
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    
    NSMutableDictionary* cocos2dSetup = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
    
    #ifdef APPORTABLE
    if([cocos2dSetup[CCSetupScreenMode] isEqual:CCScreenModeFixed])
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
    else
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenScaledAspectFitEmulationMode];
    #endif
    
    // Configure CCFileUtils to work with SpriteBuilder
    [CCBReader configureCCFileUtils];
    
    // Do any extra configuration of Cocos2d here (the example line changes the pixel format for faster rendering, but with less colors)
    //[cocos2dSetup setObject:kEAGLColorFormatRGB565 forKey:CCConfigPixelFormat];
    
    [self setupCocos2dWithOptions:cocos2dSetup];
    
    // access audio object
    OALSimpleAudio *audio = [OALSimpleAudio sharedInstance];
    
    // play background sound
    [audio playBg:@"clear-blue-sky.mp3" volume:0.05f pan:0 loop:TRUE];
    
    ////////////////////////////////////////////////////////////////////////
    // Register for push notifications
    ////////////////////////////////////////////////////////////////////////
    // AudioToolbox.framework
    // CFNetwork.framework
    // CoreGraphics.framework
    // CoreLocation.framework
    // libz.dylib
    // MobileCoreServices.framework
    // QuartzCore.framework
    // Security.framework
    // StoreKit.framework
    // SystemConfiguration.framework
    ////////////////////////////////////////////////////////////////////////
    [Parse setApplicationId:@"lBBc8zMd728g6irKuQ96hIag57nVKlu85RoUD2sZ" clientKey:@"nBB9bAJmrQa6Gu9U9NO8dRD8pS3uHLj9caBBPzLe"];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    
    ////////////////////////////////////////////////////////////////////////
    // Google Analytics.
    ////////////////////////////////////////////////////////////////////////
    // libGoogleAnalyticsServices.a
    // AdSupport.framework
    // CoreData.framework
    // SystemConfiguration.framework
    // libz.dylib
    ////////////////////////////////////////////////////////////////////////
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 10;
    
    // Initialize tracker.
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    self.tracker = [[GAI sharedInstance] defaultTracker];
    
    ////////////////////////////////////////////////////////////////////////
    // Appirater Hendler.
    [Appirater setAppId:@"849128788"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:2];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    
    ////////////////////////////////////////////////////////////////////////
    // Harpy (New Update Notifier).
    [[Harpy sharedInstance] setAppID:@"849128788"];
    // Overides system language to predefined language.
    [[Harpy sharedInstance] setForceLanguageLocalization:HarpyLanguageEnglish];
    
    return YES;
}

- (CCScene*)startScene
{
    return [CCBReader loadAsScene:@"MainScene"];
}

-(void) applicationWillResignActive:(UIApplication *)application
{
    [[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[CCDirector sharedDirector] resume];

    // Perform daily check for new version of the app
    [[Harpy sharedInstance] checkVersionDaily];
    
    // Clearing the Badge
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

-(void)applicationDidEnterBackground:(UIApplication*)application
{
    [[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    [[CCDirector sharedDirector] startAnimation];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationSignificantTimeChange:(UIApplication *)application
{
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

#pragma mark - Push notifications handlers

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end
