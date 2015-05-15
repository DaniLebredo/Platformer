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
#import "CustomLayer.h"
#import "SceneController.h"
#import "Game.h"


@implementation CustomScene

-(id) init
{
	return nil;
}

-(id) initWithSceneController:(SceneController*)scene
{
	self = [super init];
	if (self)
	{
		NSAssert(scene != NULL, @"<CustomScene:initWithSceneController>: Scene controller must be non-NULL.");
		
		mSceneController = scene;
		
		mFocusedLayer = nil;
	}
	return self;
}

-(void) dealloc
{
	mSceneController = NULL;
	
	[super dealloc];
}

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	
	[self scheduleUpdate];
	
	Game::Instance()->OnSceneEntered(mSceneController);
	mSceneController->OnSceneEntered();
}

-(void) onExitTransitionDidStart
{
	[self unscheduleUpdate];
	
	[super onExitTransitionDidStart];
}

-(void) onExit
{
	// Just in case it wasn't called before, i.e. there was no exit transition.
	// It has to be called before [super onExit] in order to properly clean up (I think).
	[self unscheduleUpdate];
	
	[super onExit];
	
	mSceneController->OnSceneExited();
	Game::Instance()->OnSceneExited(mSceneController);
	mSceneController = NULL;
}

-(void) update:(ccTime)dt
{
	Game::Instance()->OnUpdate(dt);
	
	if (mSceneController) mSceneController->Update(dt);
	
	Game::Instance()->OnPostUpdate();
}

-(void) moveFocus:(FocusDirection)focusDirection
{
	[mFocusedLayer moveFocus:focusDirection];
}

-(void) applyMoveFocus
{
	[mFocusedLayer applyMoveFocus];
}

-(void) clickFocusedButton
{
	[mFocusedLayer clickFocusedButton];
}

@end
