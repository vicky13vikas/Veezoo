//
//  ParticleAtlasItem.h
//

#import "Geometry.h"
#import "GLView.h"

@class Geometry;
@class GLView;

@interface ParticleAtlasItem : NSObject {
	GLfloat x, y, w, h, cx1, cy1, cx2, cy2;
}

//Pixel coordinates
@property(nonatomic) GLfloat x, y, w, h;

//OpenGL coordinates
@property(nonatomic) GLfloat cx1, cy1, cx2, cy2;

//Methods
-(id) initX: (GLfloat) posX Y: (GLfloat) posY W: (GLfloat) width H: (GLfloat) height SW: (GLfloat) sheetWidth SH: (GLfloat) sheetHeight;

@end
