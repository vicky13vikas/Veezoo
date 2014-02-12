//
//  ParticleAtlas.h
//

#import "Geometry.h"
#import "ParticleAtlasItem.h"
#import "Texture2D.h"

@class Geometry;
@class ParticleAtlasItem;
@class Texture2D;

@interface ParticleAtlas : NSObject<NSXMLParserDelegate> {
	//Parser
	bool isKeyTag;
	bool isTextureRect;
	bool isStringTag;
	
	//Atlas items
	NSMutableDictionary *items;
	
	//Normal texture
	Texture2D *texture;
	
	//Current texture
	NSString *currentTexture;
	
	//Size
	float sheetWidth;
	float sheetHeight;
	
	//OpenGL
	GLfloat vertices[12000];
	GLfloat coordinates[12000];
	
	//OpenGL Counters
	int vertexCount;
}

//Properties

@property (nonatomic, retain) NSMutableDictionary *items;
@property (nonatomic, retain) Texture2D *texture;
@property (nonatomic, retain) NSString *currentTexture;
@property (nonatomic) float sheetWidth;
@property (nonatomic) float sheetHeight;

//Methods

-(id) initWithFile: (NSString *) fileName Extension: (NSString *) fileExtension NormalWidth: (float) normalWidth;

-(void) addObjectID: (int) id PosX: (float) x PosY: (float) y Scale: (float) s;

-(void) clearObjects;

-(void) renderObjects;

@end