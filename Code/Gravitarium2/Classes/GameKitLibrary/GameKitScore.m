//
//  GameKitScore.h
//

#import "GameKitScore.h"

@implementation GameKitScore

@synthesize value, category, sent;

-(id) initWithValue: (int) v Category: (int) c {
	if (self = [super init]) {
		self.value = v;
		self.category = c;
		self.sent = FALSE;
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
        self.value = [coder decodeIntegerForKey:@"value"];
        self.category = [coder decodeIntegerForKey:@"category"];
		self.sent = [coder decodeBoolForKey:@"sent"];
    }   
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:value forKey:@"value"];
    [coder encodeInteger:category forKey:@"category"];
	[coder encodeBool:sent forKey:@"sent"];
}

@end
