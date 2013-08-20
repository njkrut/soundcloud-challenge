//
//  scAppDelegate.h
//  Soundcloud
//
//  Created by Nicholas Krut on 8/20/13.
//  Copyright (c) 2013 sc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class scViewController;

@interface scAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) scViewController *viewController;

@end
