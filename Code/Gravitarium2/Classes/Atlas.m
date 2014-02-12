//
//  Atlas.m
//  AstroNut
//

#import "Geometry.h"
#import "Atlas.h"
#import "AtlasItem.h"
#import "Texture2D.h"

@implementation Atlas

@synthesize items;
@synthesize texture;
@synthesize currentTexture;
@synthesize sheetWidth;
@synthesize sheetHeight;

#pragma mark Initialization

-(id) initWithFile: (NSString *) fileName Extension: (NSString *) fileExtension NormalWidth: (float) normalWidth {
	self = [super init];
    
    if (self) {
		//Allocate atlas items
		items = [[NSMutableDictionary alloc] init];
		
		//Initialize countes
		[self clearObjects];
		
		//Initialize normal texture
		texture = [[Texture2D alloc] initWithImage: [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource: fileName ofType: fileExtension]]];
		
		//Get texture size
		sheetWidth = texture.pixelsWide;
		sheetHeight = texture.pixelsHigh;
		
		//Get texture xml data
		NSData *xmlData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: fileName ofType: @"xml"]];
		
		//Create parser
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData: xmlData];
		
		//Set self delegate
		[parser setDelegate:self];
		
		//Parser options
		[parser setShouldProcessNamespaces:NO];
		[parser setShouldReportNamespacePrefixes:NO];
		[parser setShouldResolveExternalEntities:NO];
		
		//Parse
		[parser parse];
		
		//Release
		[parser release];
		parser = nil;
		
		//Flags
		isKeyTag = FALSE;
		isTextureRect = FALSE;
		isStringTag = FALSE;
	}
	
	return self;
}

#pragma mark Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	if ([elementName isEqualToString: @"key"]) 
		isKeyTag = TRUE;
	else if ([elementName isEqualToString: @"string"])
		isStringTag = TRUE;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     	
	if ([elementName isEqualToString: @"key"]) 
		isKeyTag = FALSE;
	else if ([elementName isEqualToString: @"string"]) {
		isStringTag = FALSE;
		isTextureRect = FALSE;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	if (isKeyTag) {
		NSRange range = [string rangeOfString: @".png"];
		if (range.location != NSNotFound) {
			self.currentTexture = [string stringByReplacingOccurrencesOfString: @".png" withString: @""];
			self.currentTexture = [self.currentTexture stringByReplacingOccurrencesOfString: @"@2x" withString: @""];
		}
		
		if ([string isEqualToString: @"textureRect"])
			isTextureRect = TRUE;
	} else if (isStringTag && isTextureRect) {
		NSRange range = [string rangeOfString: @"{{"];
		if (range.location != NSNotFound) {
			NSArray *comps = [string componentsSeparatedByString:@","];
			if ([comps count] == 4) {
				NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
				
				NSString *xstr = (NSString *) [comps objectAtIndex: 0];
				NSString *ystr = (NSString *) [comps objectAtIndex: 1];
				NSString *wstr = (NSString *) [comps objectAtIndex: 2];
				NSString *hstr = (NSString *) [comps objectAtIndex: 3];
				
				int x = [[xstr stringByTrimmingCharactersInSet:nonDigits] intValue];
				int y = [[ystr stringByTrimmingCharactersInSet:nonDigits] intValue];
				int w = [[wstr stringByTrimmingCharactersInSet:nonDigits] intValue];
				int h = [[hstr stringByTrimmingCharactersInSet:nonDigits] intValue];
				
				AtlasItem* ai = [[AtlasItem alloc] initX: x Y: y W: w H: h SW: sheetWidth SH: sheetHeight];
				[items setObject:ai forKey: self.currentTexture];
				[ai release];
			}
		}
	}
}

#pragma mark Renderer

-(void) flipObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y {
	[self addObject: key PosX: x PosY: y Rotation: 0.0 Scale: 1.0 Alpha: 1.0 Flip: TRUE];
}

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y {
	[self addObject: key PosX: x PosY: y Rotation: 0.0 Scale: 1.0 Alpha: 1.0 Flip: FALSE];
}

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r {
	[self addObject: key PosX: x PosY: y Rotation: r Scale: 1.0 Alpha: 1.0 Flip: FALSE];
}

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r Alpha: (float) a {
	[self addObject: key PosX: x PosY: y Rotation: r Scale: 1.0 Alpha: a Flip: FALSE];
}

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r Scale: (float) s {
	[self addObject: key PosX: x PosY: y Rotation: r Scale: s Alpha: 1.0 Flip: FALSE];
}

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r Scale: (float) s Alpha: (float) a {
	[self addObject: key PosX: x PosY: y Rotation: r Scale: s Alpha: a Flip: FALSE];
}

