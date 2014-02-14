//
//  GLViewController.m
//  Gravitarium2
//
//  Created by Robert Neagu on 11/3/10.
//  Copyright 2010 TotalSoft. All rights reserved.
//

#import "GLViewController.h"
#import "PromoViewController.h"

@implementation GLViewController

#pragma mark - Constants

#define ALERT_VIEW_PLAYER 1
#define ALERT_VIEW_CONNECT 2
#define ALERT_VIEW_HELP 3
#define ALERT_VIEW_GAMECENTER 4

#pragma mark - Structs

typedef struct {
    int action;
    int argument;
    float posX;
    float posY;
} NetworkPackage;

#pragma mark - Properties

@synthesize delegate;

@synthesize controlsViewController;
@synthesize popoverController;

@synthesize viewToast;
@synthesize lblToast;
@synthesize lblPlayer;
@synthesize btnPlayer;
@synthesize viewPlayer;

@synthesize myMatch;
@synthesize matchStarted;
@synthesize remotePlayerID;
@synthesize remotePlayerAlias;

@synthesize glView;
@synthesize menuAnimationBusy;
@synthesize menuVisible;
@synthesize animationPaused;
@synthesize currentToastID;

@synthesize resMultiplierX;
@synthesize resMultiplierY;

@synthesize interstitial;

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self)
        [self setupController];
	return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self)
        [self setupController];
    return self;
}

-(void) setupController {
    //Observe system notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    //Init shared options
    [Options sharedOptions];
    
    //Init OpenGL view
    [self initOpenGLView];
    
    //Init audio engine
    [self initAudio];
    
    //Init user interface
    [self initUserInterface];
}

- (void) viewDidLoad {
	//Debug
	NSLog(@"[GLViewController viewDidLoad]");
    
    [[AVAudio sharedAudio] setDelegate: self];
    [self loadInterstitial];
    isFromViewDidLoad = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self ShowBannerAD];
    
    if (!isFromViewDidLoad)
    {
        [self performSelector:@selector(loadInterstitial)
                   withObject:nil
                   afterDelay:60];
    }
    else
        isFromViewDidLoad = NO;
}

#pragma mark - Interstitial Methods

- (void)loadInterstitial
{
    if (self.interstitial)
    {
        [self.interstitial setDelegate:nil];
        [self.interstitial release];
        self.interstitial = nil;
        NSLog(@"%s self.interstitial = %@", __FUNCTION__, self.interstitial);
    }

    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.delegate = self;
    self.interstitial.adUnitID = @"ca-app-pub-5402296631424108/1054619671";
    [self.interstitial loadRequest:[self request]];
}

- (GADRequest *)request
{
    GADRequest *request = [GADRequest request];
    request.testDevices = @[GAD_SIMULATOR_ID];
    return request;
}

- (void)showInterstitial
{
    [self.interstitial presentFromRootViewController:self];
}

#pragma mark Ad Request Lifecycle Notifications

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [self showInterstitial];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self loadInterstitial];
}

#pragma mark Display-Time Lifecycle Notifications

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
}

#pragma mark - End Interstitial Methods

