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

#import "LifeLostLayer.h"
#import "LevelController.h"
#import "Game.h"
#import "TextButton.h"
#import "TextLabel.h"


@implementation LifeLostLayer

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	return nil;
}

-(id) initWithLevelController:(LevelController*)controller
{
	self = [super initWithSceneController:controller color:ccc4(0, 0, 0, 0)];
	if (self)
	{
		self.touchEnabled = NO;
		self.visible = NO;
		
		mLevelController = controller;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		// --------------
		
		CGFloat labelOffset = PNGMakeFloat(25);
		
		mLabel = [[TextLabel alloc] initWithStringValue:@""
												  width:PNGMakeFloat(400)
											  alignment:kCCTextAlignmentCenter];
		
		mLabel.position = ccp(0.5 * winSize.width, winSize.height - labelOffset);
		mLabel.anchorPoint = ccp(0.5, 1);
		[mContainer addChild:mLabel];
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* restartButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		restartButton.position = ccp(0.5 * winSize.width + 2 * offset + 0.5 * restartButton.width, 0.5 * winSize.height - PNGMakeFloat(25));
		restartButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Restart));
		mPreferredFocusButton = restartButton;
		[mContainer addChild:restartButton z:10];
		[mButtons setObject:restartButton forKey:@"Restart"];
		[restartButton release];
		
		TextButton* quitButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		quitButton.position = ccp(0.5 * winSize.width - 2 * offset - 0.5 * quitButton.width, restartButton.position.y);
		quitButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Quit));
		[mContainer addChild:quitButton z:10];
		[mButtons setObject:quitButton forKey:@"Quit"];
		[quitButton release];
		
		// --------------
		
		[self preDisplay];
	}
	return self;
}

-(void) dealloc
{
	mLevelController = NULL;
	
	[mLabel release];
	
	[super dealloc];
}

-(void) preDisplay
{
	[mLabel refreshWithLocalizedStringName:"LifeLost" smallFont:false];
	
	TextButton* restartButton = [mButtons objectForKey:@"Restart"];
	[restartButton refreshWithlocalizedTextName:"Retry"];
	
	TextButton* quitButton = [mButtons objectForKey:@"Quit"];
	[quitButton refreshWithlocalizedTextName:"Menu"];
}

@end
