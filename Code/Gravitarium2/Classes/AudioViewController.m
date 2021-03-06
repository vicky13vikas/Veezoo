//
//  AudioViewController.m
//  Gavitarium2
//
//  Created by Robert Neagu on 5/20/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import "AudioViewController.h"
#import "RageIAPHelper.h"
#import "SVProgressHUD.h"

#define CHOOSE_FROM_LIBRARY @"Choose from Library..."
#define PREMIUM_FREATURE_PURCHASED @"isPremiumFeaturePurchased"
#define PRODUCT_ID_PREMIUM @"ro.novasoft.gravitariumm2.buypremium"
#define ALERT_TAG_PURCHASE 105


@interface AudioViewController() <UIAlertViewDelegate>
{
     MPMediaItem *song;
}

@end
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


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseFailed:) name:IAPHelperPurchaseFailedNotification object:nil];
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
    
    if([Options sharedOptions].soundPlaying)
    {
        leftButton.title = @"Stop";
    }
    else{
        leftButton.title =  @"Play";
    }
    
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
    
    if([Options sharedOptions].musicPlayerLibrary)
    {
        [[Options sharedOptions].musicPlayerLibrary stop];
        [Options sharedOptions].musicPlayerLibrary = nil;
    }

        [Options sharedOptions].soundPlaying = FALSE;
        
        //Toogle playback state
        [[AVAudio sharedAudio] stopMusic];
        
        //Network send
        [networkDelegate sendAction: G2_STOP_TRACK Argument:0 PosX:0 PosY:0 Reliable: TRUE];
}

-(void) playCurrentSound {
    //Toogle playback state
    
    if([Options sharedOptions].musicPlayerLibrary)
    {
        [[Options sharedOptions].musicPlayerLibrary play];
        [Options sharedOptions].soundPlaying = YES;
    }
    else
    {
        [Options sharedOptions].soundPlaying = TRUE;
        
        //Toogle playback state
        
        if([[Options sharedOptions].soundKey isEqualToString:CHOOSE_FROM_LIBRARY])
        {
            [self PickAudioForIndex_iPhone];
        }
        else
        {
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
      
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[AVAudio sharedAudio].music count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];

    if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:@"MyIdentifier"] autorelease];
    
    
    if(indexPath.row == 0)
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.textLabel.textColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.00];
        cell.textLabel.text = CHOOSE_FROM_LIBRARY;
        if ([cell.textLabel.text isEqualToString: [Options sharedOptions].soundKey])
            cell.imageView.image = [UIImage imageNamed: [Options sharedOptions].soundPlaying ?  @"play.png" : @"stop.png"];
        else
            cell.imageView.image = [UIImage imageNamed: @"nothing.png"];    }
    else
    {
        //Cell text
        cell.textLabel.text = [[AVAudio sharedAudio].music objectAtIndex: indexPath.row - 1];
        
        //Cell icon
        if ([cell.textLabel.text isEqualToString: [Options sharedOptions].soundKey])
            cell.imageView.image = [UIImage imageNamed: [Options sharedOptions].soundPlaying ?  @"play.png" : @"stop.png"];
        else
            cell.imageView.image = [UIImage imageNamed: @"nothing.png"];
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
    
    if(indexPath.row == 0)
    {
        if([[NSUserDefaults standardUserDefaults] objectForKey:PREMIUM_FREATURE_PURCHASED])
        {
            [self PickAudioForIndex_iPhone];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"This is a premium feature" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
            alert.tag = ALERT_TAG_PURCHASE;
            [alert show];
        }
    }
    else
    {
        [[Options sharedOptions].musicPlayerLibrary stop];
        [Options sharedOptions].musicPlayerLibrary = nil;

        //Change current sound
        [Options sharedOptions].soundKey = [[AVAudio sharedAudio].music objectAtIndex: indexPath.row - 1];
        
        //Save options
        [NSThread detachNewThreadSelector:@selector(saveOptions) toTarget: [Options sharedOptions] withObject:nil];
        
        //Play current sound (DELAYED)
        [self performSelector: @selector(playCurrentSound) withObject:nil afterDelay:0.25];
    }
    
}

#pragma mark Media picker delegate methods

-(void)PickAudioForIndex_iPhone
{
    
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
        //device is simulator
        UIAlertView *alert1;
        alert1 = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"There is no Audio file in the Device" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
        alert1.tag=2;
        [alert1 show];
        //[alert1 release],alert1=nil;
    }else{
        
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = NO; // this is the default
        [self presentViewController:mediaPicker animated:YES completion:nil];
        
        [self stopCurrentSound];
    }
    
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    // We need to dismiss the picker
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Assign the selected item(s) to the music player and start playback.
    if ([mediaItemCollection count] < 1) {
        return;
    }
    song = [[mediaItemCollection items] objectAtIndex:0];
//    [self handleExportTapped];
    
    [[Options sharedOptions] setMusicPlayerLibrary: [MPMusicPlayerController applicationMusicPlayer]];
    if(song)
    {
        [[Options sharedOptions].musicPlayerLibrary setQueueWithItemCollection: mediaItemCollection];
//        [self setPlayedMusicOnce: YES];
        [Options sharedOptions].soundKey = CHOOSE_FROM_LIBRARY;
        [Options sharedOptions].soundPlaying = YES;
        [[Options sharedOptions].musicPlayerLibrary play];
        [self updateInterface];

    }
    else
    {
        [self playCurrentSound];
    }
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    
    // User did not select anything
    // We need to dismiss the picker
    
    [self dismissViewControllerAnimated:YES completion:nil ];
    [self playCurrentSound];
}

#pragma -mark UIAlertView Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_TAG_PURCHASE)
    {
        if(buttonIndex == 1)
        {
            [self buyInappPremium];
        }
    }
}

#pragma -mark InappPurchaseMethods


-(void)buyInappPremium
{
    [SVProgressHUD showWithStatus:@"Contacting Store..."];

    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success)
        {
            SKProduct *productToBuy;
            if([products count]>0)
            {
                for (SKProduct *product in products)
                {
                    if ([product.productIdentifier isEqualToString:PRODUCT_ID_PREMIUM]) {
                        productToBuy = product;
                        break;
                    }
                }
                
               [[RageIAPHelper sharedInstance] buyProduct:productToBuy];
            }
        }
        else
        {
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not connect to store." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}


- (void)productPurchased:(NSNotification *)notification {
    
    [SVProgressHUD dismiss];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREMIUM_FREATURE_PURCHASED];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congrats!" message:@"Purchased successfully. Now you can use this feature for free." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)purchaseFailed:(NSNotification *)notification {
    
    [SVProgressHUD dismiss];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Purchase not completed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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