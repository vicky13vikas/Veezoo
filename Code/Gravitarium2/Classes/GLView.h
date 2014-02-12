//
//  GLView.h
//  Gravitarium2
//
//  Created by Robert Neagu on 11/3/10.
//  Copyright 2010 TotalSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GLViewController.h"
#import "OpenGLES2DView.h"
#import "Texture2D.h"
#import "Geometry.h"
#import "ViewTouch.h"
#import "Options.h"
#import "GameKitLibrary.h"

@class GLViewController;
@class Texture2D;
@class Geometry;
@class ViewTouch;
@class Options;

@interface GLView : OpenGLES2DView {
	//Parent
	GLViewController *parent;
    
	//Animation
	BOOL displayLinkSupported;
	id displayLink;
	NSTimer *timerScene;
	bool animating;

    //UI
    NSMutableArray *localViewTouches;
    NSMutableArray *remoteViewTouches;
    NSMutableArray *viewTouches;
    int currentFrame;
    int currentColor;
    int colorMax;
    GLfloat currentOpacity;
    
    //Resultants
    int lastLocalCount, lastRemoteCount;
    GLfloat resX, resY, resRadius, resDistance, resUngle, resSpeed, lastLocalResX, lastRemoteResX, lastLocalResY, lastRemoteResY;
}

#pragma mark - Properties

@property (nonatomic, assign) GLViewController *parent;
@property (nonatomic, retain) NSMutableArray *localViewTouches;
@property (nonatomic, retain) NSMutableArray *remoteViewTouches;
@property (nonatomic, assign) int currentColor;
@property (nonatomic, assign) float currentOpacity;

#pragma mark - ReadOnly Properties

@property (nonatomic, readonly) GLfloat screenWidth, screenHeight, realScreenWidth, realScreenHeight;
@property (nonatomic, readonly) GLfloat menuHotZone;

#pragma mark - Initialization

-(void) initializeObjects: (GLViewController*) p;

-(void) initColorPalette;

#pragma mark - Methods

void releaseScreenshotData(void *info, const void *data, size_t size);

-(void) captureOpenGLImage;

#pragma mark - Animation

-(void) startAnimation;

-(void) stopAnimation;

-(void) drawScene;

#pragma mark - Calculation

-(void) calculateFrame;

-(void) calculateFrameLocal: (bool) local StartIndex: (int) start StopIndex: (int) stop;

-(void) calculateTouches;

-(void) calculateResultants;

#pragma mark - Drawing

-(void) drawFrame;

-(void) drawOverlay: (float) opacity;

-(void) clearScreen;

@end