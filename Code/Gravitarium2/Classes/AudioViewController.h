//
//  AudioViewController.h
//  
//
//  Created by Robert Neagu on 5/20/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVAudio.h"
#import "General.h"
#import "Options.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AudioViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NetworkReceiveDelegate, MPMediaPickerControllerDelegate> {
    //Delegates
    id<NetworkSendDelegate> networkDelegate;
    id<ModalViewDelegate> modalDelegate;
    
    //UI
    UITableView *theTable;
    UIBarButtonItem *leftButton;
    UIBarButtonItem *rightButton;
}

//Delegates
@property (nonatomic, assign) id<NetworkSendDelegate> networkDelegate;
@property (nonatomic, assign) id<ModalViewDelegate> modalDelegate;

//UI
@property (nonatomic, retain) IBOutlet UITableView *theTable;
@property (nonatomic, retain) UIBarButtonItem *leftButton;
@property (nonatomic, retain) UIBarButtonItem *rightButton;

-(void) updateInterface;

-(void) playCurrentSound;

-(void) stopCurrentSound;

-(void) playAction:(id)sender;

-(void) muteAction:(id)sender;

-(void) closeAction:(id)sender;

@end
