//
// GameKitLibrary
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GameKitScore.h"
#import "GameKitAchievement.h"
#import <CommonCrypto/CommonDigest.h>
#import "GLViewController.h"

@class GameKitScore;
@class GameKitAchievement;
@class Reachability;
@class GLViewController;

@interface GameKitLibrary : NSObject {	
	//Collections
	NSMutableArray *scores;
	NSMutableArray *scoreCategories;
	NSMutableArray *achievements;
	NSMutableArray *achievementIdentifiers;
	
	//Other
	bool gameCenterAvailable;
	bool gameCenterPlayerLoggedIn;
    
    //GLViewController
    UIViewController *presentingViewController;
}

//Classic
@property (nonatomic, assign) bool gameCenterAvailable, gameCenterPlayerLoggedIn;
@property (nonatomic, retain) NSMutableArray *scores;
@property (nonatomic, retain) NSMutableArray *achievements;
@property (nonatomic, readonly) bool internetConnectionAvailable;

@property (nonatomic, assign) UIViewController *presentingViewController;

+ (GameKitLibrary *) sharedGameKit;

#pragma mark Security

-(NSString *) scoresSecurityHash;

-(NSString *) achievementsSecurityHash;

#pragma mark Load/Save

-(void) loadScores;

-(void) loadAchievements;

-(void) initiateAchievements;

-(void) saveScores;

-(void) saveAchievements;

-(void) resetAll;

#pragma mark Syncronization

-(void) saveAll;

-(void) syncAll;

-(void) syncScores;

-(void) syncAchievements;

#pragma mark Updates

-(void) removeScoresForCategory: (int) category;

-(void) addNewScore: (int) score Category: (int) category Sync: (bool) sync;

-(int) getBestScoreForCategory: (int) category;

-(void) incrementAchievement: (int) identifier Sync: (bool) sync;

-(void) updateAchievement: (int) identifier Points: (int) points Sync: (bool) sync;

-(void) completeAchievement: (int) identifier Sync: (bool) sync;

-(GameKitAchievement *) achievementWithIdentifier: (int) identifier;

#pragma mark Methods

-(bool) isGameCenterAvailable;

-(void) authenticateLocalPlayer;

-(NSString *)localPlayerName;

-(NSString *)localPlayedID;

#pragma mark Game kit communication

-(void) reportScore: (GameKitScore *) s;

-(void) reportAchievement: (GameKitAchievement *) a;

-(void) showLeaderboardOver: (UIViewController<GKLeaderboardViewControllerDelegate> *) delegate Category: (int) cat Timescope: (int) timescope;

-(void) showAchievementsOver: (UIViewController<GKAchievementViewControllerDelegate> *) delegate;

#pragma mark Other

-(NSString*) md5: (NSString*) str;

@end
