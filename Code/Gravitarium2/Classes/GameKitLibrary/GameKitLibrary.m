//
//  GameKitLibrary.m
//

#import "GameKitLibrary.h"

@implementation GameKitLibrary

#pragma mark Properties

@synthesize scores, achievements, internetConnectionAvailable, gameCenterAvailable, gameCenterPlayerLoggedIn, presentingViewController;

#pragma mark Singleton implementation

static GameKitLibrary *sharedGameKit = nil;

+ (GameKitLibrary *) sharedGameKit
{
    @synchronized(self)
	{
        if (sharedGameKit == nil) {
            sharedGameKit = [[self alloc] init];
        }
    }
	
    return sharedGameKit;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
	{
        if (sharedGameKit == nil) {
            sharedGameKit = [super allocWithZone:zone];
            return sharedGameKit;
        }
    }
	
    return nil;
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

#pragma mark Instance management

-(id) init {
    self = [super init];
    
	if (self) {
		//Initiate collections
		scores = nil;
		achievements = nil;
		
		//Initiate definitions
		scoreCategories = [[NSMutableArray alloc] initWithObjects: @"GL", @"GT", @"GC", nil];
		achievementIdentifiers = [[NSMutableArray alloc] initWithObjects: nil];
		
		//Load stuff
		[self loadScores];
		[self loadAchievements];
		
		//Check availability
		gameCenterAvailable = [self isGameCenterAvailable];
		
		//Initial login state
		gameCenterPlayerLoggedIn = FALSE;
		
		//Authenticate if GameCenter is available
		if (self.gameCenterAvailable && self.internetConnectionAvailable)
			[self authenticateLocalPlayer];
	}
	
	//Return object
	return self;
}

#pragma mark Connectivity

-(bool) internetConnectionAvailable {
    return TRUE;
	//return internetConnectionAvailable = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi || [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN;
}	

#pragma mark Security

-(NSString *) scoresSecurityHash {
	int checksum = 0;
	for (int i=0; i<[scores count]; i++) {
		GameKitScore *gks = [scores objectAtIndex: i];
		checksum += gks.value + gks.category * 100;
	}
	return [self md5: [NSString stringWithFormat: @"%i", checksum]];
}

-(NSString *) achievementsSecurityHash {
	int checksum = 0;
	for (int i=0; i<[achievements count]; i++) {
		GameKitAchievement *gka = [achievements objectAtIndex: i];
		checksum += gka.points + gka.total * 100;
	}
	return [self md5: [NSString stringWithFormat: @"%i", checksum]];
}

#pragma mark Load/Save

-(void) loadScores {
	//Load from disk
	NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
	NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"Scores"];
	
	if (dataRepresentingSavedArray != nil) {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData: dataRepresentingSavedArray];
        if (oldSavedArray != nil)
			scores = [[NSMutableArray alloc] initWithArray:oldSavedArray];
        else
			scores = [[NSMutableArray alloc] init];
	} else {
		scores = [[NSMutableArray alloc] init];
	}
	
	//Check security
	NSString *calculatedSecurity = [self scoresSecurityHash];
	NSString *loadedSecurity = [currentDefaults objectForKey: @"SecurityHashScores"];
	if (![loadedSecurity isEqualToString: calculatedSecurity]) {
		[scores removeAllObjects];
	}
	
	//Debug
	for (int i=0; i<[scores count]; i++) {
		GameKitScore *gks = [scores objectAtIndex: i];
		NSLog(@"Load Score = Cat: %i Value: %i Sent: %i", gks.category, gks.value, gks.sent);
	}
}

-(void) loadAchievements {
	//Load from disk
	NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
	NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"Achievements"];
	
	if (dataRepresentingSavedArray != nil) {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData: dataRepresentingSavedArray];
        if (oldSavedArray != nil)
			achievements = [[NSMutableArray alloc] initWithArray:oldSavedArray];
        else
			[self initiateAchievements];
	} else {
		[self initiateAchievements];
	}
	
	//Check security
	NSString *calculatedSecurity = [self achievementsSecurityHash];
	NSString *loadedSecurity = [currentDefaults objectForKey: @"SecurityHashAchievements"];
	if (![loadedSecurity isEqualToString: calculatedSecurity]) {
		[achievements removeAllObjects];
		[achievements release];
		[self initiateAchievements];
	}
	
	//Debug
	for (int i=0; i<[achievements count]; i++) {
		GameKitAchievement *gka = [achievements objectAtIndex: i];
		NSLog(@"Load Achievement = Ident: %i Points: %i Total: %i Percentage: %i Sent: %i", gka.identifier, gka.points, gka.total, gka.percentage, gka.sent);
	}
}

