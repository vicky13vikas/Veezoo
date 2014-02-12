//
//  GLView.m
//  Gravitarium2
//
//  Created by Robert Neagu on 11/3/10.
//  Copyright 2010 TotalSoft. All rights reserved.
//

#import "GLView.h"

@implementation GLView

#pragma mark - Structs

typedef struct {
    //Generic
    GLfloat speed;
    GLfloat speedTarget;
    GLfloat speedMin;
    GLfloat speedMax;
    GLfloat ungle;
    
    //Specific
    int target;
    int idle;

    //SuperFlow
    int superTarget;
    GLfloat superTargetX;
    GLfloat superTargetY;
} LineProps;

typedef struct {
    GLfloat red;
    GLfloat green;
    GLfloat blue;
    GLfloat alpha;
} LineColor;

typedef struct {
    GLfloat posX;
    GLfloat posY;
} LineVertex;

#pragma mark - Properties

@synthesize parent;

@synthesize localViewTouches;
@synthesize remoteViewTouches;
@synthesize currentColor;
@synthesize currentOpacity;

static LineProps props[5000];
static LineColor palette[1000];
static LineVertex vertices[10000];

static GLfloat targetX[10];
static GLfloat targetY[10];
static GLfloat vectorSpeed[10];
static GLfloat vectorUngle[10];

#pragma mark - ReadOnly Properties

-(GLfloat) screenWidth {
    return self.bounds.size.width;
}

-(GLfloat) screenHeight {
    return self.bounds.size.height;
}

-(GLfloat) realScreenWidth {
    return backingWidth;
}

-(GLfloat) realScreenHeight {
    return backingHeight;
}

-(GLfloat) menuHotZone {
    return 60;
}

#pragma mark - Initialization

- (void)initializeObjects: (GLViewController*) p {
	//Remember parent
	self.parent = p;
		
    //Diplay link
    displayLinkSupported = TRUE;
    
    //Props
    for (int i=0; i<5000; i++) {
        //Generic
        props[i].speed = 1;
        props[i].speedTarget = 1;
        props[i].speedMin = 1 + rand() % 2;
        props[i].speedMax = 20 + rand() % 15;
        props[i].ungle = rand() % 360;
        
        //Custom
        props[i].target = -1;
        props[i].idle = 0;
    }
    
    //Lines
    for (int i=0; i<10000; i+=2) {
        vertices[i].posX = self.realScreenWidth/2;
        vertices[i].posY = self.realScreenHeight/2;
        vertices[i+1].posX = vertices[i].posX;
        vertices[i+1].posY = vertices[i].posY;
    }
    
    //Palette
    [self initColorPalette];
    
    //Other
    localViewTouches = [[NSMutableArray alloc] init];
    remoteViewTouches = [[NSMutableArray alloc] init];
    currentFrame = 0;
    currentColor = 0;
    currentOpacity = 0;
}

-(void) initColorPalette {
    //Reset index
    colorMax = 0;
    
    //Initial color
	GLfloat red = 1;
	GLfloat green = 0;
	GLfloat blue = 0;
    
    //Other
	int colorPhase = 1;
	bool done = FALSE;
	
	do { 
		//Color cycle
		switch (colorPhase) {
			case 1:
				green+=0.01;
				if (green >= 1) {
					colorPhase++;
					green = 1;
				}
				break;
				
			case 2:
				red-=0.01;
				if (red <= 0) {
					colorPhase++;
					red = 0;
				}
				break;
				
			case 3:
				blue+=0.01;
				if (blue >= 1) {
					colorPhase++;
					blue = 1;
				}
				break;
				
			case 4:
				green-=0.01;
				if (green <= 0) {
					colorPhase++;
					green = 0;
				}
				break;
				
			case 5:
				red+=0.01;
				if (red >= 1) {
					colorPhase++;
					red = 1;
				}
				break;
				
			case 6:
				blue-=0.01;
				if (blue <= 0) {
					colorPhase=1;
					blue = 0;
					done = TRUE;
				}
				break;
		}
		
		//Remember color value
        palette[colorMax].red = red;
        palette[colorMax].green = green;
        palette[colorMax].blue = blue;
        palette[colorMax].alpha = 1;
		
		//Increment color maximum
		colorMax++;
	} while (!done);
    
    //Debug
    NSLog(@"Palette max color: %i", colorMax);
}

