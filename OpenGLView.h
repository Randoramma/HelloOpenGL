//
//  OpenGLView.h
//  HelloOpenGL
//
//  Created by Randy McLain on 2/15/17.
//  Copyright © 2017 Randy McLain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView {
    
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    
}

@end