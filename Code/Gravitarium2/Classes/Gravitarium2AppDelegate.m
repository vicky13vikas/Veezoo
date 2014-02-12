//
//  Gravitarium2AppDelegate.m
//  Gravitarium2
//
//  Created by Robert Neagu on 11/3/10.
//  Copyright 2010 TotalSoft. All rights reserved.
//

#import "Gravitarium2AppDelegate.h"

@implementation Gravitarium2AppDelegate

@synthesize window, glViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Create window
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    //Create controller
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.glViewController = [[[GLViewController alloc] initWithNibName: @"GLViewController-iPad" bundle: nil] autorelease];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([[UIScreen mainScreen] bounds].size.height == 480)
            self.glViewController = [[[GLViewController alloc] initWithNibName: @"GLViewController" bundle: nil] autorelease];
        else
            self.glViewController = [[[GLViewController alloc] initWithNibName: @"GLViewController-iPhone5" bundle: nil] autorelease];
    }
    
    //Add controller
    [window setRootViewController: glViewController];
	[window makeKeyAndVisible];
    
    //GameKit
    [GameKitLibrary sharedGameKit].presentingViewController = glViewController;
    
    //Return
    return TRUE;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

#pragma mark Memory management

- (void)dealloc {
    [window release];
    [glViewController release];
    [super dealloc];
}

@end