-(void)ShowBannerAD
{
/*
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad unit ID.
    bannerView_.adUnitID =@"ca-app-pub-5402296631424108/1054619671";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
*/
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    bool initialHelp = [[NSUserDefaults standardUserDefaults] boolForKey: @"initialHelp"];
    if (initialHelp == FALSE) {
        //Show alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to Veezoo!" message: @"To access the application menu just tap any screen corner." delegate:self cancelButtonTitle: @"Dismiss" otherButtonTitles: @"Help", nil];
        alert.tag = ALERT_VIEW_HELP;
        [alert show];
        [alert release];
        
        //Remember flag
        [[NSUserDefaults standardUserDefaults] setBool: TRUE forKey: @"initialHelp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void) initOpenGLView {
    //Get view pointer
    self.glView = (GLView *) self.view;
    
    //Initialize view objects
    [glView initializeObjects: self];
}

-(void) initAudio {
    //Initialize audio engine
    [AVAudio sharedAudio];
    
    //Audio delegate
    [AVAudio sharedAudio].delegate = self;
    
    //Audio volume
    [[AVAudio sharedAudio] setGeneralVolume: [Options sharedOptions].soundMuted ? 0 : 1];
    
    //Auto-play soundtrack
    if ([Options sharedOptions].soundPlaying)
        [[AVAudio sharedAudio] playMusicKey: [Options sharedOptions].soundKey];
}

-(void) initUserInterface {
    //Flags
    menuAnimationBusy = FALSE;
    menuVisible = FALSE;
    animationPaused = FALSE;
    
    //Other
    resMultiplierX = 1;
    resMultiplierY = 1;
    
    //Initialize options view controller
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        controlsViewController = [[ControlsViewController alloc] initWithNibName: @"ControlsViewController" bundle: nil];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        controlsViewController = [[ControlsViewController alloc] initWithNibName: @"ControlsViewController-iPad" bundle: nil];        
    }
    controlsViewController.parent = self;
    controlsViewController.view.hidden = TRUE;
    [self.view addSubview: controlsViewController.view];
    
    //Hide view off screen
    [self hideControlsMenu];
}

#pragma mark - UI Events

- (IBAction)playerLike:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil message: [NSString stringWithFormat: @"Please choose your action for %@", self.remotePlayerAlias] delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Send like", @"Send friend request", nil];
    alert.tag = ALERT_VIEW_PLAYER;
    [alert show];
    [alert release];
}

-(void) pauseGame {
    //Toogle pause
    animationPaused = !animationPaused;
    
    //Network send
    if (matchStarted) {
        if (animationPaused)
            [self sendAction: G2_PAUSE Argument:0 PosX:0 PosY:0 Reliable: TRUE];
        else
            [self sendAction: G2_RESUME Argument:0 PosX:0 PosY:0 Reliable: TRUE];
    }
}

-(void) captureScreen {
    //Capture image to PhotoLibrary
    [glView captureOpenGLImage];
    
    //Network send
    if (matchStarted)
        [self sendAction: G2_SCREEN_SHOT Argument: 0 PosX:0 PosY:0 Reliable: TRUE];
}

-(void) showAudio {    
    //Create controller
    AudioViewController *audioViewController = [[[AudioViewController alloc] initWithNibName: @"AudioViewController" bundle: nil] autorelease];
    audioViewController.networkDelegate = self;
    audioViewController.modalDelegate = self;
    self.delegate = audioViewController;
    
    //Create navigation controller
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController: audioViewController] autorelease];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //Stop animation
        [self.glView stopAnimation];
        
        //Black navigation
        navController.navigationBar.barStyle = UIBarStyleBlack;
        
        //Show modal controller
        [self presentModalViewController: navController animated: TRUE];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Launch point
        CGRect launchPoint = CGRectMake(controlsViewController.btnAudio.frame.origin.x, controlsViewController.view.frame.origin.y + controlsViewController.btnAudio.frame.origin.y, 90, 90);
        
        //Show popover
        self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        popoverController.popoverContentSize = CGSizeMake(400, 480);
        [popoverController presentPopoverFromRect: launchPoint inView: glView permittedArrowDirections: UIPopoverArrowDirectionAny animated: TRUE];
    }
}

-(void) showOptions {
    //Create controller
    OptionsViewController *optionsViewController = [[[OptionsViewController alloc] initWithNibName: @"OptionsViewController" bundle: nil] autorelease];
    optionsViewController.networkDelegate = self;
    optionsViewController.modalDelegate = self;
    self.delegate = optionsViewController;
    
    //Create navigation controller
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController: optionsViewController] autorelease];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //Stop animation
        [self.glView stopAnimation];
        
        //Black navigation
        navController.navigationBar.barStyle = UIBarStyleBlack;
        
        //Show modal controller
        [self presentModalViewController: navController animated: TRUE];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Launch point
        CGRect launchPoint = CGRectMake(controlsViewController.btnOptions.frame.origin.x, controlsViewController.view.frame.origin.y + controlsViewController.btnOptions.frame.origin.y, 90, 90);
        
        //Show popover
        self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        popoverController.popoverContentSize = CGSizeMake(480, 320);
        [popoverController presentPopoverFromRect: launchPoint inView: glView permittedArrowDirections: UIPopoverArrowDirectionAny animated: TRUE];
    }
}

