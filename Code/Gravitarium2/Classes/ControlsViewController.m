//
//  ControlsViewController.m
//  Gavitarium2
//
//  Created by Robert Neagu on 5/10/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import "ControlsViewController.h"

@implementation ControlsViewController

#pragma mark - Properties

@synthesize parent;

@synthesize btnPause;
@synthesize btnPhoto;
@synthesize btnAudio;
@synthesize btnOptions;
@synthesize btnHelp;
@synthesize btnLeaderboard;
@synthesize btnConnect;
@synthesize btnCredits;

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - OS Events

#pragma mark - Rotation

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - UI Events

- (IBAction)pause:(id)sender {    
    //Parent
    [parent pauseGame];
    
    //Change image
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [btnPause setImage: [UIImage imageNamed: parent.animationPaused ? @"resumeNormalPhone.png" : @"pauseNormalPhone.png"] forState: UIControlStateNormal];
        [btnPause setImage: [UIImage imageNamed: parent.animationPaused ? @"resumePressedPhone.png" : @"pausePressedPhone.png"] forState: UIControlStateHighlighted];   
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [btnPause setImage: [UIImage imageNamed: parent.animationPaused ? @"resumeNormal.png" : @"pauseNormal.png"] forState: UIControlStateNormal];
        [btnPause setImage: [UIImage imageNamed: parent.animationPaused ? @"resumePressed.png" : @"pausePressed.png"] forState: UIControlStateHighlighted];          
    }
    
    //Sound
    [[AVAudio sharedAudio] playSound: @"touch"];
}

- (IBAction)photo:(id)sender {    
    //Parent
    [parent captureScreen];
    
    //Sound
    [[AVAudio sharedAudio] playSound: @"camera"];
}

- (IBAction)sound:(id)sender {
    //Parent
    [parent showAudio];
    
    //Sound
    [[AVAudio sharedAudio] playSound: @"touch"];
}

- (IBAction)options:(id)sender {
    //Parent
    [parent showOptions];
    
    //Sound
    [[AVAudio sharedAudio] playSound: @"touch"];
}

- (IBAction)connect:(id)sender {
    //Parent
    [parent connect];
    
    //Sound
    [[AVAudio sharedAudio] playSound: @"touch"];
}

- (IBAction)leaderboard:(id)sender {
    //Parent
    [parent showLeaderboard];
    
    //Sound
    [[AVAudio sharedAudio] playSound: @"touch"];
}

- (IBAction)help:(id)sender {
    //Parent
    [parent showHelp];
    
    //Sound
    [[AVAudio sharedAudio] playSound: @"touch"];
}

- (IBAction)credits:(id)sender {
    //Parent
    [parent showCredits];
    
    //Sound
    [[AVAudio sharedAudio] playSound: @"touch"];
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload{
    [self setBtnPhoto:nil];
    [self setBtnPause:nil];
    [self setBtnAudio:nil];
    [self setBtnOptions:nil];
    [self setBtnConnect:nil];
    [self setBtnLeaderboard:nil];
    [self setBtnHelp:nil];
    [self setBtnCredits:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc{
    [btnPhoto release];
    [btnPause release];
    [btnAudio release];
    [btnOptions release];
    [btnConnect release];
    [btnLeaderboard release];
    [btnHelp release];
    [btnCredits release];
    [super dealloc];
}

@end