#pragma mark - Methods

-(void) captureOpenGLImage {
	//Stop the animation
	[self stopAnimation];
	
    //Memory needed
    NSInteger myDataLength = backingWidth * backingHeight * 4;
    
    //Allocate array and read pixels into it.
    GLuint *buffer = (GLuint *) malloc(myDataLength);
    glReadPixels(0, 0, backingWidth, backingHeight, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    //OpenGL renders “upside down” so swap top to bottom into new array.
    for(int y = 0; y < backingHeight / 2; y++) {
        for(int x = 0; x < backingWidth; x++) {
            //Swap top and bottom bytes
            GLuint top = buffer[y * backingWidth + x];
            GLuint bottom = buffer[(backingHeight - 1 - y) * backingWidth + x];
            buffer[(backingHeight - 1 - y) * backingWidth + x] = top;
            buffer[y * backingWidth + x] = bottom;
        }
    }
    
    //Make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, releaseScreenshotData);
    
    //Prep the ingredients
    const int bitsPerComponent = 8;
    const int bitsPerPixel = 4 * bitsPerComponent;
    const int bytesPerRow = 4 * backingWidth;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    //Make the cgimage
    CGImageRef imageRef = CGImageCreate(backingWidth, backingHeight, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    
    //Then make the UIImage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    //Save image to photo library
    UIImageWriteToSavedPhotosAlbum(myImage, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
}

void releaseScreenshotData(void *info, const void *data, size_t size) {
    free((void *)data);
};

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	//Restart animation
	[self startAnimation];
    
    //Toast
    [parent showToast: @"Screenshot saved to Photo Library"];
}

#pragma mark - Animation OpenGLES

-(void) startAnimation {
	if (!animating) {
		if (displayLinkSupported) {
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawScene)];
			[displayLink setFrameInterval: 1];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		} else {
			timerScene = [NSTimer scheduledTimerWithTimeInterval: 1.0f/60.0f target:self selector:@selector(drawScene) userInfo:nil repeats: YES];
		}
		
		//Animating
		animating = TRUE;
	}
}

- (void)stopAnimation {
	if (animating) {
		if (displayLinkSupported) {
			[displayLink invalidate];
			displayLink = nil;
		} else	{
			[timerScene invalidate];
			timerScene = nil;
		}
		
		//No longer animating
		animating = FALSE;
	}
}

-(void)drawScene {
	if (animating) {
        //Calculation and drawing        
        if (parent.animationPaused == FALSE || (parent.animationPaused == TRUE && [localViewTouches count] > 0)) {
            //Calculate current frame
            [self calculateFrame];
            
            //Draw current frame
            [self drawFrame];
        }
    }
}

#pragma mark - Calculation

-(void) calculateFrame {
    //Particle count
    int particleCount = [Options sharedOptions].particleCount;
    
    //Single or multiplayer
    if (parent.matchStarted) {
        if ([remoteViewTouches count] == 0) {
            //Local only
            [self calculateFrameLocal: TRUE StartIndex:0 StopIndex:particleCount];
        } else if ([localViewTouches count] == 0) {
            //Remote only
            [self calculateFrameLocal: FALSE StartIndex:0 StopIndex: particleCount];
        } else {
            //Local and remote
            [self calculateFrameLocal: TRUE StartIndex: 0 StopIndex: particleCount/2];
            [self calculateFrameLocal: FALSE StartIndex: particleCount/2 StopIndex: particleCount];
        }
    } else {
        //Local only
        [self calculateFrameLocal: TRUE StartIndex:0 StopIndex:particleCount];
    }
    
    //Particle color cycle
    if ([Options sharedOptions].particleColorCycle) {
        currentColor++;
        if(currentColor >= colorMax)
            currentColor = 0;
    }
    
    //Particle opacity
    currentOpacity += ([Options sharedOptions].particleAlpha - currentOpacity) / 60;
    
    //Sync players color
    if (parent.matchStarted && currentFrame % 300 == 0)
        [parent sendAction: G2_COLOR_SYNC Argument: currentColor PosX:0 PosY:0 Reliable: TRUE];
    
    //Increment current frame
    currentFrame++;
    
    //Overall time/connected reporting
    if ([[GameKitLibrary sharedGameKit] isGameCenterAvailable]) {
        if (currentFrame % 3600 == 0) {
            //Overall time spent
            int timeSpent = [[GameKitLibrary sharedGameKit] getBestScoreForCategory: 1];
            timeSpent++;
            
            //Save new values
            [[GameKitLibrary sharedGameKit] removeScoresForCategory: 1];
            [[GameKitLibrary sharedGameKit] addNewScore: timeSpent Category:1 Sync: TRUE];
            
            if (parent.matchStarted) {
                //Overall time connected
                int timeSpentConnected = [[GameKitLibrary sharedGameKit] getBestScoreForCategory: 2];                
                timeSpentConnected++;
                
                //Save new values
                [[GameKitLibrary sharedGameKit] removeScoresForCategory: 2];
                [[GameKitLibrary sharedGameKit] addNewScore: timeSpentConnected Category:2 Sync: TRUE];
            }
        }
    }
}

