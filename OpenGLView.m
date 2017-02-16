//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by Randy McLain on 2/15/17.
//  Copyright © 2017 Randy McLain. All rights reserved.
//

#import "OpenGLView.h"
@interface OpenGLView () {
    
    
    
}





@end





@implementation OpenGLView

static NSString *const SIMPLE_VERTEX = @"SimpleVertex";
static NSString *const SIMPLE_FRAGMENT = @"SimpleFragment";
static NSString *const POSITION = @"Position";


-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self render];
    }
    return self;
}

-(void) dealloc {
  //  [_context release];
    _context = nil;
  //  [super dealloc];
}

-(GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType {
    NSString * shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError * error;
    NSString * shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                        encoding:NSUTF8StringEncoding
                                                           error:&error];
    
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    GLuint shaderHandle = glCreateShader(shaderType); // make a shader object of shader type from method parameter
    
    const char * shaderStringUTF8 = [shaderString UTF8String];
    const int shaderStringLength = (int)[shaderString length];
    //give OpenGL the source code for this shader
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // compiles shader at run time.
    glCompileShader(shaderHandle);
    
    // record the result if the compilation fails.
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
        
    }
    return shaderHandle;
}

-(void) compileShaders {
    GLuint vertexShader = [self compileShader:SIMPLE_VERTEX withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:SIMPLE_FRAGMENT withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot); 
    
    
}
/*
 To set up a view to display OpenGL content, you need to set it’s default layer to a special kind of layer called a CAEAGLLayer.
 */
+(Class)layerClass {
    return [CAEAGLLayer class];
}

/*
 To set up a view to display OpenGL content, you need to set it’s default layer to a special kind of layer called a CAEAGLLayer.
 */
- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}


/*
 An EAGLContext manages all of the information iOS needs to draw with OpenGL. It’s similar to how you need a Core Graphics context to do anything with Core Graphics.
 */
-(void) setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2; // specify version for OpenGL
    _context =[[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context!");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context!");
        exit(1);
    }
}

/*
 The next step to use OpenGL is to create a render buffer, which is an OpenGL object that stores the rendered image to present to the screen.
 */
-(void) setupRenderBuffer {
    glGenBuffers(1, &_colorRenderBuffer); //unique integer for the the render buffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer); //whenever I refer to GL_RENDERBUFFER, I really mean _colorRenderBuffer
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer]; //allocate some storage for the render buffer
}

/*
 A frame buffer is an OpenGL object that contains a render buffer, and some other buffers...
 */
-(void) setupFrameBuffer {
    GLuint framebuffer; // same as creating a renderbuffer
    glGenFramebuffers(1, &framebuffer); // same as creating a renderbuffer
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer); // same as creating a renderbuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer); // attach render buffer to frame buffer's GL_COLOR_ATTACHMENT0 enum slot.
    
}

/*
 let’s just clear the entire screen to a particular color a quick way to present something within the view.
 */
-(void) render {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT); // actually clear the current render and frame buffer objects.
    [_context presentRenderbuffer:GL_RENDERBUFFER]; // present to the new UI layer.
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
