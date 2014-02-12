//
//  AtlasItem.m
//  AstroNut
//

#import "AtlasItem.h"
#import "Geometry.h"

@implementation AtlasItem

//Standard
@synthesize x;
@synthesize y;
@synthesize w;
@synthesize h;

@synthesize cx1;
@synthesize cx2;
@synthesize cy1;
@synthesize cy2;

@synthesize a1;
@synthesize a2;
@synthesize a3;
@synthesize a4;

@synthesize diag;

-(id) initX: (float) ix Y: (float) iy W: (float) iw H: (float) ih SW: (float) sw SH: (float) sh {
	if ((self = [super init])) {
		//Pixel coordinates
		self.x = ix;
		self.y = iy;
		self.w = iw;
		self.h = ih;
		
		//OpenGL coordinates
		self.cx1 = ix / sw;
		self.cy1 = iy / sh;
		self.cx2 = self.cx1 + (iw / sw);
		self.cy2 = self.cy1 + (ih / sh);
		
		self.a3 = [Geometry getPolarUngleDX: iw/2 DY: ih/2];
		self.a4 = [Geometry getPolarUngleDX: -iw/2 DY: ih/2];
		self.a1 = [Geometry getPolarUngleDX: -iw/2 DY: -ih/2];
		self.a2 = [Geometry getPolarUngleDX: iw/2 DY: -ih/2];
		
		self.diag=sqrt ((self.w/2)*(self.w/2) + (self.h/2)*(self.h/2));
	}
	
	return self;
}


@end