//
//  OptionsViewController.h
//  Gavitarium2
//
//  Created by Robert Neagu on 5/8/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Options.h"
#import "General.h"
#import "GLViewController.h"

@interface OptionsViewController : UIViewController<NetworkReceiveDelegate> {
    id<NetworkSendDelegate> networkDelegate;
    id<ModalViewDelegate> modalDelegate;
    
    UIBarButtonItem *leftButton;
    UIBarButtonItem *rightButton;
    
    UILabel *lblParticles;
    UISlider *sldParticles;
    UILabel *lblSize;
    UISlider *sldSize;
    UILabel *lblTail;
    UISlider *sldTail;
    UILabel *lblSpeed;
    UISlider *sldSpeed;

    UILabel *lblRed;
    UISlider *sldRed;
    UILabel *lblGreen;
    UISlider *sldGreen;
    UILabel *lblBlue;
    UISlider *sldBlue;
    UILabel *lblAlpha;
    UISlider *sldAlpha;
    
    UISwitch *btnColor;
    UISwitch *btnPreventSleep;
    UISwitch *btnRepeat;
}

@property (nonatomic, assign) id<NetworkSendDelegate> networkDelegate;
@property (nonatomic, assign) id<ModalViewDelegate> modalDelegate;

@property (nonatomic, retain) UIBarButtonItem *leftButton;
@property (nonatomic, retain) UIBarButtonItem *rightButton;

@property (nonatomic, retain) IBOutlet UILabel *lblParticles;
@property (nonatomic, retain) IBOutlet UISlider *sldParticles;
@property (nonatomic, retain) IBOutlet UILabel *lblSize;
@property (nonatomic, retain) IBOutlet UISlider *sldSize;
@property (nonatomic, retain) IBOutlet UILabel *lblTail;
@property (nonatomic, retain) IBOutlet UISlider *sldTail;
@property (nonatomic, retain) IBOutlet UILabel *lblSpeed;
@property (nonatomic, retain) IBOutlet UISlider *sldSpeed;

@property (nonatomic, retain) IBOutlet UILabel *lblRed;
@property (nonatomic, retain) IBOutlet UISlider *sldRed;
@property (nonatomic, retain) IBOutlet UILabel *lblGreen;
@property (nonatomic, retain) IBOutlet UISlider *sldGreen;
@property (nonatomic, retain) IBOutlet UILabel *lblBlue;
@property (nonatomic, retain) IBOutlet UISlider *sldBlue;
@property (nonatomic, retain) IBOutlet UILabel *lblAlpha;
@property (nonatomic, retain) IBOutlet UISlider *sldAlpha;

@property (nonatomic, retain) IBOutlet UISwitch *btnColor;
@property (nonatomic, retain) IBOutlet UISwitch *btnPreventSleep;
@property (nonatomic, retain) IBOutlet UISwitch *btnRepeat;

-(void) showLoad;

-(void) showSave;

-(void) sendOptionsToNetwork;

-(void) updateInterface;

-(void) updateLabels;

-(void) updateControls;

- (IBAction)sliderChanged:(id)sender;

- (IBAction)buttonChanged:(id)sender;

@end
