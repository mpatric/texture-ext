#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class MyEAGLView;

@protocol MyEAGLViewDelegate <NSObject>
- (void) didResizeEAGLSurfaceForView:(MyEAGLView*)view;
@end

@interface MyEAGLView : UIView {
@private
	NSString* _format;
	GLuint _depthFormat;
	BOOL _autoresize;
	EAGLContext* _context;
	GLuint _framebuffer;
	GLuint _renderbuffer;
	GLuint _depthBuffer;
	CGSize _size;
	BOOL _hasBeenCurrent;
	id<MyEAGLViewDelegate> _delegate;
}

@property(readonly) GLuint framebuffer;
@property(readonly) NSString* pixelFormat;
@property(readonly) GLuint depthFormat;
@property(readonly) EAGLContext *context;
@property BOOL autoresizesSurface;
@property(readonly, nonatomic) CGSize surfaceSize;
@property(assign) id<MyEAGLViewDelegate> delegate;

- (id)initWithCoder:(NSCoder*)coder; 
- (void) setCurrentContext;
- (BOOL) isCurrentContext;
- (void) clearCurrentContext;
- (void) swapBuffers;
- (CGPoint) convertPointFromViewToSurface:(CGPoint)point;
- (CGRect) convertRectFromViewToSurface:(CGRect)rect;

@end