-(void) showLeaderboard {
    //Verify GameCenter available
    if ([[GameKitLibrary sharedGameKit] isGameCenterAvailable] == FALSE) {
        //Show alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"GameCenter is not supported in your version of iOS!\r\nPlease update your operating system and try again!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_GAMECENTER;
        [alertView show];
        [alertView release];
        
        //Return
        return;
    }
    
    //Show leadeboard
    [[GameKitLibrary sharedGameKit] showLeaderboardOver: self Category:1 Timescope:2];
}

-(void) showHelp {
    //Create controller
    HelpViewController *helpController = [[[HelpViewController alloc] initWithNibName: @"HelpViewController" bundle: nil] autorelease];
    helpController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    helpController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    //Present controller
    [self presentModalViewController: helpController animated: TRUE];
}

-(void) showCredits {
    //Create controller
    CreditsViewController *creditsController = [[[CreditsViewController alloc] initWithNibName: @"CreditsViewController" bundle: nil] autorelease];
    
    //Create navigation controller
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController: creditsController] autorelease];
    
    //Launch point
    CGRect launchPoint = CGRectMake(controlsViewController.btnCredits.frame.origin.x, controlsViewController.view.frame.origin.y + controlsViewController.btnCredits.frame.origin.y, 90, 90);
    
    //Show popover
    self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    popoverController.popoverContentSize = CGSizeMake(500, 490);
    [popoverController presentPopoverFromRect: launchPoint inView: glView permittedArrowDirections: UIPopoverArrowDirectionAny animated: TRUE];
}

#pragma mark - Remote Player

-(void) showRemotePlayer: (NSString *) text {
    //Alter views
    lblPlayer.text = text;
    viewPlayer.hidden = FALSE;
    
    //Position
    CGRect frameIntial = viewPlayer.frame;
    frameIntial.origin.y = -1 * viewPlayer.frame.size.height;
    viewPlayer.frame = frameIntial;
    
    //Animation
    [UIView beginAnimations: @"" context:nil];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationDelegate: self];
    
    //Alpha
    viewPlayer.alpha = 1;
    
    //Position
    CGRect frameFinal = viewPlayer.frame;
    frameFinal.origin.y = 0;
    viewPlayer.frame = frameFinal;
    
    //Commit animations
    [UIView commitAnimations];
}

-(void) hideRemotePlayer {
    //Animation
    [UIView beginAnimations: @"" context:nil];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(hideRemotePlayerFinished)];
    
    //Alpha
    viewPlayer.alpha = 0;
    
    //Commit animations
    [UIView commitAnimations];
}

-(void) hideRemotePlayerFinished {
    //Alter views
    lblPlayer.text = nil;
    viewPlayer.hidden = TRUE;
}

#pragma mark - Toast

-(void) showToast: (NSString *) text {
    //Alter views
    lblToast.text = text;
    viewToast.hidden = FALSE;
    
    //Animation
    [UIView beginAnimations: @"" context:nil];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(showToastFinished)];
    
    //Position
    CGRect frame = viewToast.frame;
    frame.origin.y = 0;
    viewToast.frame = frame;
    
    //Commit animations
    [UIView commitAnimations];
}

-(void) showToastFinished {
    //Identifier
    currentToastID++;
    
    //Schedule toast hide
    [self performSelector: @selector(hideToastIdentifier:) withObject: [NSNumber numberWithInt: currentToastID]
               afterDelay: 3.0];
    
}

