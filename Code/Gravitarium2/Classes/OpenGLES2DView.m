//
//  OpenGLES2DView.m
//

#import "OpenGLES2DView.h"

@implementation OpenGLES2DView

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

#pragma mark - FrameBuffer

- (BOOL)createFramebuffer {
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		return NO;
	}
	
	return YES;
}

- (id)initWithCoder:(NSCoder*)coder {
	if((self = [super initWithCoder:coder])) {
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
        
        //Screen scale (Retina support)
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            //Get screen scale
            float screenScale = [[UIScreen mainScreen] scale];
            
            //Debug
            NSLog(@"Using scale factor: %.2f", screenScale);
            
            //Set view scale
            [self setContentScaleFactor: screenScale];
            [eaglLayer setContentsScale: screenScale];
        }
        
		eaglLayer.opaque = TRUE;
        
        //TEMPORARY BUG FIX
        UIScreen *screen = [UIScreen mainScreen];
        if (screen.bounds.size.width >= 768 && screen.scale >= 2) {
            //Retina iPad
            eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys: kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        } else {
            //Everything else
            eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: TRUE], kEAGLDrawablePropertyRetainedBacking,  kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        }
        //TEMPORARY BUG FIX
        
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
			[self release];
			return nil;
		}
        
        //Debug
        NSLog(@"Using buffer size: %i x %i", backingWidth, backingHeight);
		
		//Setup buffer and perspective
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
		glViewport(0, 0, backingWidth, backingHeight);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrthof(0, backingWidth, 0, backingHeight, -1, 1);
		glMatrixMode(GL_MODELVIEW);
		
		//Clear background
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);
        
		//Set up draw mode
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		//Set up blending
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_DEPTH_TEST);
		
		//Set up addition opengles params
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
	
	return self;
}

@end
