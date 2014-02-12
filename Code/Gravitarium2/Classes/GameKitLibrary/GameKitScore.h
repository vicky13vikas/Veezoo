//
//  GameKitScore.h
//

#import <Foundation/Foundation.h>

@interface GameKitScore : NSObject {
	int value, category;
	bool sent;
}

@property (nonatomic, assign) int value, category;
@property (nonatomic, assign) bool sent;

-(id) initWithValue: (int) v Category: (int) c;

@end