-(void) hideToastIdentifier: (NSNumber *) ident {
    //Check if latest toast
    if ([ident intValue] == currentToastID) {
        //Animation
        [UIView beginAnimations: @"" context:nil];
        [UIView setAnimationDuration: 0.3];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(hideToastFinished)];
        
        //Position
        CGRect frame = viewToast.frame;
        frame.origin.y = -frame.size.height;
        viewToast.frame = frame;
        
        //Commit animations
        [UIView commitAnimations];
    }
}

-(void) hideToastFinished {
    //Hide toast
    viewToast.hidden = TRUE;
}

#pragma mark - Menu

-(void) showMenu {
    //Flag
    if (menuAnimationBusy)
        return;
    menuAnimationBusy = TRUE;
    
    //Visible
    controlsViewController.view.hidden = FALSE;
    
    //Animation
    [UIView beginAnimations: @"" context:nil];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(showMenuFinished)];
    
    //Position
    CGRect controlsFrame = controlsViewController.view.frame;
    controlsFrame.origin.x = 0;
    controlsFrame.origin.y = self.view.bounds.size.height - controlsViewController.view.bounds.size.height;
    controlsFrame.size.width = self.view.bounds.size.width;
    controlsViewController.view.frame = controlsFrame;
    
    //Opacity
    controlsViewController.view.alpha = 1.0;
    
    //Commit animations
    [UIView commitAnimations];
}

-(void) showMenuFinished {
    //Flag
    menuAnimationBusy = FALSE;
    
    //Animation ended
    menuVisible = TRUE;
}

-(void) hideControlsMenu {
    //Flag
    if (menuAnimationBusy)
        return;
    menuAnimationBusy = TRUE;    
    
    //Animation
    [UIView beginAnimations: @"" context:nil];
    [UIView setAnimationDuration: 0.3];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(hideMenuFinished)];
    
    //Position
    CGRect controlsFrame = controlsViewController.view.frame;
    controlsFrame.origin.x = 0;
    controlsFrame.origin.y =  self.view.bounds.size.height;
    controlsFrame.size.width = self.view.bounds.size.width;
    controlsViewController.view.frame = controlsFrame;
    
    //Opacity
    controlsViewController.view.alpha = 0.0;
    
    //Commit animations
    [UIView commitAnimations];
}

-(void) hideMenuFinished {
    //Flag
    menuAnimationBusy = FALSE;
    
    //Animation ended
    menuVisible = FALSE;
    
    //Hidden
    controlsViewController.view.hidden = TRUE;
}

#pragma mark - MusicPlayerDelegate

-(void) playbackStartedForMusicKey: (NSString *) key {
    //Toast
    [self showToast: [NSString stringWithFormat: @"Now playing '%@'...", key]];
    
    //Send to delegate
    if (delegate != nil)
        [delegate receivedAction];
}

-(void) playbackStoppedForMusicKey: (NSString *) key {
    //Toast
    [self showToast: @"Soundtrack stopped..."];
    
    //Send to delegate
    if (delegate != nil)
        [delegate receivedAction];
}

-(void) playbackFinishedForMusicKey: (NSString *) key {
    if ([Options sharedOptions].soundPlaying) {
        if ([Options sharedOptions].soundRepeat) {
            //Play the current track again
            [[AVAudio sharedAudio] playMusicKey: [Options sharedOptions].soundKey];
        } else {
            //Pick next track
            bool pickNext = FALSE;
            for (NSString *track in [AVAudio sharedAudio].music) {
                if (pickNext) {
                    [Options sharedOptions].soundKey = track;
                    pickNext = FALSE;
                    break;
                }
                if ([track isEqualToString: key])
                    pickNext = TRUE;
            }
            
            //Repeat playlist
            if (pickNext)
                [Options sharedOptions].soundKey = [[AVAudio sharedAudio].music objectAtIndex: 0];
            
            //Play current track
            [[AVAudio sharedAudio] playMusicKey: [Options sharedOptions].soundKey];
        }
        
        //Save options
        [NSThread detachNewThreadSelector:@selector(saveOptions) toTarget:[Options sharedOptions] withObject:nil];
    }
}