-(void) calculateFrameLocal: (bool) local StartIndex: (int) start StopIndex: (int) stop {
    //Local or Remote
    viewTouches = local ? localViewTouches : remoteViewTouches;
    
	//Touch management
	int i = 0;
	while (i<[viewTouches count]) {
        //New frame
		ViewTouch *vt = [viewTouches objectAtIndex: i];
        [vt newFrame];
        
        //Deactivation
		if (!vt.active)
			[viewTouches removeObjectAtIndex: i];
		else
			i++;
	}
    
    //Touches
    [self calculateTouches];
    
    //Resultants
    [self calculateResultants];
  
    //Calculation vars
    int vertexHead;
    int vertexTail;
    int targetID;
    int viewTouchesCount = [viewTouches count];
    
    GLfloat targetUngle;
    GLfloat targetDistance;
    GLfloat diff;
    GLfloat resSpeedX;
    GLfloat resSpeedY;
    GLfloat superPosX;
    GLfloat superPosY;
    GLfloat particleSpeed = [Options sharedOptions].particleSpeed;
    
    //Every particle
    for (int i=start; i<stop; i++) {
        //Calculate vertex indexes
        vertexHead = i * 2;
        vertexTail = vertexHead + 1;
        
        //Target
        if (viewTouchesCount == 1) {
            //******************************* Rocket *************************************//
            
            //Target speed
            if (i % 4 < 3) {
                //Max speed
                props[i].speedTarget = props[i].speedMax / 2;
            } else {
                //Measure distance and ungle
                targetUngle = [Geometry getPolarUngleDX: targetX[0] - vertices[vertexHead].posX DY: targetY[0] - vertices[vertexHead].posY];
                targetDistance = [Geometry getPolarVectorDX: targetX[0] - vertices[vertexHead].posX DY: targetY[0] - vertices[vertexHead].posY];    
                
                //Random ungle
                if (targetDistance < 150) {
                    props[i].ungle = targetUngle + 180;
                    props[i].speedTarget = props[i].speedMax;
                } else {
                    props[i].ungle += rand() % 30 - 15;
                    props[i].speedTarget = props[i].speedMin;
                }
            }
        } else if (viewTouchesCount == 2) {
            //******************************* Sparkle *************************************//
            
            //Measure distance and ungle
            targetUngle = [Geometry getPolarUngleDX: resX - vertices[vertexHead].posX DY: resY - vertices[vertexHead].posY];
            targetDistance = [Geometry getPolarVectorDX: resX - vertices[vertexHead].posX DY: resY - vertices[vertexHead].posY];     
            
            //Calculations
            if (targetDistance < props[i].speed) {
                props[i].idle = resRadius / 35 + rand() % 10;
            } else if (props[i].idle > 0) {
                props[i].idle--;
            } else if (targetDistance < resRadius) {                
                //High speed
                props[i].speedTarget = props[i].speedMax / 2;
                
                //Ungle
                props[i].ungle = targetUngle;
            } else {
                //Target speed
                props[i].speedTarget = props[i].speedMin;
                
                //Random movement
                props[i].ungle += rand() % 30 - 15;  
            }
        } else if (viewTouchesCount == 3) {
            //******************************* Flow *************************************//
            
            //Target speed
            props[i].speedTarget = props[i].speedMax;
            
            //Out of target limits
            if (props[i].target < 0 || props[i].target >= viewTouchesCount)
                props[i].target = 0;
            
            //Get current target id
            targetID = props[i].target;
            
            //Measure distance and ungle
            targetUngle = [Geometry getPolarUngleDX: targetX[targetID] - vertices[vertexHead].posX DY: targetY[targetID] - vertices[vertexHead].posY];
            targetDistance = [Geometry getPolarVectorDX: targetX[targetID] - vertices[vertexHead].posX DY: targetY[targetID]  - vertices[vertexHead].posY];
            
            //Go to the target ungle
            diff = targetUngle - props[i].ungle;
            if (diff > 180)
                targetUngle -= 360;
            else if (diff < -180)
                targetUngle += 360;
            props[i].ungle += (targetUngle - props[i].ungle) / 8;
            
            //Aquire next target
            if (targetDistance <= props[i].speed * 4 + (rand() % (int) (props[i].speed + 1)) * 2)
                props[i].target++;
        } else if (viewTouchesCount == 4) {
            //******************************* Superflow *************************************//
            
            //Target speed
            props[i].speedTarget = props[i].speedMax * 0.6;
            
            //Target
            superPosX = props[i].superTarget == 0 ? resX : props[i].superTargetX;
            superPosY = props[i].superTarget == 0 ? resY : props[i].superTargetY;
                        
            //Measure distance and ungle
            targetUngle = [Geometry getPolarUngleDX: superPosX - vertices[vertexHead].posX DY: superPosY - vertices[vertexHead].posY];
            targetDistance = [Geometry getPolarVectorDX: superPosX - vertices[vertexHead].posX DY: superPosY - vertices[vertexHead].posY];
            
            //Go to the target ungle
            diff = targetUngle - props[i].ungle;
            if (diff > 180)
                targetUngle -= 360;
            else if (diff < -180)
                targetUngle += 360;
            props[i].ungle += (targetUngle - props[i].ungle) / 8;
            
            //Aquire next target
            if (targetDistance <= props[i].speed * 4 + (rand() % (int) (props[i].speed + 1)) * 2) {
                if (props[i].superTarget == 0) {
                    float randUngle = ((float) (rand() % 360000)) / 1000.0f;  
                    props[i].superTargetX = resX + resRadius * cos([Geometry deg2Rad: randUngle]);
                    props[i].superTargetY = resY + resRadius * sin([Geometry deg2Rad: randUngle]); 
                    props[i].superTarget = 1;
                } else {
                    props[i].superTarget = 0;
                }
            }
        } else if (viewTouchesCount == 5) {
            //******************************* Freeze *************************************//
            
            //Decompose speed
            resSpeedX = resSpeed * cos([Geometry deg2Rad: resUngle]);
            resSpeedY = resSpeed * sin([Geometry deg2Rad: resUngle]);
            
            //Layers of speed
            resSpeedX = (resSpeedX * (1 + i % 4)) / 2;
            resSpeedY = (resSpeedY * (1 + i % 4)) / 2;
            
            //Move head
            vertices[vertexHead].posX += resSpeedX;
            vertices[vertexHead].posY += resSpeedY;
            
            //Move tail
            vertices[vertexTail].posX += resSpeedX;            
            vertices[vertexTail].posY += resSpeedY;
            
            //Change regular values
            props[i].speedTarget = resSpeed;
            props[i].ungle = resUngle;
        } else if (viewTouchesCount == 6) {
            //******************************* Circularium *************************************//
            
            //Target speed 
            props[i].speedTarget = props[i].speedMax / 3;
            
            //Get target id
            targetID = i % 6;
            
            //Target ungle
            targetUngle = [Geometry getPolarUngleDX: targetX[targetID] - vertices[vertexHead].posX DY: targetY[targetID] - vertices[vertexHead].posY] + rand() % 90;
            
            //Go to the target ungle
            diff = targetUngle - props[i].ungle;
            if (diff > 180)
                targetUngle -= 360;
            else if (diff < -180)
                targetUngle += 360;
            props[i].ungle += (targetUngle - props[i].ungle) / 8;
        } else if (viewTouchesCount == 7) {
            //******************************* Fish *************************************//
            
            //Target speed
            props[i].speedTarget = resSpeed * 3;
            if (props[i].speedTarget < 1)
                props[i].speedTarget = 1;
            
            //Target ungle
            targetUngle = resUngle - 90 + rand() % 180;
            
            //Go to target unfle
            diff = targetUngle - props[i].ungle;
            if (diff > 180)
                targetUngle -= 360;
            else if (diff < -180)
                targetUngle += 360;
            props[i].ungle += (targetUngle - props[i].ungle) / 8; 
        } else if (viewTouchesCount == 8) {
            //******************************* Vortex *************************************//
            
            //Target speed
            props[i].speedTarget = props[i].speedMin * (2 +  2 * ((resRadius - 150) / 100));
            
            //Set random target ungle
            targetUngle = [Geometry getPolarUngleDX: resX - vertices[vertexHead].posX DY: resY - vertices[vertexHead].posY] + rand() % 90 + 45;
            
            //Go to the target ungle
            diff = targetUngle - props[i].ungle;
            if (diff > 180)
                targetUngle -= 360;
            else if (diff < -180)
                targetUngle += 360;
            props[i].ungle += (targetUngle - props[i].ungle) / 8;  
            
            //Opacity override
            currentOpacity = 0.6;
        } else if (viewTouchesCount == 9) {
            //******************************* Lasers *************************************//
            
            //Get target id
            targetID = i % 9;
            
            //Target speed
            props[i].speedTarget = props[i].speedMax / 4;
            
            //Random ungle
            props[i].ungle += rand() % 30 - 15;
            
            //Tail
            vertices[vertexTail].posX = targetX[targetID];
            vertices[vertexTail].posY = targetY[targetID];
            
            //Head
            vertices[vertexHead].posX = vertices[vertexHead].posX + props[i].speed * particleSpeed * cos([Geometry deg2Rad: props[i].ungle]);
            vertices[vertexHead].posY = vertices[vertexHead].posY + props[i].speed * particleSpeed * sin([Geometry deg2Rad: props[i].ungle]);
            
            //Opacity override
            currentOpacity = 0.02;   
        } else if (viewTouchesCount == 10) {
            //******************************* Lightning *************************************//
            
            //Target speed
            props[i].speedTarget = props[i].speedMax * 1.5 * (resRadius / self.realScreenWidth);
            
            //Target ungle
            if (vertices[vertexHead].posX < resX)
                targetUngle = -90 + rand() % 180;
            else
                targetUngle = 90 + rand() % 180;
            
            //Go to target unfle
            diff = targetUngle - props[i].ungle;
            if (diff > 180)
                targetUngle -= 360;
            else if (diff < -180)
                targetUngle += 360;
            props[i].ungle += (targetUngle - props[i].ungle) / 6;  
        } else {
            //******************************* Brownian *************************************//            
                    
            //Random ungle
            if (props[i].idle == 0) {
                //Target speed
                props[i].speedTarget = props[i].speedMin;
                
                //Target ungle
                props[i].ungle += rand() % 30 - 15;
            } else if (props[i].idle > 0) {
                props[i].idle--;
            }
            
            //Reset
            props[i].superTarget = 0;
        }
        
        //Normalize particle ungle
        do {
            if (props[i].ungle < 0)
                props[i].ungle += 360;
            else if (props[i].ungle >= 360)
                props[i].ungle -= 360;
        } while (props[i].ungle < 0 || props[i].ungle >= 360);
        
        //Go to target speed
        if (props[i].speed < props[i].speedTarget)
            props[i].speed += (props[i].speedTarget - props[i].speed) / 15;
        else
            props[i].speed += (props[i].speedTarget - props[i].speed) / 30;            
        
        //Tail to head movement
        if (viewTouchesCount != 5 && viewTouchesCount != 9) {
            //Move line tail
            vertices[vertexTail].posX =  vertices[vertexHead].posX;
            vertices[vertexTail].posY = vertices[vertexHead].posY;
        
            //Move line head
            vertices[vertexHead].posX = vertices[vertexHead].posX + props[i].speed * particleSpeed * cos([Geometry deg2Rad: props[i].ungle]);
            vertices[vertexHead].posY = vertices[vertexHead].posY + props[i].speed * particleSpeed * sin([Geometry deg2Rad: props[i].ungle]);
        }
        
        //Recycle edge particles
        if (viewTouchesCount == 1 && i % 4 < 3) {
            //Out of screen
            if (vertices[vertexTail].posX > self.realScreenWidth || vertices[vertexTail].posX < 0 || vertices[vertexTail].posY > self.realScreenHeight || vertices[vertexTail].posY < 0) {                
                //Launch position
                vertices[vertexHead].posX = targetX[0];
                vertices[vertexHead].posY = targetY[0];
                vertices[vertexTail].posX = targetX[0];
                vertices[vertexTail].posY = targetY[0];
                
                //Launch ungle
                if (vectorSpeed[0] < 1)
                    props[i].ungle = ((float) (rand() % 360000)) / 1000.0f;               
                else
                    props[i].ungle = vectorUngle[0] - 30 + ((float) (rand() % 60000)) / 1000.0f;
                
                //Initial speed    
                props[i].speed = 0;
            }
        } else if (viewTouchesCount == 4) {
            //Nothing
        } else if (viewTouchesCount == 5) {
            //Nothing
        } else if (viewTouchesCount == 8) {
            //Out of screen
            if (vertices[vertexTail].posX > self.realScreenWidth || vertices[vertexTail].posX < 0 || vertices[vertexTail].posY > self.realScreenHeight || vertices[vertexTail].posY < 0) {
                //Launch position
                vertices[vertexHead].posX = resX;
                vertices[vertexHead].posY = resY;
                vertices[vertexTail].posX = resX;
                vertices[vertexTail].posY = resY;
                
                //Props
                props[i].speed = 0;
            }
        } else {
            //Horizontal limit        
            if (vertices[vertexTail].posX > self.realScreenWidth) {
                vertices[vertexHead].posX = vertices[vertexTail].posX - self.realScreenWidth;
                vertices[vertexTail].posX = vertices[vertexHead].posX;    
            } else if (vertices[vertexTail].posX < 0) {
                vertices[vertexHead].posX = self.realScreenWidth + vertices[vertexTail].posX;
                vertices[vertexTail].posX = vertices[vertexHead].posX;
            }
            
            //Vertical limit      
            if (vertices[vertexTail].posY > self.realScreenHeight) {
                vertices[vertexHead].posY = vertices[vertexTail].posY - self.realScreenHeight;
                vertices[vertexTail].posY = vertices[vertexHead].posY;    
            } else if (vertices[vertexTail].posY < 0) {
                vertices[vertexHead].posY = self.realScreenHeight + vertices[vertexTail].posY;
                vertices[vertexTail].posY = vertices[vertexHead].posY;
            }
        }
    }
}

