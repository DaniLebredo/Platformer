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

#import "QuitLayer.h"
#import "Game.h"
#import "MainMenuController.h"
#import "TextButton.h"
#import "TextLabel.h"


@implementation QuitLayer

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	return nil;
}

-(id) initWithMainMenuController:(MainMenuController*)controller
{
	self = [super initWithSceneController:controller color:ccc4(16, 16, 16, 230)];
	if (self)
	{
		self.visible = NO;
		self.touchEnabled = NO;
		
		mMainMenuController = controller;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		CGFloat labelOffset = PNGMakeFloat(25);
		
		mLabel = [[TextLabel alloc] initWithStringValue:@""
												  width:PNGMakeFloat(400)
											  alignment:kCCTextAlignmentCenter];
		
		mLabel.position = ccp(0.5 * winSize.width, winSize.height - labelOffset);
		mLabel.anchorPoint = ccp(0.5, 1);
		[mContainer addChild:mLabel];
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* yesButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		yesButton.position = ccp(0.5 * winSize.width + 2 * offset + 0.5 * yesButton.width, 0.5 * winSize.height - PNGMakeFloat(25));
		yesButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_ExitToOS));
		[mContainer addChild:yesButton z:10];
		[mButtons setObject:yesButton forKey:@"Yes"];
		[yesButton release];
		
		TextButton* noButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		noButton.position = ccp(0.5 * winSize.width - 2 * offset - 0.5 * noButton.width, yesButton.position.y);
		noButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Back));
		[mContainer addChild:noButton z:10];
		[mButtons setObject:noButton forKey:@"No"];
		[noButton release];
		
		// --------------
		
		[self preDisplay];
	}
	return self;
}

-(void) dealloc
{
	mMainMenuController = NULL;
	
	[mLabel release];
	
	[super dealloc];
}

-(void) preDisplay
{
	[mLabel refreshWithLocalizedStringName:"Quit" smallFont:false];
	
	TextButton* yesButton = [mButtons objectForKey:@"Yes"];
	[yesButton refreshWithlocalizedTextName:"Yes"];
	
	TextButton* noButton = [mButtons objectForKey:@"No"];
	[noButton refreshWithlocalizedTextName:"No"];
}

@end
