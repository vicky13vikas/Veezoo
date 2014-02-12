//
//  ControlsViewController.h
//  Gavitarium2
//
//  Created by Robert Neagu on 5/10/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLViewController.h"
#import "AVAudio.h"

@class GLViewController;
@class AVAudio;

@interface ControlsViewController : UIViewController {
    GLViewController *parent;
    
    UIButton *btnPause;
    UIButton *btnPhoto;
    UIButton *btnAudio;
    UIButton *btnOptions;
    UIButton *btnConnect;
    UIButton *btnLeaderboard;
    UIButton *btnHelp;
    UIButton *btnCredits;
    UIButton *credits;
}

@property (nonatomic, assign) GLViewController *parent;

@property (nonatomic, retain) IBOutlet UIButton *btnPause;
@property (nonatomic, retain) IBOutlet UIButton *btnPhoto;
@property (nonatomic, retain) IBOutlet UIButton *btnAudio;
@property (nonatomic, retain) IBOutlet UIButton *btnOptions;
@property (nonatomic, retain) IBOutlet UIButton *btnConnect;
@property (nonatomic, retain) IBOutlet UIButton *btnLeaderboard;
@property (nonatomic, retain) IBOutlet UIButton *btnHelp;
@property (nonatomic, retain) IBOutlet UIButton *btnCredits;

- (IBAction)pause:(id)sender;
- (IBAction)photo:(id)sender;
- (IBAction)sound:(id)sender;
- (IBAction)options:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)leaderboard:(id)sender;
- (IBAction)help:(id)sender;
- (IBAction)credits:(id)sender;

@end