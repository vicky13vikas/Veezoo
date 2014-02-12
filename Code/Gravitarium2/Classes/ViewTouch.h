//
//  ViewTouch.h
//

#import "GLView.h"
#import "Geometry.h"

@class GLView;
@class Geometry;

@interface ViewTouch : NSObject {
	int touchID;
	bool active;
	float posX, posY;
	float lastX, lastY;
	float vectorUngle;
    float vectorSpeed;
}

#pragma mark Properties

@property (nonatomic) int touchID;
@property (nonatomic) bool active;
@property (nonatomic) float posX, posY;
@property (nonatomic) float lastX, lastY;
@property (nonatomic) float vectorUngle;
@property (nonatomic) float vectorSpeed;

#pragma mark Methods

-(id) initWithTouchID: (int) tid CoordX: (float) cx CoordY: (float) cy;

-(void) addCoordX:(float) cx CoordY:(float) cy;

-(void) endCoords;

-(void) newFrame;

@end
