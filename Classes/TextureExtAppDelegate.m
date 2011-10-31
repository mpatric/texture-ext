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
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_TEXTURE_2D);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    UIImage* wheelImage = [UIImage imageNamed:@"wheel.png"];
    _wheel = [[MyTexture2D alloc] initWithImage:wheelImage];
    NSLog(@"wheel image size: %0.1f x %0.1f", wheelImage.size.width, wheelImage.size.height);
    NSLog(@"wheel content size: %0.1f x %0.1f", _wheel.contentSize.width, _wheel.contentSize.height);
    NSLog(@"wheel texture size: %d x %d", _wheel.pixelsWide, _wheel.pixelsHigh);
    
    UIImage* boxImage = [UIImage imageNamed:@"box.png"];
    _box = [[MyTexture2D alloc] initWithImage:boxImage];
    NSLog(@"box content size: %0.1f x %0.1f", _box.contentSize.width, _box.contentSize.height);
    NSLog(@"box texture size: %d x %d", _box.pixelsWide, _box.pixelsHigh);
    
    UIImage* spritesheetImage = [UIImage imageNamed:@"spritesheet.png"];
    _spritesheet = [[MyTexture2D alloc] initWithImage:spritesheetImage];
    NSLog(@"spritesheet content size: %0.1f x %0.1f", _spritesheet.contentSize.width, _spritesheet.contentSize.height);
    NSLog(@"spritesheet texture size: %d x %d", _spritesheet.pixelsWide, _spritesheet.pixelsHigh);

    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / 30.0f) target:self selector:@selector(renderScene) userInfo:nil repeats:YES];
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
    if (angle > 360) {
        angle -= 360;
    }
    spriteIndex += 0.5;
    if (spriteIndex > 12) {
        spriteIndex -= 8;
    }
    // Draw
    glLoadIdentity(); 
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT); 
    
    [_wheel drawAtPoint:CGPointMake(106, 384)];
    [_wheel drawAtPoint:CGPointMake(106, 288) rotatedBy:angle];
    [_box drawAtPoint:CGPointMake(106, 192) rotatedBy:angle];
    [_wheel drawAtPoint:CGPointMake(106, 192) rotatedBy:-angle];
    [_box drawAtPoint:CGPointMake(106, 96) rotatedBy:-angle];
    
    [_spritesheet drawAsSpriteSheetAtPoint:CGPointMake(212, 240) sheetDimensions:CGSizeMake(4, 4) index:(int)(spriteIndex)];
    
    [glView swapBuffers];
}

@end
