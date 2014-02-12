//
//  Gravitarium2AppDelegate.h
//  Gravitarium2
//
//  Created by Robert Neagu on 11/3/10.
//  Copyright 2010 TotalSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVAudio.h"
#import "GLViewController.h"

@class Audio;

@interface Gravitarium2AppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GLViewController *glViewController;

@end