#import "ViewController.h"
#import "MyTexture2D.h"

const NSString* prince_animation_keys[] = {@"prince0", @"prince1", @"prince2", @"prince3", @"prince4", @"prince5", @"prince6", @"prince7", @"prince8", @"prince9", @"prince10", @"prince11", @"prince12"};
const int prince_animation_key_count = 13;
const NSString* potion_animation_keys[] = {@"potion0", @"potion1", @"potion2", @"potion3", @"potion4", @"potion5", @"potion6", @"potion7", @"potion8", @"potion9", @"potion10", @"potion11", @"potion12"};
const int potion_animation_key_count = 13;


@interface ViewController ()

@property (strong, nonatomic) EAGLContext* context;
@property (nonatomic, strong) MyTexture2D* wheel;
@property (nonatomic, strong) MyTexture2D* box;
@property (nonatomic, strong) MyTexture2D* spritesheet;
@property (nonatomic, strong) MyTexture2D* textureAtlas;
@property (nonatomic, assign) float angle;
@property (nonatomic, assign) float princeIndex;
@property (nonatomic, assign) float potionIndex;

- (void)setupGL;
- (void)tearDownGL;
- (void)loadTextures;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    view.context = self.context;
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    // Configure renderbuffers created by the view
    view.drawableColorFormat = GLKViewDrawableColorFormatRGB565;
    view.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    //view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    
    // Enable multisampling
    //view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    self.preferredFramesPerSecond = 60;
    
    [self setupGL];
    [self loadTextures];
}

- (void)dealloc {
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    
    glMatrixMode(GL_PROJECTION);
    glOrthof(0, self.view.bounds.size.width, 0, self.view.bounds.size.height, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_TEXTURE_2D);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)loadTextures {
    UIImage* wheelImage = [UIImage imageNamed:@"wheel.png"];
    self.wheel = [[MyTexture2D alloc] initWithImage:wheelImage];
    
    UIImage* boxImage = [UIImage imageNamed:@"box.png"];
    self.box = [[MyTexture2D alloc] initWithImage:boxImage];
    
    UIImage* spritesheetImage = [UIImage imageNamed:@"spritesheet.png"];
    self.spritesheet = [[MyTexture2D alloc] initWithImage:spritesheetImage];
    
    UIImage* textureAtlasImage = [UIImage imageNamed:@"textureatlas.png"];
    self.textureAtlas = [[MyTexture2D alloc] initWithImage:textureAtlasImage atlasFilename:@"textureatlas.txt"];
    
    NSLog(@"TextureAtlas content size: %0.1f x %0.1f", self.textureAtlas.contentSize.width, self.textureAtlas.contentSize.height);
    NSLog(@"TextureAtlas texture size: %d x %d", self.textureAtlas.pixelsWide, self.textureAtlas.pixelsHigh);
    NSLog(@"TextureAtlas count: %d", self.textureAtlas.count);
    
    self.princeIndex = 0.0f;
    self.potionIndex = 0.0f;
}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
    // Animate
    self.angle += 1;
    if (self.angle > 360) {
        self.angle -= 360;
    }
    self.princeIndex += 0.5;
    if (self.princeIndex > (prince_animation_key_count - 1)) {
        self.princeIndex -= 8; // only repeat the last 8 frames
    }
    _potionIndex += 0.125;
    if (self.potionIndex > (potion_animation_key_count - 1)) {
        self.potionIndex -= potion_animation_key_count;
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glLoadIdentity();
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Rotated textures
    [self.wheel drawAtPoint:CGPointMake(106, 384)];
    [self.wheel drawAtPoint:CGPointMake(106, 288) rotatedBy:self.angle];
    [self.box drawAtPoint:CGPointMake(106, 192) rotatedBy:self.angle];
    [self.wheel drawAtPoint:CGPointMake(106, 192) rotatedBy:-self.angle];
    [self.box drawAtPoint:CGPointMake(106, 96) rotatedBy:-self.angle];
    
    // Texture from a sprite sheet
    [self.spritesheet drawAsSpriteSheetAtPoint:CGPointMake(212, 288) sheetDimensions:CGSizeMake(4, 4) index:(int)(self.princeIndex)];
    
    // Textures from a texture atlas
    [self.textureAtlas drawFromAtlasAtPoint:CGPointMake(212, 192) key:(NSString*)prince_animation_keys[(int)self.princeIndex]];
    [self.textureAtlas drawFromAtlasAtPoint:CGPointMake(212, 96) key:(NSString*)potion_animation_keys[(int)self.potionIndex]];
}

@end