-(void) initiateAchievements {
	//Initiate collection
	achievements = [[NSMutableArray alloc] init];
	
	//Add achivements
	for (int i=0; i<[achievementIdentifiers count]; i++) {
		GameKitAchievement *a = [[GameKitAchievement alloc] initWithIndentifier: i Points:0 Total:1];
		a.sent = TRUE;
		[achievements insertObject: a atIndex: [achievements count]];
		[a release];		
	}
}

-(void) saveScores {
	//Security
	NSString *securityHash = [self scoresSecurityHash];
	
	//Save to disk
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:scores];
	[def setObject: data forKey: @"Scores"];
	[def setObject: securityHash forKey: @"SecurityHashScores"];
	[def synchronize];
	
	//Debug
	for (int i=0; i<[scores count]; i++) {
		GameKitScore *gks = [scores objectAtIndex: i];
		NSLog(@"Save Score = Cat: %i Value: %i Sent: %i", gks.category, gks.value, gks.sent);
	}
}

-(void) saveAchievements {
	//Security
	NSString *securityHash = [self achievementsSecurityHash];
	
	//Save to disk
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:achievements];
	[def setObject: data forKey: @"Achievements"];
	[def setObject: securityHash forKey: @"SecurityHashAchievements"];
	[def synchronize];
	
	//Debug
	for (int i=0; i<[achievements count]; i++) {
		GameKitAchievement *gka = [achievements objectAtIndex: i];
		NSLog(@"Save Achievement = Ident: %i Points: %i Total: %i Percentage: %i Sent: %i", gka.identifier, gka.points, gka.total, gka.percentage, gka.sent);
	}
}

-(void) resetAll {
	//Reset
	[scores removeAllObjects];
	[achievements removeAllObjects];
	[achievements release];
	[self initiateAchievements];
	
	//Save
	[self saveScores];
	[self saveAchievements];
}

#pragma mark Updates

-(void) removeScoresForCategory: (int) category {
	//Score remove
	int i = 0;
	while (i<[scores count]) {
        GameKitScore *gks = [scores objectAtIndex: i];
        if (gks.category == category)
            [scores removeObjectAtIndex: i];
        else
            i++;
	}
}

-(void) addNewScore: (int) score Category: (int) category Sync: (bool) sync {
	//Search for score already in the list
	for (int i=0; i<[scores count]; i++) {
		GameKitScore *gks = [scores objectAtIndex: i];
		if (gks.value == score && gks.category == category) {
			gks.sent = FALSE;
			if (sync)
				[self syncScores];
			return;
		}
	}
	
	//Find a place for the new score
	int indexForInsertion = [scores count];
	for (int i=0; i<[scores count]; i++) {
		GameKitScore *gks = [scores objectAtIndex: i];
		if (score > gks.value) {
			indexForInsertion = i;
			break;
		}
	}
	
	//Add new score
	GameKitScore *gks = [[GameKitScore alloc] initWithValue: score Category: category];
	[scores insertObject: gks atIndex: indexForInsertion];
	[gks release];
	
	//Trim scores array
	while ([scores count] > 1000) {
		[scores removeLastObject];
	}
	
	//Sync
	if (sync)
		[self syncScores];
}

-(int) getBestScoreForCategory: (int) category {
	int bestScore = 0;
	for (int i=0; i<[scores count]; i++){
		GameKitScore *gks = [scores objectAtIndex: i];
		if (gks.category == category && gks.value > bestScore)
			bestScore = gks.value;
	}
	return bestScore;
}

-(void) incrementAchievement: (int) identifier Sync: (bool) sync {
	//Increment
	GameKitAchievement *a = [self achievementWithIdentifier: identifier];
	a.points = a.points + 1;
	a.sent = FALSE;
	
	//Sync
	if (sync)
		[self syncAchievements];
}

-(void) updateAchievement: (int) identifier Points: (int) points Sync: (bool) sync {
	//Update
	GameKitAchievement *a = [self achievementWithIdentifier: identifier];
	a.points = points;
	a.sent = FALSE;
	
	//Sync
	if (sync)
		[self syncAchievements];
}

-(void) completeAchievement: (int) identifier Sync: (bool) sync {
	//Increment
	GameKitAchievement *a = [self achievementWithIdentifier: identifier];
	a.points = a.total;
	a.sent = FALSE;
	
	//Sync
	if (sync)
		[self syncAchievements];
}

-(GameKitAchievement *) achievementWithIdentifier: (int) identifier {
	for (int i=0; i<[achievements count]; i++) {
		GameKitAchievement *gka = [achievements objectAtIndex: i];
		if (gka.identifier == identifier)
			return gka;
	}
	
	return nil;
}