-(void) calculateTouches {
    for (int i=0; i<[viewTouches count]; i++) {
        ViewTouch *vt = [viewTouches objectAtIndex: i];
        targetX[i] = vt.posX;
        targetY[i] = vt.posY;
        vectorSpeed[i] = vt.vectorSpeed;
        vectorUngle[i] = vt.vectorUngle;
    }
}

-(void) calculateResultants {
    //Exit
    if ([viewTouches count] == 0) {
        resX = self.realScreenWidth/2;
        resY = self.realScreenHeight/2;
        resRadius = 0;
        resUngle = 0;
        resSpeed = 0;
        
        return;
    }
    
    //Resultants
    ViewTouch *vt = [viewTouches objectAtIndex: 0];
    resX = vt.posX;
    resY = vt.posY;
    
    //Every touch
    for (int i=1; i<[viewTouches count]; i++) {
        ViewTouch *vt = [viewTouches objectAtIndex: i];
        resX += vt.posX;
        resY += vt.posY;
    }
    
    //Divide sum
    resX = resX / [viewTouches count];
    resY = resY / [viewTouches count];
    
    //Speed
    if (viewTouches == localViewTouches) {
        if (lastLocalCount != [viewTouches count])
            resSpeed = 0;
        else
            resSpeed = [Geometry getPolarVectorDX: resX - lastLocalResX DY: resY - lastLocalResY];
    
        //Ungle
        if (resSpeed > 1) 
            resUngle = [Geometry getPolarUngleDX: resX - lastLocalResX DY: resY - lastLocalResY];
    } else if (viewTouches == remoteViewTouches) {
        if (lastRemoteCount != [viewTouches count])
            resSpeed = 0;
        else
            resSpeed = [Geometry getPolarVectorDX: resX - lastRemoteResX DY: resY - lastRemoteResY]; 
        
        //Ungle
        if (resSpeed > 1) 
            resUngle = [Geometry getPolarUngleDX: resX - lastRemoteResX DY: resY - lastRemoteResY];
    }
    
    //Distance
    resDistance = 0;
    for (int i=0; i<[viewTouches count]; i++) {
        ViewTouch *vtLeft = [viewTouches objectAtIndex: i];
        for (int j=0; j<[viewTouches count]; j++) {
            ViewTouch *vtRight = [viewTouches objectAtIndex: j];
            float distance = [Geometry getPolarVectorDX: vtLeft.posX-vtRight.posX DY:vtLeft.posY-vtRight.posY];
            if (distance > resDistance)
                resDistance = distance;
        }
    }
    
    //Radius
    resRadius = resDistance / 2;
    
    //Remember last stuff
    if (viewTouches == localViewTouches) {
        lastLocalResX = resX;
        lastLocalResY = resY;
        lastLocalCount = [viewTouches count];
    } else if (viewTouches == remoteViewTouches) {
        lastRemoteResX = resX;
        lastRemoteResY = resY;
        lastRemoteCount = [viewTouches count];
    }
}