#pragma mark - AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_VIEW_PLAYER) {
        //Player infobox
        if (buttonIndex == 1) {
            //Toast
            [self showToast: [NSString stringWithFormat: @"You like %@'s Gravitarium!", self.remotePlayerAlias]];
            
            //Network send
            [self sendAction: G2_LIKE Argument: 0 PosX:0 PosY:0 Reliable: TRUE];
        } else if (buttonIndex == 2) {
            //Send friend request
            GKFriendRequestComposeViewController *friendRequestViewController = [[GKFriendRequestComposeViewController alloc] init];
            friendRequestViewController.composeViewDelegate = self;
            [friendRequestViewController addRecipientsWithPlayerIDs: [NSArray arrayWithObject: self.remotePlayerID]];
            [self presentModalViewController: friendRequestViewController animated: YES];
            [friendRequestViewController release];
        }
    } else if (alertView.tag == ALERT_VIEW_CONNECT) {
        //Connect or Disconnect
        if (buttonIndex == 1) {
            //Disconnect match
            [myMatch disconnect];
            [self gameKitMatchDisconnected];
        }
    } else if (alertView.tag == ALERT_VIEW_HELP) {
        //Initial help
        if (buttonIndex == 1)
            [self showHelp];
    }
}

#pragma mark - ModalDelegate

-(void) closeModalWindow {
    //Clean current delegate
    self.delegate = nil;
    
    //Dismiss modal window
    [self dismissModalViewControllerAnimated: TRUE];
    
    //Resume animation
    [self.glView performSelector: @selector(startAnimation) withObject: nil afterDelay: 1];
}

#pragma mark - GKMatchmaker

-(void) connect {
    //Verify GameCenter available
    if ([[GameKitLibrary sharedGameKit] isGameCenterAvailable] == FALSE) {
        //Show alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"GameCenter is not supported in your version of iOS!\r\nPlease update your operating system and try again!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        alertView.tag = ALERT_VIEW_GAMECENTER;
        [alertView show];
        [alertView release];
        
        return;
    }
    
    //Verify already connected
    if (matchStarted) {
        //Ask to disconnect
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to disconnect?" delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
        alertView.tag = ALERT_VIEW_CONNECT;
        [alertView show];
        [alertView release];
    } else {
        //Create match request
        GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
        request.minPlayers = 2;
        request.maxPlayers = 2;
        
        //Create view controller
        GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
        mmvc.matchmakerDelegate = self;
        [self presentModalViewController:mmvc animated:YES];
    }
}

#pragma mark - GKInviteHandler

-(void) registerInviteHandler {
    if ([[GameKitLibrary sharedGameKit] isGameCenterAvailable] == FALSE) 
        return;
    
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        if (acceptedInvite){
            GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite] autorelease];
            mmvc.matchmakerDelegate = self;
            [self presentModalViewController:mmvc animated:YES];
        } else if (playersToInvite) {
            GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
            request.minPlayers = 2;
            request.maxPlayers = 2;
            request.playersToInvite = playersToInvite;
            
            GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
            mmvc.matchmakerDelegate = self;
            [self presentModalViewController:mmvc animated:YES];
        }
    };
}

#pragma mark - GKLeaderboardViewControllerDelegate

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [self dismissModalViewControllerAnimated: YES];
}

#pragma mark - GKFriendRequestComposeViewControllerDelegate

