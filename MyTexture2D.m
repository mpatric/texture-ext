#import "MyTexture2D.h"

@implementation MyTexture2D

- (id) initWithImage:(UIImage *)uiImage {
    self = [super initWithImage:uiImage];
    if (self) {
        
    }
    return self;
}

#define rotate_about_point(x, y, cx, cy, cosTheta, sinTheta) CGPointMake(((((x) - (cx)) * (cosTheta)) - (((y) - (cy)) * (sinTheta))) + (cx), ((((x) - (cx)) * (sinTheta)) + (((y) - (cy)) * (cosTheta))) + (cy));
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

- (void) drawInRect:(CGRect)rect rotatedBy:(float)rotationAngle {
	float radians = DEGREES_TO_RADIANS(rotationAngle);
	GLfloat cosTheta = cosf(radians);
	GLfloat sinTheta = sinf(radians);
	CGPoint center = CGPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
	CGPoint p1 = rotate_about_point(rect.origin.x, rect.origin.y, center.x, center.y, cosTheta, sinTheta);
	CGPoint p2 = rotate_about_point(rect.origin.x + rect.size.width, rect.origin.y, center.x, center.y, cosTheta, sinTheta);
	CGPoint p3 = rotate_about_point(rect.origin.x, rect.origin.y + rect.size.height, center.x, center.y, cosTheta, sinTheta);
	CGPoint p4 = rotate_about_point(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, center.x, center.y, cosTheta, sinTheta);
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
    [self drawInRect:CGRectMake(point.x - self.contentSize.width / 2, point.y - self.contentSize.height / 2, self.contentSize.width, self.contentSize.height) rotatedBy: rotationAngle];
}


@end