#pragma mark - Drawing

-(void) drawFrame {	    
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    //Enable vertex array
	glEnableClientState(GL_VERTEX_ARRAY);
    
    //Enagle blending
    glEnable(GL_BLEND);
    
    //Clear background
    [self drawOverlay: 1.0f - [Options sharedOptions].particleTail];
    
    //Color
    GLfloat red = [Options sharedOptions].particleColorCycle ? palette[currentColor].red : [Options sharedOptions].particleRed;
    GLfloat green = [Options sharedOptions].particleColorCycle ? palette[currentColor].green : [Options sharedOptions].particleGreen;
    GLfloat blue = [Options sharedOptions].particleColorCycle ? palette[currentColor].blue : [Options sharedOptions].particleBlue;
    GLfloat alpha = currentOpacity;
    
    //Set line color
    glColor4f(red, green, blue, alpha);
    
    //Set line width
    glLineWidth([Options sharedOptions].particleSize);

    //Draw lines
    glVertexPointer(2, GL_FLOAT, sizeof(LineVertex), &vertices[0]);
    glDrawArrays(GL_LINES, 0, [Options sharedOptions].particleCount*2);

	//Render framebuffer to screen
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer: GL_RENDERBUFFER_OES];
}

-(void) drawOverlay: (float) opacity {
    //Values
	GLfloat minX = 0;
	GLfloat minY = 0;
	GLfloat maxX = self.realScreenWidth;
	GLfloat maxY = self.realScreenHeight;

    //Define triangles
	GLfloat vert[8]; vert[0] = maxX; vert[1] = maxY; vert[2] = minX; vert[3] = maxY; vert[4] = minX; vert[5] = minY; vert[6] = maxX; vert[7] = minY;
    
    //Color
	glColor4f(0.0f, 0.0f, 0.0f, opacity);
    
    //Draw triangles
	glVertexPointer (2, GL_FLOAT , 0, vert);	
	glDrawArrays (GL_TRIANGLE_FAN, 0, 4);
}