- (void)friendRequestComposeViewControllerDidFinish:(GKFriendRequestComposeViewController *)viewController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - GKMatchmakerViewControllerDelegate

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    //Dismiss modal window
    [self dismissModalViewControllerAnimated:YES];
    
    //Flag
    matchStarted = FALSE;
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    //Dismiss modal window
    [self dismissModalViewControllerAnimated:YES];
    
    //Flag
    matchStarted = FALSE;
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *) match {    
    //Dismiss window
    [self dismissModalViewControllerAnimated:YES];
    
    //Retain match
    self.myMatch = match; 
    
    //Delegate
    myMatch.delegate = self;
    
    //Retreive player name
    [GKPlayer loadPlayersForIdentifiers: myMatch.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        for (GKPlayer *player in players) {
            if (![[[GameKitLibrary sharedGameKit] localPlayedID] isEqualToString: player.playerID]) {
                //Player
                self.remotePlayerAlias = player.alias;
                self.remotePlayerID = player.playerID;
                
                //Toast
                [self showToast: [NSString stringWithFormat: @"Connected with '%@'...", self.remotePlayerAlias]];
                
                //InfoBox
                [self showRemotePlayer: self.remotePlayerAlias];
                
                //Network send
                [self sendAction: G2_RESOLUTION Argument: 0 PosX: self.glView.realScreenWidth PosY: self.glView.realScreenHeight Reliable: TRUE];
            }
        }
    }];
    
    //Flag
    matchStarted = TRUE;
    
    //Reset current color
    glView.currentColor = 0;
    
    //Load default settings
    [[Options sharedOptions] loadPreset: @"Default" Extension: @"plist"];
    
    //Auto hide the controls menu
    if (menuVisible)
        [self hideControlsMenu];
}

#pragma mark - GameKitLibraryMatchDelegate

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    //Show remote player
    if (state == GKPlayerStateConnected) {        
        //Retreive player name
        [GKPlayer loadPlayersForIdentifiers: [NSArray arrayWithObject: playerID] withCompletionHandler:^(NSArray *players, NSError *error) {
            for (GKPlayer *player in players) {
                if (![[[GameKitLibrary sharedGameKit] localPlayedID] isEqualToString: player.playerID]) {
                    //Player
                    self.remotePlayerAlias = player.alias;
                    self.remotePlayerID = player.playerID;
                    
                    //Toast
                    [self showToast: [NSString stringWithFormat: @"Connected with '%@'...", self.remotePlayerAlias]];
                    
                    //InfoBox
                    [self showRemotePlayer: self.remotePlayerAlias];
                
                    //Network send
                    [self sendAction: G2_RESOLUTION Argument: 0 PosX: self.glView.realScreenWidth PosY: self.glView.realScreenHeight Reliable: TRUE];
                }
            }
        }];
    } else if (state == GKPlayerStateDisconnected) {
        [self gameKitMatchDisconnected];
    }
}

- (void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {    
    [self gameKitMatchDisconnected];
}

- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
    [self gameKitMatchDisconnected];
}

