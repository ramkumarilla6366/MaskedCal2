//
//  HelloWorldLayer.m
//  MaskedCal
//
//  Created by zhou matt on 12-9-7.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "MaskedSprite.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (CCSprite *)maskedSpriteWithSprite:(CCSprite *)textureSprite maskSprite:(CCSprite *)maskSprite { 
    
    // 1
    CCRenderTexture * rt = [CCRenderTexture renderTextureWithWidth:maskSprite.contentSize.width height:maskSprite.contentSize.height];
    
    // 2
    maskSprite.position = ccp(maskSprite.contentSize.width/2, maskSprite.contentSize.height/2);
    textureSprite.position = ccp(textureSprite.contentSize.width/2, textureSprite.contentSize.height/2);
    
    // 3
    [maskSprite setBlendFunc:(ccBlendFunc){GL_ONE, GL_ZERO}];
    [textureSprite setBlendFunc:(ccBlendFunc){GL_DST_ALPHA, GL_ZERO}];
    
    // 4
    [rt begin];
    [maskSprite visit];        
    [textureSprite visit];    
    [rt end];
    
    // 5
    CCSprite *retval = [CCSprite spriteWithTexture:rt.sprite.texture];
    retval.flipY = YES;
    return retval;
    
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		
		
		//
		// Leaderboards and Achievements
		//
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
			
			
			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
			achivementViewController.achievementDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:achivementViewController animated:YES];
			
		}
									   ];

		// Leaderboard Menu Item using blocks
		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
			
			
			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
			
		}
									   ];
		
		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
		
		// Add the menu to the layer
		[self addChild:menu];

	}
	return self;
}

-(void) setupShaderWithCCShader
{
    self.shaderProgram = [[GLProgram alloc] initWithVertexShaderByteArray:ccPositionColor_vert fragmentShaderByteArray:ccPositionColor_frag] ;
    
    [shaderProgram_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
    [shaderProgram_ addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
    [shaderProgram_ link];
    [shaderProgram_ updateUniforms];
    
    // Set up u_MVPMatrix, because CC Shader's ccPositionColor_vert as defined in ccShader_PositionColor_vert.h uses an uniform	mat4 u_MVPMatrix.
    // In this project, the MVPMatrix does not change, and so we just set the matrix to be identity.
    GLuint _MVPMatrixLocation = glGetUniformLocation(shaderProgram_->program_, "u_MVPMatrix");
    float identity[16] = {
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f
    };
    glUniformMatrix4fv(_MVPMatrixLocation, 1, GL_FALSE, identity);
}

+(CCScene *) sceneWithLastCalendar:(int)lastCalendar // new
{
    CCScene *scene = [CCScene node];
    HelloWorldLayer *layer = [[HelloWorldLayer alloc] 
                               initWithLastCalendar:lastCalendar] ; // new
    [scene addChild: layer];	
    return scene;
}

// Replace init with the following
-(id) initWithLastCalendar:(int)lastCalendar
{
	if( (self=[super init])) {
        [self setupShaderWithCCShader];
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        do {
            calendarNum = arc4random() % 3 + 1;
        } while (calendarNum == lastCalendar);
        
        NSString * spriteName = [NSString 
                                 stringWithFormat:@"Calendar%d.png", calendarNum];
        
        MaskedSprite * maskedCal = [MaskedSprite spriteWithFile:spriteName];
//        CCSprite * maskedCal = [CCSprite spriteWithFile:spriteName];
        maskedCal.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:maskedCal];
        
        self.isTouchEnabled = YES;
	}
	return self;
}

// Add new methods
- (void)registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 
                                                       swallowsTouches:YES];

}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CCScene *scene = [HelloWorldLayer sceneWithLastCalendar:calendarNum];
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionJumpZoom transitionWithDuration:1.0 scene:scene]];
    return TRUE;
}

// on "dealloc" you need to release all your retained objects

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
