//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by Randy McLain on 2/15/17.
//  Copyright © 2017 Randy McLain. All rights reserved.
//

#import "OpenGLView.h"


@implementation OpenGLView


-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self render];
    }
    return self;
}

-(void) dealloc {
  //  [_context release];
    _context = nil;
  //  [super dealloc];
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
