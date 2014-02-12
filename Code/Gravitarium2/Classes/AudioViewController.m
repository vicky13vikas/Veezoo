//
//  AudioViewController.m
//  Gavitarium2
//
//  Created by Robert Neagu on 5/20/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import "AudioViewController.h"

@implementation AudioViewController

#pragma mark Properties

@synthesize networkDelegate;
@synthesize modalDelegate;

@synthesize theTable;
@synthesize leftButton;
@synthesize rightButton;

-(NSString *) title {
    return @"Audio";
}

#pragma mark - Initialize

-(void) viewDidLoad {
    //Super
    [super viewDidLoad];
    
    //Left button
    self.leftButton = [[[UIBarButtonItem alloc] initWithTitle: @"Play" style:UIBarButtonItemStylePlain target: self action:@selector(playAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = self.leftButton;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //Right button
        self.rightButton = [[[UIBarButtonItem alloc] initWithTitle: @"Close" style:UIBarButtonItemStylePlain target: self action:@selector(closeAction:)] autorelease];
        self.navigationItem.rightBarButtonItem = self.rightButton;   
        
        //Flash scrollers (DELAYED)
        [theTable performSelector: @selector(flashScrollIndicators) withObject:nil afterDelay:0.5];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Right button
        self.rightButton = [[[UIBarButtonItem alloc] initWithTitle: @"Mute" style:UIBarButtonItemStylePlain target: self action:@selector(muteAction:)] autorelease];
        self.navigationItem.rightBarButtonItem = self.rightButton;
    }
    
    //Update interface
    [self updateInterface];
}

#pragma mark - OS Events

#pragma mark - Rotation

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - NetworkReceiveDelegate

-(void) receivedAction {
    //Update interface
    [self updateInterface];
}

#pragma mark - UI Actions

- (void)playAction:(id)sender {
    //Toogle playback state
    if ([Options sharedOptions].soundPlaying)
        [self stopCurrentSound];
    else
        [self playCurrentSound];
    
    //Update interface
    [self updateInterface];
    
    //Save options
    [NSThread detachNewThreadSelector:@selector(saveOptions) toTarget: [Options sharedOptions] withObject:nil];
}

- (void)muteAction:(id)sender {
    //Toogle mute state
    [Options sharedOptions].soundMuted = ![Options sharedOptions].soundMuted;
    
    //Toogle volume
    [[AVAudio sharedAudio] setGeneralVolume: [Options sharedOptions].soundMuted ? 0 : 1];
    
    //Update interface
    [self updateInterface];

    //Save options
    [NSThread detachNewThreadSelector:@selector(saveOptions) toTarget:[Options sharedOptions] withObject:nil];
}

-(void) closeAction:(id)sender {
    //Dismiss modal window
    if (modalDelegate != nil && [modalDelegate respondsToSelector:@selector(closeModalWindow)])
        [modalDelegate closeModalWindow];
}

#pragma mark - Methods

-(void) updateInterface {
    //Left button
    leftButton.title = [Options sharedOptions].soundPlaying ? @"Stop" : @"Play";
    
    //Right button
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        rightButton.title = @"Close";
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        rightButton.title = [Options sharedOptions].soundMuted ? @"Unmute" : @"Mute";
    }
    
    //Table refresh
    [theTable reloadData];
}

-(void) stopCurrentSound {    
    //Toogle playback state
    [Options sharedOptions].soundPlaying = FALSE;
    
    //Toogle playback state
    [[AVAudio sharedAudio] stopMusic];
    
    //Network send
    [networkDelegate sendAction: G2_STOP_TRACK Argument:0 PosX:0 PosY:0 Reliable: TRUE];
}

-(void) playCurrentSound {    
    //Toogle playback state
    [Options sharedOptions].soundPlaying = TRUE;
    
    //Toogle playback state
    [[AVAudio sharedAudio] playMusicKey: [Options sharedOptions].soundKey];

    //Current track index
    int trackCounter = 0;
    for (NSString *track in [AVAudio sharedAudio].music) {
        if ([track isEqualToString: [Options sharedOptions].soundKey])
            break;
        else
            trackCounter++;
    }
    
    //Network Send
    [networkDelegate sendAction: G2_PLAY_TRACK Argument:trackCounter PosX:0 PosY:0 Reliable: TRUE];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[AVAudio sharedAudio].music count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];

    if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:@"MyIdentifier"] autorelease];
    
    if(indexPath.row <= [AVAudio sharedAudio].music.count)
    {
        //Cell text
        cell.textLabel.text = [[AVAudio sharedAudio].music objectAtIndex: indexPath.row];
        
        //Cell icon
        if ([cell.textLabel.text isEqualToString: [Options sharedOptions].soundKey])
            cell.imageView.image = [UIImage imageNamed: [Options sharedOptions].soundPlaying ?  @"play.png" : @"stop.png"];
        else
            cell.imageView.image = [UIImage imageNamed: @"nothing.png"];
    }
    else
    {
        cell.textLabel.text = @"Choose from library";
    }
    
    //Return cell
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.contentView.backgroundColor = [UIColor blackColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Change current sound
    [Options sharedOptions].soundKey = [[AVAudio sharedAudio].music objectAtIndex: indexPath.row];

    //Save options
    [NSThread detachNewThreadSelector:@selector(saveOptions) toTarget: [Options sharedOptions] withObject:nil];
    
    //Play current sound (DELAYED)
    [self performSelector: @selector(playCurrentSound) withObject:nil afterDelay:0.25];
}

#pragma mark - Memory management

- (void)viewDidUnload {
    //Super
    [super viewDidUnload];
    
    //Nil
    [self setTheTable:nil];
    [self setLeftButton: nil];
    [self setRightButton: nil];
}

- (void)dealloc {
    //Debug
    NSLog(@"[AudioViewController dealloc]");
    
    [theTable release];
    [leftButton release];
    [rightButton release];

    //Super
    [super dealloc];
}

@end