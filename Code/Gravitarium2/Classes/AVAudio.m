//
//  AVAudio.m
//  

#import "AVAudio.h"

@implementation AVAudio

#pragma mark - Singleton implementation

static AVAudio *sharedAudioInstance = nil;

+ (AVAudio *)sharedAudio
{
    @synchronized(self)
	{
        if (sharedAudioInstance == nil) {
            sharedAudioInstance = [[self alloc] init];
        }
    }

    return sharedAudioInstance;
}
 
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
	{
        if (sharedAudioInstance == nil) {
            sharedAudioInstance = [super allocWithZone:zone];
            return sharedAudioInstance;  // assignment and return on first allocation
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

@synthesize sounds, music, musicPlayer, musicKey, delegate;

#pragma mark Instance management

-(id) init {
    self = [super init];
    
	if (self) {
        //Mix with iPod sound
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        UInt32 doSetProperty = 1;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
        [[AVAudioSession sharedInstance] setActive: YES error: nil];

        //Load collections
        sounds = [[NSMutableDictionary alloc] init];
        music = [[NSMutableArray alloc] init];
        
		//Get file manager
		NSFileManager *fileManager=[[NSFileManager alloc] init];
		NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath: [[NSBundle mainBundle] resourcePath]];
		
		//Enumerate files
		NSString *filename;
		while ((filename = [directoryEnumerator nextObject])) {
            //Assign a key
            NSString* key = [[filename lastPathComponent] stringByDeletingPathExtension];
            NSString* extension = [filename pathExtension];
            
            //Only for sound files
            if ([extension isEqualToString: @"wav"]) {
                //Debug
                //NSLog(@"Preloading '%@.%@'...", key, extension);
                
                //Calculate URL
                NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:key ofType: extension]];
                
                //Create new player, prepare to play
                AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
                [newPlayer prepareToPlay];
                    
                //Assign player in dictionary
                [sounds setObject: newPlayer forKey: key];
                
                //Release stuff
                [fileURL release];
                [newPlayer release];
            } else if ([extension isEqualToString: @"mp3"]) {
                //Debug
                NSLog(@"Added '%@.%@' to playlist...", key, extension);                
             
                //Add key to playlist
                [music addObject: key];
            }
        }
        
		//Release file manager
		[fileManager release];
    }
	
	//Return object
	return self;
}

#pragma mark AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag == FALSE)
        return;
    
    //Delegate send
    if (delegate != nil)
        [delegate playbackFinishedForMusicKey: self.musicKey];
}

#pragma mark Sound effects control

-(void) playSound: (NSString *) key {
    AVAudioPlayer *avPlayer = (AVAudioPlayer *) [sounds objectForKey: key];
    avPlayer.numberOfLoops = 0;
    [avPlayer play];
}

-(void) playLoopingSound: (NSString *) key {
    AVAudioPlayer *avPlayer = (AVAudioPlayer *) [sounds objectForKey: key];
    avPlayer.numberOfLoops = -1;
    [avPlayer play];
}

-(void) stopSound: (NSString *) key {
    AVAudioPlayer *avPlayer = (AVAudioPlayer *) [sounds objectForKey: key];
    [avPlayer stop];
}

-(void) stopLoopingSounds {
    for (NSString *key in [sounds allKeys]) {
        AVAudioPlayer *avPlayer = (AVAudioPlayer *) [sounds objectForKey: key];
        
        //Detect looping sounds
        if (avPlayer.numberOfLoops == -1) {
            [avPlayer stop]; 
            [avPlayer setCurrentTime: 0];
        }
    }
}

-(void) stopAllSounds {
    for (NSString *key in [sounds allKeys]) {
        AVAudioPlayer *avPlayer = (AVAudioPlayer *) [sounds objectForKey: key];
        [avPlayer stop]; 
        [avPlayer setCurrentTime: 0];
    } 
}

#pragma mark Music control

-(void) playMusicKey: (NSString *) key {    
    //Stop music
    [self stopMusic];
    
    //Calculate URL
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:key ofType: @"mp3"]];
    
    //Create player
    self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    musicPlayer.numberOfLoops = 0;
    musicPlayer.delegate = self;
    
    //Play
    [musicPlayer play];
    
    //Remember key
    self.musicKey = key;
    
    //Delegate send
    if (delegate != nil)
        [delegate playbackStartedForMusicKey: musicKey];

    //Release
    [fileURL release];
}

-(void) stopMusic {
    //Detect if playing
    if (musicPlayer != nil && musicPlayer.playing) {
        //Stop
        [musicPlayer stop]; 
        
        //Release player
        self.musicPlayer = nil;
        
        //Delegate
        if (delegate != nil)
            [delegate playbackStoppedForMusicKey: musicKey];
    
        //No key
        self.musicKey = nil;
    }
}

#pragma mark Volume control

-(void) setGeneralVolume: (float) vol {
    for (NSString *key in [sounds allKeys]) {
        AVAudioPlayer *avPlayer = (AVAudioPlayer *) [sounds objectForKey: key];
        avPlayer.volume = vol;
    }
    musicPlayer.volume = vol;
}

-(void) setVolume: (float) vol forSound: (NSString *) key {
    AVAudioPlayer *avPlayer = (AVAudioPlayer *) [sounds objectForKey: key];
    avPlayer.volume = vol;
}

-(void) setMusicVolume: (float) vol {
    musicPlayer.volume = vol;
}

@end
