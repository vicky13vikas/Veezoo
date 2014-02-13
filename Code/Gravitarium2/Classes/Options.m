//
//  Options.m
//  Gavitarium2
//
//  Created by Robert Neagu on 5/8/11.
//  Copyright 2011 TotalSoft. All rights reserved.
//

#import "Options.h"

@implementation Options

#pragma mark - Singleton implementation

static Options *sharedOptionsInstance = nil;

+ (Options *)sharedOptions
{
    @synchronized(self)
	{
        if (sharedOptionsInstance == nil) {
            sharedOptionsInstance = [[self alloc] initOptions];
        }
    }
    
    return sharedOptionsInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
	{
        if (sharedOptionsInstance == nil) {
            sharedOptionsInstance = [super allocWithZone:zone];
            return sharedOptionsInstance;  // assignment and return on first allocation
        }
    }
    
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release
{
    // do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark - Properties

//Sound
@synthesize soundKey, soundPlaying, soundMuted, soundRepeat;
@synthesize musicPlayerLibrary;


//Options
@synthesize particleCount, particleTail, particleSize, particleSpeed;
@synthesize particleRed, particleGreen, particleBlue, particleAlpha;
@synthesize particleColorCycle, preventSleep;

-(void) setPreventSleep:(_Bool) value {
    preventSleep = value;
    
    //Apply setting
    [UIApplication sharedApplication].idleTimerDisabled = value;
}

#pragma mark - Initialize

-(id) initOptions {
    self = [super init];
    
    if (self) {
        //Copy preset files
        bool presets = [[NSUserDefaults standardUserDefaults] boolForKey: @"presetsInPlace"];
        if (presets == FALSE) {
            //Copy bundle files
            [self copyBundleFiles];
            
            //Save
            [[NSUserDefaults standardUserDefaults] setBool: TRUE forKey: @"presetsInPlace"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        //Load options
        bool defaults = [[NSUserDefaults standardUserDefaults] boolForKey: @"defaultsInPlace"];
        if (defaults == FALSE) {
            //Sound
            self.soundKey = [[AVAudio sharedAudio].music objectAtIndex: 0];
            soundPlaying = TRUE;
            soundMuted = FALSE;
            soundRepeat = FALSE;
            
            //Load defaults
            [self loadPreset: @"Default" Extension: @"plist"];
        } else {
            //Sound
            self.soundKey = [[NSUserDefaults standardUserDefaults] stringForKey: @"soundKey"];
            soundPlaying = [[NSUserDefaults standardUserDefaults] boolForKey: @"soundPlaying"];
            soundMuted = [[NSUserDefaults standardUserDefaults] boolForKey: @"soundMuted"];
            soundRepeat = [[NSUserDefaults standardUserDefaults] boolForKey: @"soundRepeat"];
            
            //Options
            particleCount = [[NSUserDefaults standardUserDefaults] integerForKey: @"particleCount"];
            particleTail = [[NSUserDefaults standardUserDefaults] floatForKey: @"particleTail"];
            particleSize = [[NSUserDefaults standardUserDefaults] floatForKey: @"particleSize"];
            particleSpeed = [[NSUserDefaults standardUserDefaults] floatForKey: @"particleSpeed"];
            
            particleRed = [[NSUserDefaults standardUserDefaults] floatForKey: @"particleRed"];
            particleGreen = [[NSUserDefaults standardUserDefaults] floatForKey: @"particleGreen"];
            particleBlue = [[NSUserDefaults standardUserDefaults] floatForKey: @"particleBlue"];
            particleAlpha = [[NSUserDefaults standardUserDefaults] floatForKey: @"particleAlpha"];
            
            particleColorCycle = [[NSUserDefaults standardUserDefaults] boolForKey: @"particleColorCycle"];
            preventSleep = [[NSUserDefaults standardUserDefaults] boolForKey: @"preventSleep"];
        }
    }
    
    return self;
}

-(void) saveOptions {
    //Sound
    [[NSUserDefaults standardUserDefaults] setValue: soundKey forKey: @"soundKey"];
    [[NSUserDefaults standardUserDefaults] setBool: soundPlaying forKey: @"soundPlaying"];
    [[NSUserDefaults standardUserDefaults] setBool: soundMuted forKey: @"soundMuted"];
    [[NSUserDefaults standardUserDefaults] setBool: soundRepeat forKey: @"soundRepeat"];
    
    //Options
    [[NSUserDefaults standardUserDefaults] setInteger: particleCount forKey: @"particleCount"];
    [[NSUserDefaults standardUserDefaults] setFloat: particleTail forKey: @"particleTail"];
    [[NSUserDefaults standardUserDefaults] setFloat: particleSize forKey: @"particleSize"];
    [[NSUserDefaults standardUserDefaults] setFloat: particleSpeed forKey: @"particleSpeed"];
    
    [[NSUserDefaults standardUserDefaults] setFloat: particleRed forKey: @"particleRed"];
    [[NSUserDefaults standardUserDefaults] setFloat: particleGreen forKey: @"particleGreen"];
    [[NSUserDefaults standardUserDefaults] setFloat: particleBlue forKey: @"particleBlue"];
    [[NSUserDefaults standardUserDefaults] setFloat: particleAlpha forKey: @"particleAlpha"];
    
    [[NSUserDefaults standardUserDefaults] setBool: particleColorCycle forKey: @"particleColorCycle"];
    [[NSUserDefaults standardUserDefaults] setBool: preventSleep forKey: @"preventSleep"];
    
    //Save
    [[NSUserDefaults standardUserDefaults] setBool: TRUE forKey: @"defaultsInPlace"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Load/Save presets

-(void) loadPreset: (NSString *) filename Extension: (NSString *) extension {
    //Get readable file path
    NSString *filePath = [self getDocumentsPathForFileName: filename Extension: extension];
    
    //Load object from file
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile: filePath];
    
    //Decompose object
    particleCount = [[dic objectForKey: @"particleCount"] intValue];
    particleTail = [[dic objectForKey: @"particleTail"] floatValue];
    particleSize = [[dic objectForKey: @"particleSize"] floatValue];
    particleSpeed = [[dic objectForKey: @"particleSpeed"] floatValue];
    
    particleRed = [[dic objectForKey: @"particleRed"] floatValue];
    particleGreen = [[dic objectForKey: @"particleGreen"] floatValue];
    particleBlue = [[dic objectForKey: @"particleBlue"] floatValue];
    particleAlpha = [[dic objectForKey: @"particleAlpha"] floatValue];
    
    particleColorCycle  = [[dic objectForKey: @"particleColorCycle"] intValue] == 1;
    preventSleep = [[dic objectForKey: @"preventSleep"] intValue] == 1;
    
    //Settings protection
    if ([self isHighPerformanceSystem]) {
        if (particleCount > 5000)
            particleCount = 5000;
    } else {
        if (particleCount > 3000)
            particleCount = 3000;
    }
    
    //Release
    [dic release];
}

-(void) saveCurrentPreset {
    //Get writable file path
    NSString *filePath = [self getDocumentsPathForFileName: @"Custom" Extension: @"plist"];
    
    //Compose object
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSNumber numberWithInt: particleCount], @"particleCount",
                         [NSNumber numberWithFloat: particleTail], @"particleTail",
                         [NSNumber numberWithFloat: particleSize], @"particleSize",
                         [NSNumber numberWithFloat: particleSpeed], @"particleSpeed",
                         
                         [NSNumber numberWithFloat: particleRed], @"particleRed",
                         [NSNumber numberWithFloat: particleGreen], @"particleGreen", 
                         [NSNumber numberWithFloat: particleBlue], @"particleBlue",
                         [NSNumber numberWithFloat: particleAlpha], @"particleAlpha",
                         
                         [NSNumber numberWithInt: particleColorCycle ? 1 : 0], @"particleColorCycle",
                         [NSNumber numberWithInt: preventSleep ? 1 : 0], @"preventSleep",
    nil];
    
    //Save object to file
    [dic writeToFile: filePath atomically: TRUE];
    
    //Release
    [dic release];
}

#pragma mark - Helpers

-(void) copyBundleFiles {
    //Copy bundle files
    NSArray *files = [NSArray arrayWithObjects: @"Default", @"Drawing", @"Tranquility", @"Custom", nil];
    for (NSString *file in files) {
        //Source and destination
        NSString *fileSource = [self getBundlePathForFilename: file Extension: @"plist"];
        NSString *fileDestination = [self getDocumentsPathForFileName: file Extension: @"plist"];
        
        //Copy file
        [[NSFileManager defaultManager] copyItemAtPath: fileSource toPath: fileDestination error:nil];
    }
}

-(NSString *) getBundlePathForFilename: (NSString *) filename Extension: (NSString *) extension {
    return [[NSBundle mainBundle] pathForResource: filename ofType: extension];    
}

-(NSString *) getDocumentsPathForFileName: (NSString *) filename Extension:(NSString *)extension {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return  [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", filename, extension]];
}

-(bool) isHighPerformanceSystem {
	size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname("hw.machine", answer, &size, NULL, 0);
	NSString *result = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
    
    //Debug
    NSLog(@"DeviceModel: %@", result);
    
	if ([result isEqualToString: @"iPad2,1"] || [result isEqualToString: @"iPad2,2"]) 
		return TRUE;
	else
		return FALSE;
}

@end