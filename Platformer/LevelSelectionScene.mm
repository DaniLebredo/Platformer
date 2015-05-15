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

#import "LevelSelectionScene.h"
#import "WorldSelectLayer.h"
#import "LevelSelectLayer.h"
#import "StoreLayer.h"
#import "BusyLayer.h"
#import "LevelSelectionController.h"
#import "Game.h"


@implementation LevelSelectionScene

-(id) init
{
	return nil;
}

-(id) initWithSceneController:(SceneController*)scene
{
	return nil;
}

-(id) initWithLevelSelectionController:(LevelSelectionController*)controller
{
	self = [super initWithSceneController:controller];
	if (self)
	{
		mWorldSelectLayer = [[WorldSelectLayer alloc] initWithLevelSelectionController:controller];
		[self addChild:mWorldSelectLayer z:0];
		
		mLevelSelectLayer = [[LevelSelectLayer alloc] initWithLevelSelectionController:controller];
		[self addChild:mLevelSelectLayer z:10];
		
		mStoreLayer = [[StoreLayer alloc] initWithSceneController:controller];
		[self addChild:mStoreLayer z:20];
		
		mBusyLayer = [[BusyLayer alloc] initWithSceneController:controller];
		[self addChild:mBusyLayer z:30];
	}
	return self;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: LevelSelectionScene");
	
	[mWorldSelectLayer release];
	[mLevelSelectLayer release];
	[mStoreLayer release];
	[mBusyLayer release];
	
	[super dealloc];
}

-(void) pause
{
	CCLOG(@"NOTHING TO PAUSE HERE");
}

-(void) showLayer:(CCLayer*)layer
{
	layer.visible = YES;
	layer.touchEnabled = YES;
}

-(void) hideLayer:(CCLayer*)layer
{
	layer.visible = NO;
	layer.touchEnabled = NO;
}

-(void) showWorlds
{
	[mWorldSelectLayer showUI];
	[mWorldSelectLayer addGestureRecognizer];
	[self showLayer:mWorldSelectLayer];
	mFocusedLayer = mWorldSelectLayer;
}

-(void) hideWorlds
{
	[mWorldSelectLayer hideUI];
	[mWorldSelectLayer removeGestureRecognizer];
	[self hideLayer:mWorldSelectLayer];
}

-(void) centerWorld:(int)worldId
{
	[mWorldSelectLayer centerWorld:worldId animate:false];
}

-(void) showLevelsForWorld:(int)worldId focusLevel:(int)levelId
{
	[mLevelSelectLayer showLevelsForWorld:worldId focusLevel:levelId];
	[self showLayer:mLevelSelectLayer];
	mFocusedLayer = mLevelSelectLayer;
}

-(void) hideLevels
{
	[self hideLayer:mLevelSelectLayer];
}

-(void) animateLevels
{
	[mLevelSelectLayer animate];
}

-(void) showStore
{
	[mStoreLayer preDisplay];
	[self showLayer:mStoreLayer];
	mFocusedLayer = mStoreLayer;
}

-(void) hideStore
{
	[self hideLayer:mStoreLayer];
}

-(void) setStoreAvailability:(bool)available
{
	[mStoreLayer setAvailability:available];
}

-(void) showBusy
{
	[self showLayer:mBusyLayer];
}

-(void) hideBusy
{
	[self hideLayer:mBusyLayer];
}

@end
