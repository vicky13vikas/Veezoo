//
//  ParticleAtlasItem.m
//  AstroNut
//

#import "ParticleAtlasItem.h"

@implementation ParticleAtlasItem

@synthesize x, y, w, h;

@synthesize cx1, cx2, cy1, cy2;

-(id) initX: (GLfloat) posX Y: (GLfloat) posY W: (GLfloat) width H: (GLfloat) height SW: (GLfloat) sheetWidth SH: (GLfloat) sheetHeight {
	if ((self = [super init])) {
		//Pixel coordinates
		self.x = posX;
		self.y = posY;
		self.w = width;
		self.h = height;
		
		//OpenGL coordinates
		self.cx1 = posX / sheetWidth;
		self.cy1 = posY / sheetHeight;
		self.cx2 = self.cx1 + (width / sheetWidth);
		self.cy2 = self.cy1 + (height / sheetHeight);
	}
	
	return self;
}

@end