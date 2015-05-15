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

#import "StartMenuLayer.h"
#import "Game.h"
#import "MainMenuController.h"
#import "TextButton.h"


@implementation StartMenuLayer

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	return nil;
}

-(id) initWithMainMenuController:(MainMenuController*)controller
{
	self = [super initWithSceneController:controller color:ccc4(0, 0, 0, 0)];
	if (self)
	{
		self.touchEnabled = YES;
		
		mMainMenuController = controller;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		mBackground = [[CCSprite alloc] initWithFile:@"BackgroundMainMenu.png"];
		//mBackground.position = ccp(0.5 * winSize.width, 0.5 * winSize.height);
		mBackground.position = ccp(0.5 * winSize.width, 0);
		mBackground.anchorPoint = ccp(0.5, 0);
		[self addChild:mBackground];
		
		mLogo = [[CCSprite alloc] initWithFile:@"Logo.png"];
		mLogo.position = ccp(0.5 * winSize.width, winSize.height - PNGMakeFloat(0));
		mLogo.anchorPoint = ccp(0.5, 1);
		[self addChild:mLogo];
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* startButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		startButton.position = ccp(0.5 * winSize.width, offset + 0.5 * startButton.height);
		startButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Start));
		mPreferredFocusButton = startButton;
		[self addChild:startButton z:10];
		[mButtons setObject:startButton forKey:@"Start"];
		[startButton release];
		
		TextButton* leaderboardsButton = [[TextButton alloc] initWithName:@"Leaderboards"];
		leaderboardsButton.position = ccp(offset + 0.5 * leaderboardsButton.width, 3 * offset + 0.5 * leaderboardsButton.height);
		leaderboardsButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Leaderboards));
		[self addChild:leaderboardsButton z:10];
		[mButtons setObject:leaderboardsButton forKey:@"Leaderboards"];
		[leaderboardsButton release];
		
		TextButton* achievementsButton = [[TextButton alloc] initWithName:@"Achievements"];
		achievementsButton.position = ccpAdd(leaderboardsButton.position, ccp(leaderboardsButton.width + 2 * offset, 0));
		achievementsButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Achievements));
		[self addChild:achievementsButton z:10];
		[mButtons setObject:achievementsButton forKey:@"Achievements"];
		[achievementsButton release];
		
		TextButton* settingsButton = [[TextButton alloc] initWithName:@"Settings"];
#ifdef ANDROID
		settingsButton.position = ccp(winSize.width - 2 * offset - 0.5 * settingsButton.width, 3 * offset + 0.5 * settingsButton.height);
#else
		settingsButton.position = ccp(winSize.width - offset - 0.5 * settingsButton.width, 3 * offset + 0.5 * settingsButton.height);
#endif
		settingsButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Settings));
		[self addChild:settingsButton z:10];
		[mButtons setObject:settingsButton forKey:@"Settings"];
		[settingsButton release];
		
		TextButton* infoButton = [[TextButton alloc] initWithName:@"Info"];
#ifdef ANDROID
		infoButton.position = ccp(2 * offset + 0.5 * infoButton.width, 3 * offset + 0.5 * infoButton.height);
#else
		infoButton.position = ccpSub(settingsButton.position, ccp(settingsButton.width + 2 * offset, 0));
#endif
		infoButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Info));
		[self addChild:infoButton z:10];
		[mButtons setObject:infoButton forKey:@"Info"];
		[infoButton release];
		
		[self showButtons];
	}
	return self;
}

-(void) dealloc
{
	mMainMenuController = NULL;
	
	[mBackground release];
	[mLogo release];
	
	[super dealloc];
}

-(void) showButtons
{
	for (NSString* key in mButtons)
	{
		TextButton* button = [mButtons objectForKey:key];
		if (button) button.visible = YES;
	}
	
#ifdef ANDROID
	TextButton* leaderboardsButton = [mButtons objectForKey:@"Leaderboards"];
	leaderboardsButton.visible = NO;
	
	TextButton* achievementsButton = [mButtons objectForKey:@"Achievements"];
	achievementsButton.visible = NO;
#endif
	
	TextButton* startButton = [mButtons objectForKey:@"Start"];
	[startButton refreshWithlocalizedTextName:"Start"];
}

-(void) hideButtons
{
	for (NSString* key in mButtons)
	{
		TextButton* button = [mButtons objectForKey:key];
		if (button) button.visible = NO;
	}
}

@end
