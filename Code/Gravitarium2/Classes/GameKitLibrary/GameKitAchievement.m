//
//  GameKitAchievement.h
//

#import "GameKitAchievement.h"

@implementation GameKitAchievement

@synthesize identifier, sent, points, total, percentage;

-(id) initWithIndentifier: (int) i Points: (int) p Total: (int) t {
	if (self = [super init]) {
		self.identifier = i;
		self.points = p;
		self.total = t;
		self.sent = FALSE;
	}
	
	return self;
}

-(id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
        self.identifier = [coder decodeIntegerForKey:@"identifier"];
		self.total = [coder decodeIntegerForKey: @"total"];
		self.points = [coder decodeIntegerForKey: @"points"];
		self.sent = [coder decodeBoolForKey:@"sent"];
    }   
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:identifier forKey:@"identifier"];
	[coder encodeInteger:total forKey:@"total"];
	[coder encodeInteger:points forKey:@"points"];
	[coder encodeBool:sent forKey:@"sent"];
}

-(void) setPoints:(int) value {
	if (value > total)
		points = total;
	else
		points = value;
}

-(bool) completed {
	return points >= total;
}

-(int) percentage {
	return (points / total) * 100;
}

@end
