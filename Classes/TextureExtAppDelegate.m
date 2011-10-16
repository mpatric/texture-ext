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
    NSLog(@"***** image size: %0.1f x %0.1f", image.size.width, image.size.height);
    _wheel = [[Texture2D alloc] initWithImage:image];
    NSLog(@"***** texture size: %d x %d", _wheel.pixelsWide, _wheel.pixelsHigh);

    CGRect bounds = [glView bounds];
    _wheelRect = CGRectMake((bounds.size.width - image.size.width) / 2, (bounds.size.height - image.size.height) / 2, image.size.width, image.size.height);

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
    // Draw
    glLoadIdentity(); 
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT); 
    [_wheel drawInRect:_wheelRect];
    [glView swapBuffers];
}

@end