-(void) clearScreen {
	//Draw on framebuffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    //Clear screen
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
	//Render framebuffer to screen
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer: GL_RENDERBUFFER_OES];
}

#pragma mark - OS Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		//Get touch ID
		int touchID = (int)(void*)touch;
		
		//Invert coordinates
		CGPoint cgp = [touch locationInView: self];
		cgp.y = self.screenHeight - cgp.y;
        
        //Retina support
        cgp.x *= self.contentScaleFactor;
        cgp.y *= self.contentScaleFactor;
		
		//Cleanup touches with same id
		int i = 0;
		while (i<[localViewTouches count]) {
			ViewTouch *t = [localViewTouches objectAtIndex: i];
			if (t.touchID == touchID)
				[localViewTouches removeObjectAtIndex: i];
			else
				i++;
		}
        
        //Check corners
        if ((cgp.x < self.menuHotZone && cgp.y < self.menuHotZone) || (cgp.x < self.menuHotZone && cgp.y > self.realScreenHeight - self.menuHotZone) || (cgp.x > self.realScreenWidth - self.menuHotZone && cgp.y < self.menuHotZone) || (cgp.x > self.realScreenWidth - self.menuHotZone && cgp.y > self.realScreenHeight - self.menuHotZone)) {
            [parent showMenu];
        } else {
            //Controls frame
            CGRect controlsFrame = parent.controlsViewController.view.frame;
            
            //Check controls frame
            if (self.screenHeight - cgp.y < controlsFrame.origin.y) {
                //Hide menu
                if (parent.animationPaused == FALSE && parent.menuVisible == TRUE)
                    [parent hideControlsMenu];
                
                //Initiate view touch
                ViewTouch *t = [[ViewTouch alloc] initWithTouchID: touchID CoordX: cgp.x CoordY: cgp.y];
                [localViewTouches insertObject: t atIndex: [localViewTouches count]];
                [t release];
                
                //Network send
                if (parent.matchStarted)
                    [parent sendAction: G2_TOUCH_ADD Argument: touchID PosX: cgp.x PosY: cgp.y Reliable: TRUE];
            }
        }
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
		//Get touch ID
		int touchID = (int)(void*)touch;
		
		//Invert coordinates
		CGPoint cgp = [touch locationInView: self];
		cgp.y = self.screenHeight - cgp.y;
        
        //Retina support
        cgp.x *= self.contentScaleFactor;
        cgp.y *= self.contentScaleFactor;
		
		//Find touch
		for (int i=0; i<[localViewTouches count]; i++) {
			ViewTouch *t = [localViewTouches objectAtIndex: i];
            
			if (t.touchID == touchID) {
                //Add coord
				[t addCoordX: cgp.x CoordY: cgp.y];
                
                //Network send
                if (parent.matchStarted)
                    [parent sendAction: G2_TOUCH_MOVE Argument: touchID PosX: cgp.x PosY: cgp.y Reliable: FALSE];
			}
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		//Get touch ID
		int touchID = (int)(void*)touch;
		
		//Find touch
		for (int i=0; i<[localViewTouches count]; i++) {
			ViewTouch *t = [localViewTouches objectAtIndex: i];
            
			if (t.touchID == touchID) {
                //End coords
				[t endCoords];
             
                //Network send
                if (parent.matchStarted)
                    [parent sendAction: G2_TOUCH_DELETE Argument: touchID PosX: t.posX PosY: t.posY Reliable: TRUE];
            }
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		//Get touch ID
		int touchID = (int)(void*)touch;
		
		//Find touch
		for (int i=0; i<[localViewTouches count]; i++) {
			ViewTouch *t = [localViewTouches objectAtIndex: i];
            
			if (t.touchID == touchID) {
                //End coords
				[t endCoords];
                
                //Network send
                if (parent.matchStarted)
                    [parent sendAction: G2_TOUCH_DELETE Argument: touchID PosX: t.posX PosY: t.posY Reliable: TRUE];
            }
		}
	}
}

#pragma mark - Memory management

- (void)dealloc {
	//Debug
	NSLog(@"[GLView deallocated]");
    
    //Release
    [localViewTouches release];
    [remoteViewTouches release];

	//Super
	[super dealloc];
}

@end
