#import "Texture2D.h"

/*
 This class extends Texture2D to provide additional functionality.
 See blog post at: http://mpatric.com/2011-10-21-extending-texture2d-part-1-rotation

 Michael Patricios, 2011
*/

@interface MyTexture2D : Texture2D

- (void) drawInRect:(CGRect)rect rotatedBy:(float)rotationAngle;
- (void) drawAtPoint:(CGPoint)point rotatedBy:(float)rotationAngle;

@end
