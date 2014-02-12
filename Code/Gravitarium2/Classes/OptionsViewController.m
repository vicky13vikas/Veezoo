//
//  OptionsViewController.m
//  Gavitarium2
//
//  Created by Robert Neagu on 5/8/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import "OptionsViewController.h"

@implementation OptionsViewController

#pragma mark - Properties

@synthesize networkDelegate;
@synthesize modalDelegate;

@synthesize leftButton;
@synthesize rightButton;

@synthesize lblParticles;
@synthesize sldParticles;
@synthesize lblSize;
@synthesize sldSize;
@synthesize lblTail;
@synthesize sldTail;
@synthesize lblSpeed;
@synthesize sldSpeed;

@synthesize lblRed;
@synthesize sldRed;
@synthesize lblGreen;
@synthesize sldGreen;
@synthesize lblBlue;
@synthesize sldBlue;
@synthesize lblAlpha;
@synthesize sldAlpha;

@synthesize btnColor;
@synthesize btnPreventSleep;
@synthesize btnRepeat;

-(NSString *) title {
    return @"Options";
}

#pragma mark - Initialize

- (void)viewDidLoad{ 
    //Super
    [super viewDidLoad];
    
    //Right button
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //Left button
        self.leftButton = [[[UIBarButtonItem alloc] initWithTitle: @"Reset" style:UIBarButtonItemStylePlain target: self action:@selector(reset)] autorelease];
        self.navigationItem.leftBarButtonItem = self.leftButton;
        
        //Right button
        self.rightButton = [[[UIBarButtonItem alloc] initWithTitle: @"Close" style:UIBarButtonItemStylePlain target: self action:@selector(close)] autorelease];
        self.navigationItem.rightBarButtonItem = self.rightButton;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Left button
        self.leftButton = [[[UIBarButtonItem alloc] initWithTitle: @"Load" style:UIBarButtonItemStylePlain target: self action:@selector(showLoad)] autorelease];
        self.navigationItem.leftBarButtonItem = self.leftButton;
        
        //Right button
        self.rightButton = [[[UIBarButtonItem alloc] initWithTitle: @"Save" style:UIBarButtonItemStylePlain target: self action:@selector(showSave)] autorelease];
        self.navigationItem.rightBarButtonItem = self.rightButton;
    }
    
    //Update
    [self updateInterface];
}

-(void) viewWillAppear:(BOOL)animated {
    //Super
    [super viewWillAppear: animated];
    
    //Limit maximum particle count
    sldParticles.maximumValue = [[Options sharedOptions] isHighPerformanceSystem] ? 5000 : 3000;
}

-(void) viewWillDisappear:(BOOL)animated {
    //Super
    [super viewWillDisappear: animated];
    
    //Save
    [NSThread detachNewThreadSelector:@selector(saveOptions) toTarget:[Options sharedOptions] withObject:nil];
}

#pragma mark - Network Receive Delegate

-(void) receivedAction {
    //Update controls
    [self updateInterface];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex > 0) {
            //Load preset
            NSArray *files = [NSArray arrayWithObjects: @"", @"Default", @"Drawing", @"Tranquility", @"Custom", nil];
            [[Options sharedOptions] loadPreset: [files objectAtIndex: buttonIndex] Extension: @"plist"];
            
            //Save
            [NSThread detachNewThreadSelector:@selector(saveOptions) toTarget:[Options sharedOptions] withObject:nil];
            
            //Update all controls
            [self updateInterface];
            
            //Send to network
            [self sendOptionsToNetwork];
            
            //Drawing mode screen clear
            if (buttonIndex == 2) {
                //Assume modal delegate as parent
                GLViewController *parent = (GLViewController *) modalDelegate;
                
                //Clear screen
                [parent.glView clearScreen];
                
                //Set opacity
                parent.glView.currentOpacity = [Options sharedOptions].particleAlpha;
                
                //Network send
                [networkDelegate sendAction: G2_SCREEN_CLEAR Argument:0 PosX:[Options sharedOptions].particleAlpha PosY:0 Reliable:TRUE];
            }
        }
    } else if (alertView.tag == 2) {
        //Save current preset
        if (buttonIndex > 0)
            [[Options sharedOptions] saveCurrentPreset];
    }
}

