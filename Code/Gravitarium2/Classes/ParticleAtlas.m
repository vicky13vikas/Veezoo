//
//  ParticleAtlas.m
//  AstroNut
//

#import "Geometry.h"
#import "ParticleAtlas.h"
#import "AtlasItem.h"
#import "Texture2D.h"

@implementation ParticleAtlas

@synthesize items;
@synthesize texture;
@synthesize currentTexture;
@synthesize sheetWidth;
@synthesize sheetHeight;

#pragma mark Initialization

-(id) initWithFile: (NSString *) fileName Extension: (NSString *) fileExtension NormalWidth: (float) normalWidth {
	if (self = [super init]) {
		//Initialize dictionary
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
				
				int identifier = [self.currentTexture intValue];
				
				NSString *xstr = (NSString *) [comps objectAtIndex: 0];
				NSString *ystr = (NSString *) [comps objectAtIndex: 1];
				NSString *wstr = (NSString *) [comps objectAtIndex: 2];
				NSString *hstr = (NSString *) [comps objectAtIndex: 3];
				
				int x = [[xstr stringByTrimmingCharactersInSet:nonDigits] intValue];
				int y = [[ystr stringByTrimmingCharactersInSet:nonDigits] intValue];
				int w = [[wstr stringByTrimmingCharactersInSet:nonDigits] intValue];
				int h = [[hstr stringByTrimmingCharactersInSet:nonDigits] intValue];
				
				ParticleAtlasItem* pai = [[ParticleAtlasItem alloc] initX: x Y: y W: w H: h SW: sheetWidth SH: sheetHeight];
				[items setObject: pai forKey: [NSNumber numberWithInt: identifier]];
				[pai release];
			}
		}
	}
}

#pragma mark Renderer

-(void) addObjectID: (int) identifier PosX: (GLfloat) x PosY: (GLfloat) y Scale: (GLfloat) s {
	//Get atlas object by key
	ParticleAtlasItem *p = [items objectForKey: [NSNumber numberWithInt: identifier]];
	
	//Set texture coordinates
	coordinates[vertexCount + 0] = p.cx1;
	coordinates[vertexCount + 1] = p.cy2;
	coordinates[vertexCount + 2] = p.cx2;
	coordinates[vertexCount + 3] = p.cy2;
	coordinates[vertexCount + 4] = p.cx1;
	coordinates[vertexCount + 5] = p.cy1;
	coordinates[vertexCount + 6] = p.cx2;
	coordinates[vertexCount + 7] = p.cy2;
	coordinates[vertexCount + 8] = p.cx1;
	coordinates[vertexCount + 9] = p.cy1;
	coordinates[vertexCount + 10] = p.cx2;
	coordinates[vertexCount + 11] = p.cy1;
	
	//Calculations
	GLfloat realWidth = p.w * s;
	GLfloat realHeight = p.h * s;
	GLfloat posX1 = x - realWidth / 2;
	GLfloat posY1 = y - realHeight / 2;
	GLfloat posX2 = posX1 + realWidth;
	GLfloat posY2 = posY1 + realHeight;
	
	//Set texture vertices
	vertices[vertexCount + 0] = posX1;
	vertices[vertexCount + 1] = posY2;
	vertices[vertexCount + 2] = posX2;
	vertices[vertexCount + 3] = posY2;
	vertices[vertexCount + 4] = posX1;
	vertices[vertexCount + 5] = posY1;
	vertices[vertexCount + 6] = posX2;
	vertices[vertexCount + 7] = posY2;
	vertices[vertexCount + 8] = posX1;
	vertices[vertexCount + 9] = posY1;
	vertices[vertexCount + 10] = posX2;
	vertices[vertexCount + 11] = posY1;
	
	//Increment vertex count
	vertexCount += 12;
}

-(void) renderObjects {	
	//No need to render
	if (vertexCount == 0)
		return;
	
	//Enable blending
	glEnable(GL_BLEND);
	
	//Bind normal texture
	glBindTexture(GL_TEXTURE_2D, [texture name]);
	
	//Reset transformations
    glLoadIdentity();
	
	//Draw with opengl
	glTexCoordPointer(2,GL_FLOAT, 0, coordinates);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_TRIANGLES, 0, vertexCount/2);
	
	//Disable blending
	glDisable(GL_BLEND);
	
	//Reset object counters
	[self clearObjects];
}

-(void) clearObjects {
	//Reset flags
	vertexCount = 0;
}

#pragma mark Memory

- (void) dealloc {
	//Release items
	[items removeAllObjects];
	[items release];
	items = nil;
	
	//Release texture
	[texture release];
	texture = nil;
	
	//Release current texture
	[currentTexture release];
	currentTexture = nil;

	//Debug
	NSLog(@"Particle atlas deallocated");
	
	//Notify super
	[super dealloc];
}

@end