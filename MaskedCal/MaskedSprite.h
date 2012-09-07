//
//  MaskedSprite.h
//  MaskedCal
//
//  Created by zhou matt on 12-9-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MaskedSprite : CCSprite {
    CCTexture2D * _maskTexture;
    GLuint _textureLocation;
    GLuint _maskLocation;
}

@end
