//
//  HelloWorldLayer.h
//  MaskedCal
//
//  Created by zhou matt on 12-9-7.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    int calendarNum;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

+ (CCScene *) sceneWithLastCalendar:(int)lastCalendar;
- (id)initWithLastCalendar:(int)lastCalendar;

@end