-(void) gameKitMatchDisconnected {
    //Player
    self.remotePlayerAlias = nil;
    self.remotePlayerID = nil;

    //Cleanup remote touches
    [glView.remoteViewTouches removeAllObjects];
    
    //Toast
    [self showToast: @"Disconnected..."];
    
    //InfoBox
    [self hideRemotePlayer];
    
    //Flag
    matchStarted = FALSE;
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    //Read package
    NetworkPackage *networkPackagePointer = (NetworkPackage*)[data bytes];
    NetworkPackage networkPackage = *networkPackagePointer;
    
    //Route package
    if (networkPackage.action == G2_TOUCH_ADD) {
        //Apply multiplier
        float rX = networkPackage.posX / resMultiplierX;
        float rY = networkPackage.posY / resMultiplierY;
        
        //Add external touch
        ViewTouch *newTouch = [[ViewTouch alloc] initWithTouchID: networkPackage.argument CoordX: rX CoordY: rY];
        [glView.remoteViewTouches insertObject: newTouch atIndex: [glView.remoteViewTouches count]];
        [newTouch release]; 
    } else if (networkPackage.action == G2_TOUCH_MOVE) {
        //Apply multiplier
        float rX = networkPackage.posX / resMultiplierX;
        float rY = networkPackage.posY / resMultiplierY;
        
        //Move external touch
		for (int i=0; i<[glView.remoteViewTouches count]; i++) {
			ViewTouch *t = [glView.remoteViewTouches objectAtIndex: i];
			if (t.touchID == networkPackage.argument) 
				[t addCoordX: rX CoordY:rY];
		}
    } else if (networkPackage.action == G2_TOUCH_DELETE) {
        //Remove external touch
		for (int i=0; i<[glView.remoteViewTouches count]; i++) {
			ViewTouch *t = [glView.remoteViewTouches objectAtIndex: i];
			if (t.touchID == networkPackage.argument) 
				[t endCoords];
		}
    } else if (networkPackage.action == G2_LIKE) {
        //Key
        NSString *key = [NSString stringWithFormat: @"VoteForPlayerID=%@", self.remotePlayerID];
        
        //Check if user voted you before
        bool userVoted = [[NSUserDefaults standardUserDefaults] boolForKey: key];
        if (userVoted == FALSE) {
            //Likes
            int currentScore = [[GameKitLibrary sharedGameKit] getBestScoreForCategory: 0];
            currentScore++;
            
            //Save new like score
            [[GameKitLibrary sharedGameKit] removeScoresForCategory: 0];
            [[GameKitLibrary sharedGameKit] addNewScore:currentScore Category:0 Sync: TRUE];
            [[GameKitLibrary sharedGameKit] saveAll];
        
            //Remember that user voted
            [[NSUserDefaults standardUserDefaults] setBool: TRUE forKey: key];
        }
        
        //Toast
        [self showToast: [NSString stringWithFormat: @"%@ likes your Gravitarium!", self.remotePlayerAlias]];
    } else if (networkPackage.action == G2_COLOR_SYNC) {
        //Sync color
        glView.currentColor = networkPackage.argument;
    } else if (networkPackage.action == G2_PAUSE) {
        //Toast
        [self showToast: [NSString stringWithFormat: @"%@ paused Gravitarium!", self. remotePlayerAlias]];
    } else if (networkPackage.action == G2_RESUME) {
        //Toast
        [self showToast: [NSString stringWithFormat: @"%@ resumed Gravitarium!", self. remotePlayerAlias]];
    } else if (networkPackage.action == G2_PLAY_TRACK) {
        //Sound key
        [Options sharedOptions].soundKey = [[AVAudio sharedAudio].music objectAtIndex: networkPackage.argument];
        
        //Sound active
        [Options sharedOptions].soundPlaying = TRUE;
        
        //Play music
        [[AVAudio sharedAudio] playMusicKey: [Options sharedOptions].soundKey];
    } else if (networkPackage.action == G2_STOP_TRACK) {
        //Sound not active
        [Options sharedOptions].soundPlaying = FALSE;
    
        //Stop music
        [[AVAudio sharedAudio] stopMusic];
    } else if (networkPackage.action == G2_PART_COUNT) {
        [Options sharedOptions].particleCount = networkPackage.argument;
    } else if (networkPackage.action == G2_PART_SIZE) {
        [Options sharedOptions].particleSize = networkPackage.posX;
    } else if (networkPackage.action == G2_PART_TAIL) {
        [Options sharedOptions].particleTail = networkPackage.posX;
    } else if (networkPackage.action == G2_PART_SPEED) {
        [Options sharedOptions].particleSpeed = networkPackage.posX;
    } else if (networkPackage.action == G2_COLOR_RED) {
        [Options sharedOptions].particleRed = networkPackage.posX;
    } else if (networkPackage.action == G2_COLOR_GREEN) {
        [Options sharedOptions].particleGreen = networkPackage.posX;
    } else if (networkPackage.action == G2_COLOR_BLUE) {
        [Options sharedOptions].particleBlue = networkPackage.posX;
    } else if (networkPackage.action == G2_COLOR_ALPHA) {
        [Options sharedOptions].particleAlpha = networkPackage.posX;
    } else if (networkPackage.action == G2_COLOR_CYCLE) {
        [Options sharedOptions].particleColorCycle = networkPackage.argument == 1;
    } else if (networkPackage.action == G2_REPEAT_TRACK) {
        [Options sharedOptions].soundRepeat = networkPackage.argument == 1;
    } else if (networkPackage.action == G2_PREVENT_SLEEP) {
        [Options sharedOptions].preventSleep = networkPackage.argument == 1;
    } else if (networkPackage.action == G2_SCREEN_SHOT) {
        //Toast
        [self showToast: [NSString stringWithFormat: @"%@ captured a screenshot of your Gravitarium!", self. remotePlayerAlias]]; 
    } else if (networkPackage.action == G2_SCREEN_CLEAR) {
        //Clear screen
        [glView clearScreen];
        
        //Set new opacity
        glView.currentOpacity = networkPackage.posX;
    } else if (networkPackage.action == G2_RESOLUTION) {
        //Calculate multipliers
        resMultiplierX = networkPackage.posX / self.glView.realScreenWidth;
        resMultiplierY = networkPackage.posY / self.glView.realScreenHeight;
        
        //Debug
        NSLog(@"=================== RESOLUTION RATIO ==================");
        NSLog(@"Remote Resolution: %.0fx%.0f", networkPackage.posX, networkPackage.posY);
        NSLog(@"Local Resolution: %.0fx%.0f", self.glView.realScreenWidth, self.glView.realScreenHeight);
        NSLog(@"Remote/Local Ratio: %.2fx%.2f", resMultiplierX, resMultiplierY);
        NSLog(@"=================== RESOLUTION RATIO ==================");
    }
    
    //Notify the delegate about this external change (besides frequent updates)
    if (delegate != nil && [delegate respondsToSelector: @selector(receivedAction)] && networkPackage.action >= G2_PAUSE)
        [delegate receivedAction];
}