-(void) addObject: (NSString *) key PosX: (CGFloat) x PosY: (CGFloat) y Rotation: (float) r Scale: (float) s Alpha: (float) a Flip: (bool) f {
	//Get atlas object by key
	AtlasItem* ai = [items objectForKey: key];

	//Set texture alpha
	for (int l=0; l<24; l++) 
		colors[colorsCount + l] = a;
	
	//Increment color count
	colorsCount += 24;
	
	//Set texture coordinates
	coordinates[vertexCount + 0] = ai.cx1;
	coordinates[vertexCount + 1] = ai.cy2;
	coordinates[vertexCount + 2] = ai.cx2;
	coordinates[vertexCount + 3] = ai.cy2;
	coordinates[vertexCount + 4] = ai.cx1;
	coordinates[vertexCount + 5] = ai.cy1;
	coordinates[vertexCount + 6] = ai.cx2;
	coordinates[vertexCount + 7] = ai.cy2;
	coordinates[vertexCount + 8] = ai.cx1;
	coordinates[vertexCount + 9] = ai.cy1;
	coordinates[vertexCount + 10] = ai.cx2;
	coordinates[vertexCount + 11] = ai.cy1;
	
	//Calculate quad ungles	
	float a1 = r + ai.a1;
	float a2 = r + ai.a2;
	float a3 = r + ai.a3;
	float a4 = r + ai.a4;
	
	//Flip
	if (f) {
		//Temp coords
		float t1 = a1;
		float t2 = a2;
		
		//Reverse coords
		a1 = a4;
		a2 = a3;
		
		//Reverse coords
		a4 = t1;
		a3 = t2;
	}
	
	//Apply screen scale (Retina support)
	x = x * 1;//view.screenScale;
	y = y * 1;//view.screenScale;
	
	//Calculate quad points
	GLfloat x1 = x + ai.diag * s * cos([Geometry deg2Rad: a1]);
	GLfloat y1 = y + ai.diag * s * sin([Geometry deg2Rad: a1]);
	GLfloat x2 = x + ai.diag * s * cos([Geometry deg2Rad: a2]);
	GLfloat y2 = y + ai.diag * s * sin([Geometry deg2Rad: a2]);
	GLfloat x3 = x + ai.diag * s * cos([Geometry deg2Rad: a4]);
	GLfloat y3 = y + ai.diag * s * sin([Geometry deg2Rad: a4]);
	GLfloat x4 = x + ai.diag * s * cos([Geometry deg2Rad: a3]);
	GLfloat y4 = y + ai.diag * s * sin([Geometry deg2Rad: a3]);
	
	//Set texture vertices
	vertices[vertexCount + 0] = x1;
	vertices[vertexCount + 1] = y1;
	vertices[vertexCount + 2] = x2;
	vertices[vertexCount + 3] = y2;
	vertices[vertexCount + 4] = x3;
	vertices[vertexCount + 5] = y3;
	vertices[vertexCount + 6] = x2;
	vertices[vertexCount + 7] = y2;
	vertices[vertexCount + 8] = x3;
	vertices[vertexCount + 9] = y3;
	vertices[vertexCount + 10] = x4;
	vertices[vertexCount + 11] = y4;
	
	//Increment vertex count
	vertexCount += 12;
}

-(void) clearObjects {
	//Reset counters
	vertexCount = 0;
	colorsCount = 0;
}

-(void) renderObjects {	
	//No need to render
	if (vertexCount == 0)
		return;
	
	//Reset transformations
    glLoadIdentity();
	
	//Enable blending
	glEnable(GL_BLEND);
	
	//Enable color masking
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	//Enable color array
	glEnableClientState(GL_COLOR_ARRAY);
	
	//Bind normal texture
	glBindTexture(GL_TEXTURE_2D, [texture name]);
	
	//Draw with opengl
	glTexCoordPointer(2,GL_FLOAT, 0, coordinates);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glDrawArrays(GL_TRIANGLES, 0, vertexCount/2);
	
	//Disable color array
	glDisableClientState(GL_COLOR_ARRAY);
	
	//Disable color masking
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	
	//Disable blending
	glDisable(GL_BLEND);
	
	//Reset object counters
	[self clearObjects];
}

#pragma mark Memory

- (void) dealloc {
	//Release items
	[items removeAllObjects];
	[items release];
	items = nil;
	
	//Release currentTexture
	[currentTexture release];
	currentTexture = nil;
	
	//Release texture
	[texture release];
	texture = nil;
	
	//Debug
	NSLog(@"Atlas deallocated");
	
	//Notify super
	[super dealloc];
}

@end