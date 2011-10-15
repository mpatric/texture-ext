#import <QuartzCore/QuartzCore.h>
#import "MyEAGLView.h"
#import "TextureExtAppDelegate.h"

@implementation MyEAGLView

@synthesize delegate=_delegate, autoresizesSurface=_autoresize, surfaceSize=_size, framebuffer = _framebuffer, pixelFormat = _format, depthFormat = _depthFormat, context = _context;

+ (Class) layerClass {
	return [CAEAGLLayer class];
}

- (BOOL) _createSurface {
	CAEAGLLayer* eaglLayer = (CAEAGLLayer*)[self layer];
	CGSize newSize;
	GLuint oldRenderbuffer;
	GLuint oldFramebuffer;
	
	if (![EAGLContext setCurrentContext:_context]) {
		return NO;
	}
	
	newSize = [eaglLayer bounds].size;
	newSize.width = roundf(newSize.width);
	newSize.height = roundf(newSize.height);
	
	glGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint *) &oldRenderbuffer);
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint *) &oldFramebuffer);
	
	glGenRenderbuffersOES(1, &_renderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
	
	if (![_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer]) {
		glDeleteRenderbuffersOES(1, &_renderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_BINDING_OES, oldRenderbuffer);
		return NO;
	}
	
	glGenFramebuffersOES(1, &_framebuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _framebuffer);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _renderbuffer);
	if (_depthFormat) {
		glGenRenderbuffersOES(1, &_depthBuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthBuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, _depthFormat, newSize.width, newSize.height);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthBuffer);
	}
	
	_size = newSize;
	if (!_hasBeenCurrent) {
		glViewport(0, 0, newSize.width, newSize.height);
		glScissor(0, 0, newSize.width, newSize.height);
		_hasBeenCurrent = YES;
	} else {
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFramebuffer);
	}
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, oldRenderbuffer);

	[_delegate didResizeEAGLSurfaceForView:self];
	return YES;
}

- (void) _destroySurface {
	EAGLContext *oldContext = [EAGLContext currentContext];
	
	if (oldContext != _context) {
		[EAGLContext setCurrentContext:_context];
    }
	
	if (_depthFormat) {
		glDeleteRenderbuffersOES(1, &_depthBuffer);
		_depthBuffer = 0;
	}
	
	glDeleteRenderbuffersOES(1, &_renderbuffer);
	_renderbuffer = 0;
	
	glDeleteFramebuffersOES(1, &_framebuffer);
	_framebuffer = 0;
	
	if (oldContext != _context) {
		[EAGLContext setCurrentContext:oldContext];
    }
}

- (id) initWithCoder:(NSCoder*)coder {
	if ((self = [super initWithCoder:coder])) {
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*)[self layer];
		
		[eaglLayer setDrawableProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil]];
		_format = kEAGLColorFormatRGB565;
		_depthFormat = 0;
		
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		if (_context == nil) {
			[self release];
			return nil;
		}
		
		if (![self _createSurface]) {
			[self release];
			return nil;
		}
	}
	return self;
}

- (void) dealloc {
	[self _destroySurface];
	[_context release];
	_context = nil;
	[super dealloc];
}

- (void) layoutSubviews {
	CGRect bounds = [self bounds];
	
	if (_autoresize && ((roundf(bounds.size.width) != _size.width) || (roundf(bounds.size.height) != _size.height))) {
		[self _destroySurface];
		[self _createSurface];
	}
}

- (void) setAutoresizesEAGLSurface:(BOOL)autoresizesEAGLSurface; {
	_autoresize = autoresizesEAGLSurface;
	if (_autoresize) {
		[self layoutSubviews];
    }
}

- (void) setCurrentContext {
	if (![EAGLContext setCurrentContext:_context]) {
		printf("Failed to set current context %p in %s\n", _context, __FUNCTION__);
	}
}

- (BOOL) isCurrentContext {
	return ([EAGLContext currentContext] == _context ? YES : NO);
}

- (void) clearCurrentContext {
	if (![EAGLContext setCurrentContext:nil]) {
		printf("Failed to clear current context in %s\n", __FUNCTION__);
    }
}

- (void) swapBuffers {
	EAGLContext *oldContext = [EAGLContext currentContext];
	GLuint oldRenderbuffer;
	
	if (oldContext != _context) {
		[EAGLContext setCurrentContext:_context];
    }

	glGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint *) &oldRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderbuffer);
	
	if (![_context presentRenderbuffer:GL_RENDERBUFFER_OES]) {
		printf("Failed to swap renderbuffer in %s\n", __FUNCTION__);
    }
	
	if (oldContext != _context) {
		[EAGLContext setCurrentContext:oldContext];
    }
}

- (CGPoint) convertPointFromViewToSurface:(CGPoint)point {
	CGRect bounds = [self bounds];
	return CGPointMake((point.x - bounds.origin.x) / bounds.size.width * _size.width, (point.y - bounds.origin.y) / bounds.size.height * _size.height);
}

- (CGRect) convertRectFromViewToSurface:(CGRect)rect {
	CGRect bounds = [self bounds];
	return CGRectMake((rect.origin.x - bounds.origin.x) / bounds.size.width * _size.width, (rect.origin.y - bounds.origin.y) / bounds.size.height * _size.height, rect.size.width / bounds.size.width * _size.width, rect.size.height / bounds.size.height * _size.height);
}

@end
