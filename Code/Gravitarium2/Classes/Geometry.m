//
//  Geometry.m
//

#import "Geometry.h"
#import <math.h>

@implementation Geometry

+(float) getPolarVectorDX: (float) dx DY: (float) dy {
	return sqrt(dx*dx + dy*dy);
}

+(float) getPolarUngleDX: (float) dx DY: (float) dy {
	if (dx > 0 && dy >= 0)
		return [self rad2Deg: atan(dy/dx)];
	else if (dx > 0 && dy < 0)
		return [self rad2Deg: atan(dy/dx)] + 360;
	else if (dx  < 0)
		return [self rad2Deg: atan(dy/dx)] + 180;
	else if (dx == 0 && dy > 0)
		return 90;
	else if (dx == 0 && dy < 0)
		return 270;
	return 0;
}

+(float) deg2Rad: (float) degrees{
	return degrees * M_PI / 180;
}

+(float) rad2Deg: (float) radians{
	return radians * 180 / M_PI;
}

@end