#pragma mark Syncronization

-(void) saveAll {
	//Save
	[self saveScores];
	[self saveAchievements];
}

-(void) syncAll {
	//Sync
	[self syncScores];
	[self syncAchievements];
}

-(void) syncScores {
	NSLog(@"Syncing scores...");
	
	for (int i=0; i<[scores count]; i++) {
		GameKitScore *gks = [scores objectAtIndex: i];
		if (!gks.sent) {
			NSLog(@"Reporting score: %i", gks.value);
			[self reportScore: gks];
		}
	}
	
	NSLog(@"Done.");
}

-(void) syncAchievements {
	NSLog(@"Syncing achievements...");
	
	for (int i=0; i<[achievements count]; i++) {
		GameKitAchievement *gka = [achievements objectAtIndex: i];
		if (!gka.sent) {
			NSLog(@"Reporting achievement: %i", gka.percentage);
			[self reportAchievement: gka];
		}
	}
	
	NSLog(@"Done.");
}

#pragma mark Methods

-(bool) isGameCenterAvailable {
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));

    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
    return (gcClass && osVersionSupported);
}

-(void) authenticateLocalPlayer {
	if ([self isGameCenterAvailable] == FALSE)
		return;
	
	//Register event
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticationDidChange) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	
	//Try to login
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if (error == nil){
			gameCenterPlayerLoggedIn = TRUE;
		}
		else {
			gameCenterPlayerLoggedIn = FALSE;
		}
	}];
}

- (void)playerAuthenticationDidChange {
	//Set new user status
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	self.gameCenterPlayerLoggedIn = localPlayer.authenticated;
	
	//Try to send unsent scores and achievements
	if (self.gameCenterPlayerLoggedIn) {
        //Register invite handler
        if ([presentingViewController respondsToSelector:@selector(registerInviteHandler)])
            [presentingViewController performSelector: @selector(registerInviteHandler)];
        
        //Start sync
		[self syncScores];
		[self syncAchievements];
	}
}

- (NSString *)localPlayerName {
	//Get player alias
	if (gameCenterPlayerLoggedIn) {
		GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
		return localPlayer.alias;
	}
	
	return nil;
}

-(NSString *) localPlayedID {
	//Get player alias
	if (gameCenterPlayerLoggedIn) {
		GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
		return localPlayer.playerID;
	}
	
	return nil;
}

-(void) showLeaderboardOver: (UIViewController<GKLeaderboardViewControllerDelegate> *) delegate Category: (int) cat Timescope: (int) timescope {
	if ([self isGameCenterAvailable] == FALSE)
		return;
	
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
		if (cat != -1)
			leaderboardController.category = [scoreCategories objectAtIndex: cat];
		if (timescope != -1)
			leaderboardController.timeScope = timescope == 0 ? GKLeaderboardTimeScopeToday : timescope == 1 ? GKLeaderboardTimeScopeWeek : GKLeaderboardTimeScopeAllTime;
        leaderboardController.leaderboardDelegate = delegate;	
        [delegate presentModalViewController: leaderboardController animated: YES];		
    }
    [leaderboardController release];
}

-(void) showAchievementsOver: (UIViewController<GKAchievementViewControllerDelegate> *) delegate {
	if ([self isGameCenterAvailable] == FALSE)
		return;
	
	GKAchievementViewController *achievementController = [[GKAchievementViewController alloc] init];
    if (achievementController != nil) {				
        achievementController.achievementDelegate = delegate;	
        [delegate presentModalViewController: achievementController animated: YES];		
    }
    [achievementController release];
}

#pragma mark Game kit communication

-(void) reportScore: (GameKitScore *) s {
	if ([self isGameCenterAvailable] == FALSE)
		return;
	
	NSString *category = [scoreCategories objectAtIndex: s.category];
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
    scoreReporter.value = (int64_t) s.value;
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		if (error != nil) {
			s.sent = FALSE;
        } else {
			s.sent = TRUE;
		}
		
		[self saveScores];
    }];
}

-(void) reportAchievement: (GameKitAchievement *) a {
	if ([self isGameCenterAvailable] == FALSE)
		return;
	
	NSString *identifier = [achievementIdentifiers objectAtIndex: a.identifier];
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
    if (achievement) {
		achievement.percentComplete = a.percentage;
		[achievement reportAchievementWithCompletionHandler:^(NSError *error) {
			if (error != nil) {
				a.sent = FALSE;
			} else {
				a.sent = TRUE;
			}
			
			[self saveAchievements];
		}];
    }
}

#pragma mark Other

-(NSString*) md5: (NSString*) str {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString  stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

@end