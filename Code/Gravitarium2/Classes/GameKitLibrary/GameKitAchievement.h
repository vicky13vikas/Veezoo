//
//  GameKitAchievement.h
//

#import <Foundation/Foundation.h>

@interface GameKitAchievement : NSObject {
	int identifier, points, total;
	bool sent;
}

@property (nonatomic, assign) int identifier, points, total;
@property (nonatomic, assign) bool sent;

@property (nonatomic, readonly) bool completed;
@property (nonatomic, readonly) int percentage;

-(id) initWithIndentifier: (int) i Points: (int) p Total: (int) t;

@end
