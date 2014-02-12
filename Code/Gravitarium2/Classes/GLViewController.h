//
//  GLViewController.h
//  Gravitarium2
//
//  Created by Robert Neagu on 11/3/10.
//  Copyright 2010 TotalSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLView.h"
#import "Options.h"
#import "ControlsViewController.h"
#import "OptionsViewController.h"
#import "AudioViewController.h"
#import "HelpViewController.h"
#import "CreditsViewController.h"
#import "AVAudio.h"
#import "GameKitLibrary.h"
#import "General.h"
#import <AudioToolbox/AudioToolbox.h>
//#import "GADBannerView.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"

#pragma mark - Classes

@class GLView;
@class Options;
@class ControlsViewController;
@class OptionsViewController;
@class AudioViewController;
@class HelpViewController;
@class CreditsViewController;
@class EmptyViewController;
@class Audio;
@class GameKitLibrary;
@class Reachability;

@interface GLViewController : UIViewController<GKMatchmakerViewControllerDelegate, GKMatchDelegate, GKLeaderboardViewControllerDelegate, GKFriendRequestComposeViewControllerDelegate, MusicPlayerDelegate, NetworkSendDelegate, ModalViewDelegate, GADInterstitialDelegate> {

    //GADBannerView *bannerView_;
    
    //NetworkReceiverDelegate
    id<NetworkReceiveDelegate> delegate;
    
    //Controllers
    ControlsViewController *controlsViewController;
    UIPopoverController *popoverController;
    
    //Toast
    UIView *viewToast;
    UILabel *lblToast;
    
    //Player InfoBox
    UILabel *lblPlayer;
    UIButton *btnPlayer;
    UIView *viewPlayer;
    
    //GameCenter Match
    GKMatch *myMatch;
    bool matchStarted;
    NSString *remotePlayerID;
    NSString *remotePlayerAlias;
    
    //Other
    GLView *glView;
    bool menuAnimationBusy;
    bool menuVisible;
    bool animationPaused;
    int currentToastID;
    
    //Resolution Multiplier
    GLfloat resMultiplierX;
    GLfloat resMultiplierY;
    
    BOOL isFromViewDidLoad;
}

//Controllers
@property (nonatomic, readonly) ControlsViewController *controlsViewController;
@property (nonatomic, retain) UIPopoverController *popoverController;

//Toast
@property (nonatomic, retain) IBOutlet UIView *viewToast;
@property (nonatomic, retain) IBOutlet UILabel *lblToast;

//Player InfoBox
@property (nonatomic, retain) IBOutlet UILabel *lblPlayer;
@property (nonatomic, retain) IBOutlet UIButton *btnPlayer;
@property (nonatomic, retain) IBOutlet UIView *viewPlayer;

//Match
@property (nonatomic, retain) GKMatch *myMatch;
@property (nonatomic, assign) bool matchStarted;
@property (nonatomic, retain) NSString *remotePlayerID;
@property (nonatomic, retain) NSString *remotePlayerAlias;

//NetworkReceiverDelegate
@property (nonatomic, assign) id<NetworkReceiveDelegate> delegate;

//Other
@property (nonatomic, assign) GLView *glView;
@property (nonatomic, assign) bool menuAnimationBusy;
@property (nonatomic, assign) bool menuVisible;
@property (nonatomic, assign) bool animationPaused;
@property (nonatomic, assign) int currentToastID;

    //Resolution Multiplier
@property (nonatomic, assign) float resMultiplierX;
@property (nonatomic, assign) float resMultiplierY;

@property (nonatomic, strong) GADInterstitial *interstitial;

#pragma mark Methods

-(void) setupController;

-(void) initOpenGLView;

-(void) initAudio;

-(void) initUserInterface;

#pragma mark UI Events

-(IBAction)playerLike:(id)sender;

-(void) pauseGame;

-(void) captureScreen;

-(void) showAudio;

-(void) showOptions;

-(void) showLeaderboard;

-(void) showHelp;

-(void) showCredits;

#pragma mark GKMatch

-(void) connect;

-(void) registerInviteHandler;

-(void) sendAction:(int) action Argument: (int) arg PosX: (float) px PosY: (float) py Reliable: (bool) reliable;

-(void) gameKitMatchDisconnected;

#pragma mark Toast

-(void) showToast: (NSString *) text;

-(void) hideToastIdentifier: (NSNumber *) ident;

#pragma mark Like

-(void) showRemotePlayer: (NSString *) text;

-(void) hideRemotePlayer;

#pragma mark Menu

-(void) showMenu;

-(void) hideControlsMenu;

#pragma mark - Interstitial Methods

- (GADRequest *)request;
- (void)loadInterstitial;
- (void)showInterstitial;

@end
