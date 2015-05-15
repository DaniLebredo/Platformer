/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2014 Pointy Nose Games
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CustomScene.h"
#import "StdInclude.h"
#import "GameObjectManager.h"
#import "MessageDispatcher.h"

#import <GameKit/GameKit.h>

#import "ActionLayer.h"
#import "ScrollableLayer.h"
//@class ActionLayer;
//@class ScrollableLayer;
@class HUDLayer;
@class PauseMenuLayer;
@class LevelCompleteLayer;
@class LifeLostLayer;
@class GetReadyLayer;
@class SettingsLayer;
@class ControlsLayer;
@class GameCompleteLayer;

class LevelController;


@interface LevelScene : CustomScene<GKGameCenterControllerDelegate>
{
	// Visuals
	CCSprite* mBackground;
	ScrollableLayer* mScrollableLayer;
	ActionLayer* mActionLayer;
	HUDLayer* mHUDLayer;
	PauseMenuLayer* mPauseMenuLayer;
	LevelCompleteLayer* mLevelCompleteLayer;
	LifeLostLayer* mLifeLostLayer;
	GetReadyLayer* mGetReadyLayer;
	SettingsLayer* mSettingsLayer;
	ControlsLayer* mControlsLayer;
	GameCompleteLayer* mGameCompleteLayer;
}

@property (nonatomic, readonly) ActionLayer* actionLayer;
@property (nonatomic, readonly) ScrollableLayer* scrollableLayer;

-(id) initWithLevelController:(LevelController*)controller;

-(void) addGameObject:(GameObject*)gObj;

-(void) updateStatusBar;
-(void) updateCamera:(CGPoint)targetPos;

-(void) showLeaderboards;
-(void) showAchievements;

-(void) hideGetReadyLayer;
	
-(void) showPauseLayer;
-(void) hidePauseLayer;
-(void) animatePauseLayer;

-(void) showHUDLayer;
-(void) hideHUDLayer;
-(void) refreshControlsInHUDLayer;

-(void) showLifeLostLayer;
-(void) animateLifeLostLayer;

-(void) showLevelCompletedLayer;

-(void) showControls;
-(void) hideControls;
-(void) resetControls;
-(void) refreshControls;
-(void) animateControls;

-(void) showSettings;
-(void) hideSettings;
-(void) refreshSettings;
-(void) animateSettings;

-(void) showWorldCompleted;
-(void) showGameCompleted;

-(void) postTweet;
-(void) postFacebookMessage;

@end
