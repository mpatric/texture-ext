#import <mach/mach_time.h>
#import "TextureExtAppDelegate.h"
#import "MyEAGLView.h"
#import "MyTexture2D.h"

const NSString* prince_animation_keys[] = {@"prince0", @"prince1", @"prince2", @"prince3", @"prince4", @"prince5", @"prince6", @"prince7", @"prince8", @"prince9", @"prince10", @"prince11", @"prince12"};
const int prince_animation_key_count = 13;
const NSString* potion_animation_keys[] = {@"potion0", @"potion1", @"potion2", @"potion3", @"potion4", @"potion5", @"potion6", @"potion7", @"potion8", @"potion9", @"potion10", @"potion11", @"potion12"};
const int potion_animation_key_count = 13;

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
    
    UIImage* boxImage = [UIImage imageNamed:@"box.png"];
    _box = [[MyTexture2D alloc] initWithImage:boxImage];
    
    UIImage* spritesheetImage = [UIImage imageNamed:@"spritesheet.png"];
    _spritesheet = [[MyTexture2D alloc] initWithImage:spritesheetImage];
    
    UIImage* spriteatlasImage = [UIImage imageNamed:@"spriteatlas.png"];
    _spriteatlas = [[MyTexture2D alloc] initWithImage:spriteatlasImage atlasFilename:@"spriteatlas.txt"];
    NSLog(@"spriteatlas content size: %0.1f x %0.1f", _spriteatlas.contentSize.width, _spriteatlas.contentSize.height);
    NSLog(@"spriteatlas texture size: %d x %d", _spriteatlas.pixelsWide, _spriteatlas.pixelsHigh);
    NSLog(@"spriteatlas count: %d", _spriteatlas.count);
    
    princeIndex = potionIndex = 0.0f;

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
    princeIndex += 0.5;
    if (princeIndex > (prince_animation_key_count - 1)) {
        princeIndex -= 8; // only repeat the last 8 frames
    }
    potionIndex += 0.125;
    if (potionIndex > (potion_animation_key_count - 1)) {
        potionIndex -= potion_animation_key_count;
    }
    
    // Draw
    glLoadIdentity(); 
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT); 
    
    // Rotated textures
    [_wheel drawAtPoint:CGPointMake(106, 384)];
    [_wheel drawAtPoint:CGPointMake(106, 288) rotatedBy:angle];
    [_box drawAtPoint:CGPointMake(106, 192) rotatedBy:angle];
    [_wheel drawAtPoint:CGPointMake(106, 192) rotatedBy:-angle];
    [_box drawAtPoint:CGPointMake(106, 96) rotatedBy:-angle];
    
    // Texture from a sprite sheet
    [_spritesheet drawAsSpriteSheetAtPoint:CGPointMake(212, 288) sheetDimensions:CGSizeMake(4, 4) index:(int)(princeIndex)];

    // Textures from a texture atlas
    [_spriteatlas drawFromAtlasAtPoint:CGPointMake(212, 192) key:(NSString*)prince_animation_keys[(int)princeIndex]];
    [_spriteatlas drawFromAtlasAtPoint:CGPointMake(212, 96) key:(NSString*)potion_animation_keys[(int)potionIndex]];
    
    [glView swapBuffers];
}

@end
