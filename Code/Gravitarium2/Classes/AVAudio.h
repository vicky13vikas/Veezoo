//
//  AVAudio.h
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

//Protocol

@protocol MusicPlayerDelegate <NSObject>

-(void) playbackStartedForMusicKey: (NSString *) key;

-(void) playbackStoppedForMusicKey: (NSString *) key;

-(void) playbackFinishedForMusicKey: (NSString *) key;

@end

@interface AVAudio : NSObject<AVAudioPlayerDelegate> {
    NSMutableDictionary *sounds;
    NSMutableArray *music;
    AVAudioPlayer *musicPlayer;
    NSString *musicKey;
    id<MusicPlayerDelegate> delegate;
}

//Singleton

+ (AVAudio *)sharedAudio;

//Propertis

@property (nonatomic, retain) NSMutableDictionary *sounds;
@property (nonatomic, retain) NSMutableArray *music;
@property (nonatomic, retain) AVAudioPlayer *musicPlayer;
@property (nonatomic, retain) NSString *musicKey;
@property (nonatomic, assign) id<MusicPlayerDelegate> delegate;

//Sound effects control

-(void) playSound: (NSString *) key;

-(void) playLoopingSound: (NSString *) key;

-(void) stopSound: (NSString *) key;

-(void) stopLoopingSounds;

-(void) stopAllSounds;

//Music control

-(void) playMusicKey: (NSString *) key;

-(void) stopMusic;

//Volume control

-(void) setGeneralVolume: (float) vol;

-(void) setVolume: (float) vol forSound: (NSString *) key;

-(void) setMusicVolume: (float) vol;

@end