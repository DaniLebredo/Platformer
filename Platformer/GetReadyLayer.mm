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

#import "GetReadyLayer.h"
#import "LevelController.h"
#import "Game.h"
#import "TextLabel.h"


@implementation GetReadyLayer

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(id) init
{
	return nil;
}

-(id) initWithLevelController:(LevelController*)controller
{
	self = [super initWithColor:ccc4(16, 16, 16, 230)];
	if (self)
	{
		self.touchEnabled = YES;
		
		mSceneController = controller;
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		mLabel = [[TextLabel alloc] initWithLocalizedStringName:"GetReady"
														  width:PNGMakeFloat(320)
													  alignment:kCCTextAlignmentCenter
													  smallFont:false];
		
		mLabel.position = ccp(0.5 * winSize.width, 0.5 * winSize.height);
		[self addChild:mLabel];
	}
	return self;
}

-(void) dealloc
{
	mSceneController = NULL;
	
	[mLabel release];
	
	[super dealloc];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	mSceneController->OnButtonClicked(Btn_Ready);
}

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
}

@end
