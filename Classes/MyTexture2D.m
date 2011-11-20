#import "MyTexture2D.h"

/*
 This class extends Texture2D to provide additional functionality.
 See blog posts at:
 
    http://mpatric.com/2011-10-21-extending-texture2d-part-1-rotation
    http://mpatric.com/2011-10-31-extending-texture2d-part-2-sprite-sheets

 Michael Patricios, 2011
*/

@interface MyTexture2D(PrivateMethods)
- (void) drawInRect:(CGRect)rect textureRect:(CGRect)textureRect;
- (void) readAtlasWithFilename:(NSString*)atlasFilename;
@end

@implementation MyTexture2D

#define ROTATE_ABOUT_POINT(x, y, cx, cy, cosTheta, sinTheta) CGPointMake(((((x) - (cx)) * (cosTheta)) - (((y) - (cy)) * (sinTheta))) + (cx), ((((x) - (cx)) * (sinTheta)) + (((y) - (cy)) * (cosTheta))) + (cy));
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

@synthesize imageSize = _imageSize;

- (id) initWithImage:(UIImage*)uiImage {
    _imageSize = CGSizeMake(uiImage.size.width, uiImage.size.height);
    _spriteAtlas = nil;
    self = [super initWithImage:uiImage];
    return self;
}

- (id) initWithImage:(UIImage*)uiImage atlasFilename:(NSString*)atlasFilename {
    _imageSize = CGSizeMake(uiImage.size.width, uiImage.size.height);
    _spriteAtlas = nil;
    self = [super initWithImage:uiImage];
    if (self) {
        [self readAtlasWithFilename:atlasFilename];
    }
    return self;
}

- (void) dealloc {
    if (_spriteAtlas) {
        [_spriteAtlas release];
        _spriteAtlas = nil;
    }
    [super dealloc];
}

- (void) drawAtPoint:(CGPoint)point {
    [self drawInRect:CGRectMake(point.x - self.imageSize.width / 2, point.y - self.imageSize.height / 2, self.imageSize.width, self.imageSize.height)];
}

