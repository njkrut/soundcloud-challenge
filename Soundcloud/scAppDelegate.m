//
//  scAppDelegate.m
//  Soundcloud
//
//  Created by Nicholas Krut on 8/20/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import "scAppDelegate.h"
#import "SCUI.h"
#import "scViewController.h"
#import "scAudioPlayer.h"

@implementation scAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[scViewController alloc] initWithNibName:@"scViewController" bundle:nil];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [[self.viewController navigationController] setNavigationBarHidden:YES animated:NO];
    
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
    
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (void)initialize;
{
    [SCSoundCloud  setClientID:@"bdacc1c417260a7b78438097e3a3c795"
                        secret:@"84ac8251b4cebdd31b84d733e9ac5057"
                   redirectURL:[NSURL URLWithString:@"soundcloudchallenge://oauth"]];
}

// remote control
- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (void) remoteControlReceivedWithEvent:(UIEvent*) aEvent
{
	if (aEvent.type == UIEventTypeRemoteControl)
	{
        scAudioPlayer *player = [scAudioPlayer GetSingleton];
		switch (aEvent.subtype)
		{
			case UIEventSubtypeRemoteControlPlay:
                if (player)
                    [player playPause];
                else
                {
                    [player playTrack:0];
                }
                
				break;
			case UIEventSubtypeRemoteControlPause:
                if (player)
                    [player playPause];
                
				break;
			case UIEventSubtypeRemoteControlStop:
                if (player)
                    [player stop];
                
				break;
			case UIEventSubtypeRemoteControlTogglePlayPause:
                [player playPause];
                
				break;
			case UIEventSubtypeRemoteControlNextTrack:
                [player nextTrack];
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
                [player lastTrack];
				break;
			default:
				return;
		}
	}
}

@end
