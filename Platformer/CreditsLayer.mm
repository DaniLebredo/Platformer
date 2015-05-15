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

#import "CreditsLayer.h"
#import "Game.h"
#import "MainMenuController.h"
#import "TextButton.h"
#import "TextLabel.h"


@implementation CreditsLayer

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
		
		mMessageLabel = [[CCLabelBMFont alloc] initWithString:@""
													  fntFile:@"GroboldSmall.fnt"
														width:PNGMakeFloat(320)
													alignment:kCCTextAlignmentCenter];
		
		mMessageLabel.position = ccp(0.5 * winSize.width, 0.5 * winSize.height + 6.5 * PNGMakeFloat(10));
		mMessageLabel.anchorPoint = ccp(0.5, 1);
		//mMessageLabel.visible = NO;
		[mContainer addChild:mMessageLabel];
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* goBackButton = [[TextButton alloc] initWithName:@"Back"];
		goBackButton.position = ccp(offset + 0.5 * goBackButton.width, offset + 0.5 * goBackButton.height);
		goBackButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Back));
		[mContainer addChild:goBackButton z:10];
		[mButtons setObject:goBackButton forKey:@"Back"];
		[goBackButton release];
		
		// --------------
		
		[self preDisplay];
	}
	return self;
}

-(void) dealloc
{
	mMainMenuController = NULL;
	
	[mLabel release];
	[mMessageLabel release];
	
	[super dealloc];
}

-(void) preDisplay
{
	[mLabel refreshWithLocalizedStringName:"Credits" smallFont:false];
	
	mMessageLabel.string = @"Created by:\n------------\nJacopious\nmogibo\nspellbnd\n\nPowered by cocos2d, ObjectAL,\nBox2D and JsonCpp.";
}

@end
