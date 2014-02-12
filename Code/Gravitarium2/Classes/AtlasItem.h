//
//  AtlasItem.h
//  AstroNut
//

#import "Geometry.h"

@class Geometry;

@interface AtlasItem : NSObject {
	float x, y, w, h, cx1, cy1, cx2, cy2, a1, a2, a3, a4, diag;
}

//Pixel coordinates
@property(nonatomic) float x;
@property(nonatomic) float y;
@property(nonatomic) float w;
@property(nonatomic) float h;

//OpenGL coordinates
@property(nonatomic) float cx1;
@property(nonatomic) float cy1;
@property(nonatomic) float cx2;
@property(nonatomic) float cy2;

@property(nonatomic) float a1;
@property(nonatomic) float a2;
@property(nonatomic) float a3;
@property(nonatomic) float a4;

@property(nonatomic) float diag;

//Methods
-(id) initX: (float) ix Y: (float) iy W: (float) iw H: (float) ih SW: (float) sw SH: (float) sh;

@end
