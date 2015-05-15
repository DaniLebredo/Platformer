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

#import "LoadingLayer.h"
#import "LoadingController.h"
#import "TextLabel.h"
#import "Game.h"


@implementation LoadingLayer

-(id) init
{
	return nil;
}

-(id) initWithSceneController:(LoadingController*)controller mode:(LoadingMode)mode
{
	// If loading scene is displayed with logo, set background color to white.
	// Otherwise, set it to black.
	
	if (mode == Loading_Logo)
		self = [super initWithColor:ccc4(255, 255, 255, 255)];
	else self = [super initWithColor:ccc4(16, 16, 16, 230)];
	
	if (self)
	{
		mSceneController = controller;
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		mLogo = nil;
		mLabel = nil;
		
		// --------------
		
		if (mode == Loading_Logo)
		{
			mLogo = [[CCSprite alloc] initWithFile:@"LogoTeamLL.png"];
			mLogo.position = ccp(0.5 * winSize.width, 0.5 * winSize.height);
			[self addChild:mLogo];
		}
		else if (mode == Loading_TextMessage)
		{
			mLabel = [[TextLabel alloc] initWithLocalizedStringName:"Loading"
															  width:PNGMakeFloat(320)
														  alignment:kCCTextAlignmentCenter
														  smallFont:false];
			
			mLabel.position = ccp(0.5 * winSize.width, 0.5 * winSize.height);
			[self addChild:mLabel];
		}
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: LoadingLayer");
	
	mSceneController = NULL;
	
	[mLabel release];
	
	[mLogo release];
	
	[super dealloc];
	
	[[CCTextureCache sharedTextureCache] removeTextureForKey:@"LogoTeamLL.png"];
}

@end
