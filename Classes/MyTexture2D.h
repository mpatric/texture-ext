#import "Texture2D.h"

/*
 This class extends Texture2D to provide additional functionality.
 See blog posts at:
 
    http://mpatric.com/2011-10-21-extending-texture2d-part-1-rotation
    http://mpatric.com/2011-10-31-extending-texture2d-part-2-sprite-sheets
    http://mpatric.com/2011-11-22-extending-texture2d-part-3-texture-atlas

 Michael Patricios, 2011
*/

@interface MyTexture2D : Texture2D {
@private
	CGSize _imageSize;
    NSMutableDictionary* _textureAtlas;
}

@property (readonly, nonatomic) CGSize imageSize;

- (id) initWithImage:(UIImage*)uiImage;
- (id) initWithImage:(UIImage*)uiImage atlasFilename:(NSString*)atlasFilename;

- (void) drawInRect:(CGRect)rect rotatedBy:(float)rotationAngle;
- (void) drawAtPoint:(CGPoint)point rotatedBy:(float)rotationAngle;

- (void) drawAsSpriteSheetInRect:(CGRect)rect sheetDimensions:(CGSize)dimensions index:(int)index;
- (void) drawAsSpriteSheetAtPoint:(CGPoint)point sheetDimensions:(CGSize)dimensions index:(int)index;

- (void) drawFromAtlasInRect:(CGRect)rect key:(NSString*)key;
- (void) drawFromAtlasAtPoint:(CGPoint)point key:(NSString*)key;

- (int) count;

@end