-(void) sendAction:(int) action Argument: (int) arg PosX: (float) px PosY: (float) py Reliable: (bool) reliable {
    //Error
    NSError *error;
    
    //Create package
    NetworkPackage networkPackage;
    networkPackage.action = action;
    networkPackage.argument = arg;
    networkPackage.posX = px;
    networkPackage.posY = py;
    
    //Send package
    NSData *packet = [NSData dataWithBytes:&networkPackage length:sizeof(NetworkPackage)];
    [myMatch sendDataToAllPlayers: packet withDataMode: reliable ? GKMatchSendDataReliable : GKMatchSendDataUnreliable error:&error];
}


#pragma mark - OS Events

-(void) didBecomeActive:(NSNotification *)notification {
    //Start animation
    [glView startAnimation];
}

-(void) willResignActive:(NSNotification *)notification {
    //Stop animation
    [glView stopAnimation];
}

#pragma mark - Rotation

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Memory management

-(void)dealloc {
	//Debug
	NSLog(@"[GLViewController dealloc]");
    
	//No longer observe system notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Release objects
    [controlsViewController release];
    [popoverController release];

    //Release toast
    [viewToast release];
    [lblToast release];
    
    //Release infobox
    [lblPlayer release];
    [btnPlayer release];
    [viewPlayer release];
    
    //Release match
    [myMatch release];
    
    //Release other
    [glView release];

    if (self.interstitial)
    {
        [self.interstitial setDelegate:nil];
        [self.interstitial release];
        self.interstitial = nil;
    }
    
	//Super
    [super dealloc];
}

- (void)viewDidUnload {
	//Debug
	NSLog(@"[GLViewController viewDidUnload]");
    
    [self setViewToast:nil];
    [self setLblToast:nil];
    
    [self setLblPlayer:nil];
    [self setBtnPlayer:nil];
    [self setViewPlayer:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)didReceiveMemoryWarning {
	//Debug
	NSLog(@"[GLViewController didReceiveMemoryWarning]");
    
    //Stop music
    [[AVAudio sharedAudio] stopMusic];
    
	//Super
    [super didReceiveMemoryWarning];
}

@end