#import <UIKit/UIKit.h>
#import "MyTexture2D.h"

@class MyEAGLView;

@interface TextureExtAppDelegate : NSObject<UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet MyEAGLView *glView;
    NSTimer* _timer;
    MyTexture2D* _wheel;
    CGPoint _wheelPoint1, _wheelPoint2;
    float angle;
}

@end