#pragma mark - iPhone Events

-(void) reset {
    //Load default settings
    [[Options sharedOptions] loadPreset: @"Default" Extension: @"plist"];
    
    //Save
    [NSThread detachNewThreadSelector:@selector(saveOptions) toTarget:[Options sharedOptions] withObject:nil];
    
    //Update all controls
    [self updateInterface];
    
    //Send to network
    [self sendOptionsToNetwork];
}

-(void) close {
    //Dismiss window
    if (modalDelegate != nil && [modalDelegate respondsToSelector: @selector(closeModalWindow)])
        [modalDelegate closeModalWindow];
}

#pragma - iPad Events

-(void) showLoad {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil message:@"Tap the preset you want to load" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Default", @"Drawing", @"Tranquility", @"User", nil];
    alert.tag = 1;
    [alert show];
    [alert release];
}

-(void) showSave {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil message:@"Are your sure you want to overwrite the existing 'User' preset?" delegate: self cancelButtonTitle: @"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 2;
    [alert show];
    [alert release];
}

#pragma - Generic Events

- (IBAction)sliderChanged:(id)sender {
    if ([sender isEqual: sldParticles]) {
        [Options sharedOptions].particleCount = sldParticles.value;
    } else if ([sender isEqual: sldSize]) {
        [Options sharedOptions].particleSize = sldSize.value;
    } else if ([sender isEqual: sldTail]){ 
        [Options sharedOptions].particleTail = sldTail.value;
    } else if ([sender isEqual: sldSpeed]){
        [Options sharedOptions].particleSpeed = sldSpeed.value;
    } else if ([sender isEqual: sldRed]) {
        [Options sharedOptions].particleRed = sldRed.value;
        
        //Off
        btnColor.on = FALSE;
        [Options sharedOptions].particleColorCycle = FALSE;
    } else if ([sender isEqual: sldGreen]) {
        [Options sharedOptions].particleGreen = sldGreen.value;
        
        //Off
        btnColor.on = FALSE;
        [Options sharedOptions].particleColorCycle = FALSE;
    } else if ([sender isEqual: sldBlue]) {
        [Options sharedOptions].particleBlue = sldBlue.value;
        
        //Off
        btnColor.on = FALSE;
        [Options sharedOptions].particleColorCycle = FALSE;
    } else if ([sender isEqual: sldAlpha]){
        [Options sharedOptions].particleAlpha = sldAlpha.value;
    }  
    
    //Update labels
    [self updateLabels];
    
    //Send to network
    [self sendOptionsToNetwork];
}

- (IBAction)buttonChanged:(id)sender {
    if ([sender isEqual: btnColor]) {
        [Options sharedOptions].particleColorCycle = btnColor.on;
    } else if ([sender isEqual: btnPreventSleep]) {
        [Options sharedOptions].preventSleep = btnPreventSleep.on;
    } else if ([sender isEqual: btnRepeat]) {
        [Options sharedOptions].soundRepeat = btnRepeat.on;
    }
    
    //Send to network
    [self sendOptionsToNetwork];
}

#pragma mark - Methods

-(void) sendOptionsToNetwork {
    //Send packets
    [networkDelegate sendAction: G2_PART_COUNT Argument: [Options sharedOptions].particleCount PosX:0 PosY:0 Reliable:TRUE];
    [networkDelegate sendAction: G2_PART_SIZE Argument: 0 PosX: [Options sharedOptions].particleSize PosY:0 Reliable:TRUE];
    [networkDelegate sendAction: G2_PART_TAIL Argument: 0 PosX: [Options sharedOptions].particleTail PosY:0 Reliable:TRUE];
    [networkDelegate sendAction: G2_PART_SPEED Argument: 0 PosX: [Options sharedOptions].particleSpeed PosY:0 Reliable:TRUE];
    [networkDelegate sendAction: G2_COLOR_RED Argument: 0 PosX: [Options sharedOptions].particleRed PosY:0 Reliable:TRUE];
    [networkDelegate sendAction: G2_COLOR_GREEN Argument: 0 PosX: [Options sharedOptions].particleGreen PosY:0 Reliable:TRUE];
    [networkDelegate sendAction: G2_COLOR_BLUE Argument: 0 PosX: [Options sharedOptions].particleBlue PosY:0 Reliable:TRUE];
    [networkDelegate sendAction: G2_COLOR_ALPHA Argument: 0 PosX: [Options sharedOptions].particleAlpha PosY:0 Reliable:TRUE];
    [networkDelegate sendAction: G2_COLOR_CYCLE Argument: [Options sharedOptions].particleColorCycle ? 1:0 PosX:0 PosY:0 Reliable:TRUE]; 
    [networkDelegate sendAction: G2_REPEAT_TRACK Argument: [Options sharedOptions].soundRepeat ? 1:0 PosX:0 PosY:0 Reliable:TRUE];
    [networkDelegate sendAction: G2_PREVENT_SLEEP Argument: [Options sharedOptions].preventSleep ? 1:0 PosX:0 PosY:0 Reliable:TRUE];
}

