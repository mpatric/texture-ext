#import <UIKit/UIKit.h>
#import "Texture2D.h"

@class MyEAGLView;

@interface TextureExtAppDelegate : NSObject<UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet MyEAGLView *glView;
    NSTimer* _timer;
    Texture2D* _wheel;
    CGRect _wheelRect;
}

@end
