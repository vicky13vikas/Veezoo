//
//  Atlas.h
//  AstroNut
//
//	Support for Texture2D Atlas Sheet (Max: 2048px texture width; Max: 1000 triangles rendered)
//

#import <Foundation/Foundation.h>
#import "Geometry.h"
#import "AtlasItem.h"
#import "Texture2D.h"

@class Geometry;
@class AtlasItem;
@class Texture2D;

@interface Atlas : NSObject<NSXMLParserDelegate> {
	//Parser
	bool isKeyTag;
	bool isTextureRect;
	bool isStringTag;
	NSString *currentTexture;
	
	//Atlas Items
	NSMutableDictionary *items;
	
	//Normal Texture
	Texture2D *texture;
	
	//Size
	float sheetWidth;
	float sheetHeight;
	
	//OpenGL
	GLfloat vertices[12000];
	GLfloat coordinates[12000];
	GLfloat colors[24000];
	
	//OpenGL Counters
	int vertexCount;
	int colorsCount;
}

//Properties
@property (nonatomic, retain) NSString* currentTexture;
@property (nonatomic, retain) Texture2D *texture;
@property (nonatomic, retain) NSMutableDictionary *items;
@property (nonatomic) float sheetWidth;
@property (nonatomic) float sheetHeight;

//Methods
-(id) initWithFile: (NSString *) fileName Extension: (NSString *) fileExtension NormalWidth: (float) normalWidth;

//-(void) loadPVRTexture:(NSString *)name;

-(void) flipObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y;

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y;

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r;

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r Alpha: (float) a;

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r Scale: (float) s;

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r Scale: (float) s Alpha: (float) a;

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r Scale: (float) s Alpha: (float) a Flip: (bool) f;

-(void) clearObjects;

-(void) renderObjects;

@end
