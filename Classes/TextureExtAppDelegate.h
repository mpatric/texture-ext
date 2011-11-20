#import <UIKit/UIKit.h>
#import "MyTexture2D.h"

@class MyEAGLView;

@interface TextureExtAppDelegate : NSObject<UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet MyEAGLView *glView;
    NSTimer* _timer;
    MyTexture2D *_wheel, *_box, *_spritesheet, *_spriteatlas;
    float angle;
    float princeIndex, potionIndex;
}

@end
