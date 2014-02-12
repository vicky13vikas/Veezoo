#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_A8,
} Texture2DPixelFormat;

@interface Texture2D : NSObject {

@private
	GLuint						_name;
	CGSize						_size;
	NSUInteger					_width,
								_height;
	Texture2DPixelFormat		_format;
	GLfloat						_maxS,
								_maxT;
}

- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size;

@property(readonly) Texture2DPixelFormat pixelFormat;
@property(readonly) NSUInteger pixelsWide;
@property(readonly) NSUInteger pixelsHigh;
@property(readonly) GLuint name;
@property(readonly, nonatomic) CGSize contentSize;
@property(readonly) GLfloat maxS;
@property(readonly) GLfloat maxT;

@end

@interface Texture2D (Drawing)

- (void) drawInRect: (CGRect) rect;
- (void) drawAtPoint: (CGPoint) position;
- (void) drawAtPoint: (CGPoint) position rotation:(float) rotation;
- (void) drawAtPoint: (CGPoint) position rotation:(float) rotation alpha:(float) alpha;
- (void) drawAtPoint: (CGPoint) position rotation:(float) rotation scale:(CGPoint)scale alpha:(float) alpha;

@end

@interface Texture2D (Image)

- (id) initWithImage:(UIImage *)uiImage;

@end

@interface Texture2D (Text)

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;

@end
