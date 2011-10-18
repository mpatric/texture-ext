#import <mach/mach_time.h>
#import "TextureExtAppDelegate.h"
#import "MyEAGLView.h"
#import "MyTexture2D.h"


@interface TextureExtAppDelegate ()
- (void) renderScene;
@end


@implementation TextureExtAppDelegate

- (void) applicationDidFinishLaunching:(UIApplication*)application {
    CGRect rect = [[UIScreen mainScreen] bounds];	

    glMatrixMode(GL_PROJECTION);
    glOrthof(0, rect.size.width, 0, rect.size.height, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_TEXTURE_2D);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    UIImage* image = [UIImage imageNamed:@"wheel.png"];
    _wheel = [[MyTexture2D alloc] initWithImage:image];
    NSLog(@"***** image size: %0.1f x %0.1f", _wheel.contentSize.width, _wheel.contentSize.height);
    NSLog(@"***** texture size: %d x %d", _wheel.pixelsWide, _wheel.pixelsHigh);

    CGRect bounds = [glView bounds];
    _wheelPoint1 = CGPointMake(bounds.size.width / 2, bounds.size.height / 2 - 100.0);
    _wheelPoint2 = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);

    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / 60.0f) target:self selector:@selector(renderScene) userInfo:nil repeats:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;	
}

- (void) dealloc {
    [_wheel release];
    [glView release];
    [window release];	
    [super dealloc];
}

- (void) renderScene {
    // Animate
    angle += 1;
    // Draw
    glLoadIdentity(); 
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT); 
    
    [_wheel drawAtPoint:_wheelPoint1];
    [_wheel drawAtPoint:_wheelPoint2 rotatedBy:angle];
    
    [glView swapBuffers];
}

@end