-(void) updateInterface {
    [self updateLabels];
    [self updateControls];
}

-(void) updateLabels {
    lblParticles.text = [NSString stringWithFormat: @"%i", [Options sharedOptions].particleCount];
    lblSize.text = [NSString stringWithFormat: @"%.2f", [Options sharedOptions].particleSize];
    lblTail.text = [NSString stringWithFormat: @"%.2f", [Options sharedOptions].particleTail];
    lblSpeed.text = [NSString stringWithFormat: @"%.2f", [Options sharedOptions].particleSpeed];
    
    lblRed.text = [NSString stringWithFormat: @"%.2f", [Options sharedOptions].particleRed];
    lblGreen.text = [NSString stringWithFormat: @"%.2f", [Options sharedOptions].particleGreen];
    lblBlue.text = [NSString stringWithFormat: @"%.2f", [Options sharedOptions].particleBlue];
    lblAlpha.text = [NSString stringWithFormat: @"%.2f", [Options sharedOptions].particleAlpha];
}

-(void) updateControls {
    sldParticles.value = [Options sharedOptions].particleCount;
    sldSize.value = [Options sharedOptions].particleSize;
    sldTail.value = [Options sharedOptions].particleTail;
    sldSpeed.value = [Options sharedOptions].particleSpeed;
    
    sldRed.value = [Options sharedOptions].particleRed;
    sldGreen.value = [Options sharedOptions].particleGreen;
    sldBlue.value = [Options sharedOptions].particleBlue;
    sldAlpha.value = [Options sharedOptions].particleAlpha;
    
    btnColor.on = [Options sharedOptions].particleColorCycle;
    btnPreventSleep.on = [Options sharedOptions].preventSleep;
    btnRepeat.on = [Options sharedOptions].soundRepeat;
}

#pragma mark - OS Events

#pragma mark - Rotation

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


#pragma mark - Memory Management

- (void)dealloc {
    NSLog(@"[OptionsViewController dealloc]");
    
    //Releases
    [leftButton release];
    [rightButton release];
    
    [lblParticles release];
    [sldParticles release];
    [lblSize release];
    [sldSize release];
    [lblTail release];
    [sldTail release];
    [lblSpeed release];
    [sldSpeed release];

    [lblRed release];
    [sldRed release];
    [lblGreen release];
    [sldGreen release];
    [lblBlue release];
    [sldBlue release];
    [lblAlpha release];
    [sldAlpha release];
    
    [btnColor release];
    [btnPreventSleep release];
    [btnRepeat release];
    
    [super dealloc];
}

- (void)viewDidUnload{
    [self setLeftButton: nil];
    [self setRightButton: nil];
    
    [self setLblParticles:nil];
    [self setSldParticles:nil];
    [self setLblSize:nil];
    [self setSldSize:nil];
    [self setLblTail:nil];
    [self setSldTail:nil];
    [self setLblSpeed:nil];
    [self setSldSpeed:nil];

    [self setLblRed:nil];
    [self setSldRed:nil];
    [self setLblGreen:nil];
    [self setSldGreen:nil];
    [self setLblBlue:nil];
    [self setSldBlue:nil];
    [self setLblAlpha:nil];
    [self setSldAlpha:nil];

    [self setBtnColor:nil];
    [self setBtnPreventSleep:nil];
    [self setBtnRepeat:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end