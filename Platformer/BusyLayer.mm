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

#import "BusyLayer.h"
#import "Game.h"


@implementation BusyLayer

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(id) init
{
	return nil;
}

-(id) initWithSceneController:(SceneController*)controller
{
	self = [super initWithColor:ccc4(16, 16, 16, 230)];
	if (self)
	{
		self.visible = NO;
		self.touchEnabled = NO;
		
		mSceneController = controller;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		mMessageLabel = [[CCLabelBMFont alloc] initWithString:@"Busy..."
													  fntFile:@"GroboldSmall.fnt"
														width:PNGMakeFloat(320)
													alignment:kCCTextAlignmentCenter];
		
		mMessageLabel.position = ccp(0.5 * winSize.width, 0.5 * winSize.height);
		mMessageLabel.anchorPoint = ccp(0.5, 1);
		[self addChild:mMessageLabel];
	}
	return self;
}

-(void) dealloc
{
	mSceneController = NULL;
	
	[mMessageLabel release];
	
	[super dealloc];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	return YES;
}

@end
