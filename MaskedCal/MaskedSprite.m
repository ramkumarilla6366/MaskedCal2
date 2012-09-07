//
//  MaskedSprite.m
//  MaskedCal
//
//  Created by zhou matt on 12-9-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "MaskedSprite.h"

//extern void ccGLUniformProjectionMatrix(CCGLProgram	*);
//extern void ccGLUniformModelViewMatrix(CCGLProgram	*);

@implementation MaskedSprite

- (id)initWithFile:(NSString *)file 
{
    self = [super initWithFile:file];
    if (self) {
        
        // 1
        _maskTexture = [[CCTextureCache sharedTextureCache] addImage:@"CalendarMask.png"] ;
        
        // 2
        self.shaderProgram = 
        [[CCGLProgram alloc] 
          initWithVertexShaderFilename:@"PositionTextureColor.vert"
          fragmentShaderFilename:@"Mask.frag"] ;
        
        CHECK_GL_ERROR_DEBUG();
        
        // 3
        [shaderProgram_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [shaderProgram_ addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
        [shaderProgram_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 4
        [shaderProgram_ link];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 5
        [shaderProgram_ updateUniforms];
        
        CHECK_GL_ERROR_DEBUG();                
        
        // 6
        _textureLocation = glGetUniformLocation( shaderProgram_->program_, "u_texture");
        _maskLocation = glGetUniformLocation( shaderProgram_->program_, "u_mask");
        
        CHECK_GL_ERROR_DEBUG();
        
    }
    
    return self;
}

-(void) draw {    
    
    CC_NODE_DRAW_SETUP();
    
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
    ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [shaderProgram_ setUniformForModelViewProjectionMatrix];
    
    // 2
    glActiveTexture(GL_TEXTURE0);
    glBindTexture( GL_TEXTURE_2D,  [texture_ name] );
    glUniform1i(_textureLocation, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture( GL_TEXTURE_2D,  [_maskTexture name] );
    glUniform1i(_maskLocation, 1);
    
    // 3
#define kQuadSize sizeof(quad_.bl)
    long offset = (long)&quad_;
    
//    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords | kCCVertexAttribFlag_Color);
    // vertex
    NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
    // texCoods
    diff = offsetof( ccV3F_C4B_T2F, texCoords);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
    // color
    diff = offsetof( ccV3F_C4B_T2F, colors);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
    // 4
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); 
    glActiveTexture(GL_TEXTURE0);
}

@end
