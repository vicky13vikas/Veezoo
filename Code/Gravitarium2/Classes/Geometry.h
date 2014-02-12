//
//  Geometry.h
//

#import <Foundation/Foundation.h>
#import <math.h>

@interface Geometry : NSObject {
}

+(float) getPolarVectorDX: (float) dx DY: (float) dy;

+(float) getPolarUngleDX: (float) dx DY: (float) dy;

+(float) deg2Rad: (float) degrees;

+(float) rad2Deg: (float) radians;

@end
