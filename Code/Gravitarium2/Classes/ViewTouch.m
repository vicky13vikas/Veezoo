//
//  ViewTouch.m
//

#import "ViewTouch.h"

@implementation ViewTouch

#pragma mark Properties

@synthesize touchID, active, posX, posY, lastX, lastY, vectorUngle, vectorSpeed;

#pragma mark Methods

-(id) initWithTouchID: (int) tid CoordX: (float) cx CoordY: (float) cy {
    self = [super init];
    
	if (self) {
		touchID = tid;
		posX = cx; posY = cy;
        lastX = cx; lastY = cy;
		active = TRUE;
	}
	
	return self;
}

-(void) addCoordX:(float) cx CoordY:(float) cy{
	//Update current position
	posX = cx;
	posY = cy;
}

-(void) endCoords {
	//No longer active
	active = FALSE;
}

-(void) newFrame {
    //Get new values
    vectorUngle = [Geometry getPolarUngleDX: lastX-posX DY: lastY-posY];    
    vectorSpeed = [Geometry getPolarVectorDX: lastX-posX DY: lastY-posY]; 

    //Reset
    lastX = posX;
    lastY = posY;
}

@end
