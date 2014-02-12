//
//  Options.h
//  Gavitarium2
//
//  Created by Robert Neagu on 5/8/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/sysctl.h>
#import "AVAudio.h"

@class AVAudio;

@interface Options : NSObject {
    //Sound
    NSString *soundKey;
    bool soundPlaying, soundMuted, soundRepeat;
    
    //Options
    int particleCount;
    float particleTail, particleSize, particleSpeed, particleRed, particleGreen, particleBlue, particleAlpha;
    bool particleColorCycle, preventSleep;
}

//Singleton

+ (Options *) sharedOptions;

//Sound
@property (nonatomic, retain) NSString* soundKey;
@property (nonatomic) bool soundPlaying, soundMuted, soundRepeat;

//Options
@property (nonatomic) int particleCount;
@property (nonatomic) float particleTail, particleSize, particleSpeed,  particleRed, particleGreen, particleBlue, particleAlpha;
@property (nonatomic) bool particleColorCycle,  preventSleep;

#pragma mark - Initialize

-(id) initOptions;

-(void) saveOptions;

#pragma mark - Load/Save presets

-(void) loadPreset: (NSString *) filename Extension: (NSString *) extension;

-(void) saveCurrentPreset;

#pragma mark - Helpers

-(void) copyBundleFiles;

-(NSString *) getBundlePathForFilename: (NSString *) filename Extension: (NSString *) extension;

-(NSString *) getDocumentsPathForFileName: (NSString *) filename Extension: (NSString *) extension;

-(bool) isHighPerformanceSystem;

@end
