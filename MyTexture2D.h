#import "Texture2D.h"

@interface MyTexture2D : Texture2D

- (id) initWithImage:(UIImage*)uiImage;

- (void) drawInRect:(CGRect)rect rotatedBy:(float)rotationAngle;
- (void) drawAtPoint:(CGPoint)point rotatedBy:(float)rotationAngle;

@end