- (void) drawInRect:(CGRect)rect rotatedBy:(float)rotationAngle {
	float radians = DEGREES_TO_RADIANS(rotationAngle);
	GLfloat cosTheta = cosf(radians);
	GLfloat sinTheta = sinf(radians);
	CGPoint center = CGPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
	CGPoint p1 = ROTATE_ABOUT_POINT(rect.origin.x, rect.origin.y, center.x, center.y, cosTheta, sinTheta);
	CGPoint p2 = ROTATE_ABOUT_POINT(rect.origin.x + rect.size.width, rect.origin.y, center.x, center.y, cosTheta, sinTheta);
	CGPoint p3 = ROTATE_ABOUT_POINT(rect.origin.x, rect.origin.y + rect.size.height, center.x, center.y, cosTheta, sinTheta);
	CGPoint p4 = ROTATE_ABOUT_POINT(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, center.x, center.y, cosTheta, sinTheta);
	GLfloat	coordinates[] = {
		0, self.maxT,
		self.maxS, self.maxT,
		0, 0,
		self.maxS, 0
	};
	GLfloat vertices[] = {
		p1.x, p1.y, 0.0,
		p2.x, p2.y, 0.0,
		p3.x, p3.y, 0.0,
		p4.x, p4.y, 0.0
	};
	glBindTexture(GL_TEXTURE_2D, self.name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) drawAtPoint:(CGPoint)point rotatedBy:(float)rotationAngle {
    [self drawInRect:CGRectMake(point.x - self.imageSize.width / 2, point.y - self.imageSize.height / 2, self.imageSize.width, self.imageSize.height) rotatedBy: rotationAngle];
}

- (void) drawAsSpriteSheetInRect:(CGRect)rect sheetDimensions:(CGSize)dimensions index:(int)index {
    GLfloat y = self.maxS * ((GLfloat)(index / (int)dimensions.height)) / dimensions.height;
	GLfloat x = self.maxT * ((GLfloat)(index % (int)dimensions.width)) / dimensions.width;
    GLfloat x = self.maxS * ((GLfloat)(index % (int)dimensions.width)) / dimensions.width;
    GLfloat y = self.maxT * ((GLfloat)(index / (int)dimensions.height)) / dimensions.height;
    
	GLfloat	coordinates[] = {
        x, y + (self.maxT / dimensions.height),
        x + (self.maxS / dimensions.width), y + (self.maxT / dimensions.height),
        x, y,
        x + (self.maxS / dimensions.width),	y
	};
	GLfloat	vertices[] = {
        rect.origin.x, rect.origin.y, 0.0,
        rect.origin.x + rect.size.width, rect.origin.y, 0.0,
        rect.origin.x, rect.origin.y + rect.size.height, 0.0,
        rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, 0.0
	};
	
	glBindTexture(GL_TEXTURE_2D, self.name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) drawAsSpriteSheetAtPoint:(CGPoint)point sheetDimensions:(CGSize)dimensions index:(int)index {
    [self drawAsSpriteSheetInRect:CGRectMake(point.x - self.imageSize.width / (2 * dimensions.width), point.y - self.imageSize.height / (2 * dimensions.height), self.imageSize.width / dimensions.width, self.imageSize.height / dimensions.height)
                  sheetDimensions:dimensions index:index];
}

- (void) drawFromAtlasInRect:(CGRect)rect key:(NSString*)key {
    NSValue* value = [_spriteAtlas valueForKey:key];
    if (value) {
        CGRect atlasRect = [value CGRectValue];
        [self drawInRect:rect textureRect:atlasRect];
    }
}

- (void) drawFromAtlasAtPoint:(CGPoint)point key:(NSString*)key {
    NSLog(@"key: %@", key);
    NSValue* value = [_spriteAtlas valueForKey:key];
    if (value) {
        CGRect atlasRect = [value CGRectValue];
        NSLog(@"rect: %0.1f, %0.1f, %0.1f, %0.1f", atlasRect.origin.x, atlasRect.origin.y, atlasRect.size.width, atlasRect.size.height);
        [self drawInRect:CGRectMake(point.x - atlasRect.size.width / 2, point.y - atlasRect.size.height / 2, atlasRect.size.width, atlasRect.size.height) textureRect:atlasRect];
    }
}

- (void) drawInRect:(CGRect)rect textureRect:(CGRect)textureRect {
    GLfloat y = self.maxS * (textureRect.origin.y / self.imageSize.height);
    GLfloat x = self.maxT * (textureRect.origin.x / self.imageSize.width);
    
    GLfloat	coordinates[] = {
        x, y + (self.maxT * (textureRect.size.height / self.imageSize.height)),
        x + (self.maxS * (textureRect.size.width / self.imageSize.width)), y + (self.maxT * (textureRect.size.height / self.imageSize.width)),
        x, y,
        x + (self.maxS * (textureRect.size.width / self.imageSize.width)), y
    };
    GLfloat	vertices[] = {
        rect.origin.x, rect.origin.y, 0.0,
        rect.origin.x + rect.size.width, rect.origin.y, 0.0,
        rect.origin.x, rect.origin.y + rect.size.height, 0.0,
        rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, 0.0
    };
    
    glBindTexture(GL_TEXTURE_2D, self.name);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) readAtlasWithFilename:(NSString*)atlasFilename {
    if (_spriteAtlas) {
        [_spriteAtlas release];
        _spriteAtlas = nil;
    }
    NSString* path = [[NSBundle mainBundle] pathForResource:atlasFilename ofType:nil];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (content == nil) {
        NSLog(@"Warning: could not read specified sprite atlas file: %@", atlasFilename);
    } else {
        NSArray* lines = [content componentsSeparatedByString:@"\n"];
        _spriteAtlas = [[NSMutableDictionary dictionaryWithCapacity:lines.count] retain];
        for (NSString* line in lines) {
            if (line.length == 0) continue;
            NSArray* data = [line componentsSeparatedByString:@","];
            CGRect rect = CGRectMake([[data objectAtIndex:1] intValue], [[data objectAtIndex:2] intValue], [[data objectAtIndex:3] intValue], [[data objectAtIndex:4] intValue]);
            [_spriteAtlas setValue:[NSValue valueWithCGRect:rect] forKey:[data objectAtIndex:0]];
        }
    }
}

- (int) count {
    if (_spriteAtlas) {
        return _spriteAtlas.count;
    } else {
        return 1;
    }
}

@end
