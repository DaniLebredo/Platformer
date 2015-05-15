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

#import "PauseMenuLayer.h"
#import "Game.h"
#import "LevelController.h"
#import "TextButton.h"
#import "TextLabel.h"


@implementation PauseMenuLayer

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	return nil;
}

-(id) initWithLevelController:(LevelController*)controller
{
	self = [super initWithSceneController:controller color:ccc4(16, 16, 16, 230)];
	if (self)
	{
		self.touchEnabled = NO;
		self.visible = NO;
		
		mLevelController = controller;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		mLabel = [[TextLabel alloc] initWithStringValue:@""
												  width:PNGMakeFloat(400)
											  alignment:kCCTextAlignmentCenter
											  smallFont:false];
		
		mLabel.position = ccp(0.5 * winSize.width, winSize.height - PNGMakeFloat(25));
		mLabel.anchorPoint = ccp(0.5, 1);
		[mContainer addChild:mLabel];
		
		// --------------
		
		mCoinsIcon = [[CCSprite alloc] initWithFile:@"Coin.png"];
		mCoinsIcon.position = ccp(0.5 * winSize.width - PNGMakeFloat(40), 0.5 * winSize.height + PNGMakeFloat(55));
		[mContainer addChild:mCoinsIcon];
		
		mLives = [[NSMutableArray alloc] initWithCapacity:3];
		for (int i = 0; i < 3; ++i)
		{
			CCSprite* heart = [[CCSprite alloc] initWithFile:@"Heart.png"];
			heart.position = ccpAdd(mCoinsIcon.position, PNGMakePoint(40 * i, -50));
			[mContainer addChild:heart];
			[mLives addObject:heart];
			[heart release];
		}
		
		mTimeIcon = [[CCSprite alloc] initWithFile:@"Clock.png"];
		mTimeIcon.position = ccpAdd(mCoinsIcon.position, PNGMakePoint(0, -100));
		[mContainer addChild:mTimeIcon];
		
		// --------------
		
		mCoinsLabel = [[TextLabel alloc] initWithStringValue:@""
													   width:PNGMakeFloat(320)
												   alignment:kCCTextAlignmentLeft
												   smallFont:true];
		
		mCoinsLabel.position = ccpAdd(mCoinsIcon.position, PNGMakePoint(30, -2));
		mCoinsLabel.anchorPoint = ccp(0, 0.5);
		[mContainer addChild:mCoinsLabel];
		
		mTimeLabel = [[TextLabel alloc] initWithStringValue:@""
													  width:PNGMakeFloat(320)
												  alignment:kCCTextAlignmentLeft
												  smallFont:true];
		
		mTimeLabel.position = ccpAdd(mTimeIcon.position, PNGMakePoint(30, -2));
		mTimeLabel.anchorPoint = ccp(0, 0.5);
		[mContainer addChild:mTimeLabel];
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* resumeButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		resumeButton.position = ccp(0.5 * winSize.width + 3 * offset + resumeButton.width, offset + 0.5 * resumeButton.height);
		resumeButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Resume));
		mPreferredFocusButton = resumeButton;
		[mContainer addChild:resumeButton z:10];
		[mButtons setObject:resumeButton forKey:@"Resume"];
		[resumeButton release];
		
		TextButton* restartButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		restartButton.position = ccp(0.5 * winSize.width, resumeButton.position.y);
		restartButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Restart));
		[mContainer addChild:restartButton z:10];
		[mButtons setObject:restartButton forKey:@"Restart"];
		[restartButton release];
		
		TextButton* quitButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		quitButton.position = ccp(0.5 * winSize.width - 3 * offset - resumeButton.width, resumeButton.position.y);
		quitButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Quit));
		[mContainer addChild:quitButton z:10];
		[mButtons setObject:quitButton forKey:@"Quit"];
		[quitButton release];
		
		TextButton* settingsButton = [[TextButton alloc] initWithName:@"Settings"];
		settingsButton.position = ccp(winSize.width - offset - 0.5 * settingsButton.width,
									  winSize.height - offset - 0.5 * settingsButton.height);
		settingsButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Settings));
		[mContainer addChild:settingsButton z:10];
		[mButtons setObject:settingsButton forKey:@"Settings"];
		[settingsButton release];
		
		// --------------
		
		[self preDisplay];
	}
	return self;
}

-(void) dealloc
{
	mLevelController = NULL;
	
	[mLabel release];
	
	// ---
	
	[mCoinsIcon release];
	[mCoinsLabel release];
	
	[mLives release];
	
	[mTimeIcon release];
	[mTimeLabel release];
	
	// ---
	
	[super dealloc];
}

-(void) preDisplay
{
	const std::string& strPaused = Game::Instance()->Data().LocalizedText("Paused");
	NSString* pausedText = [[NSString alloc] initWithUTF8String:strPaused.c_str()];
	NSString* labelText = [[NSString alloc] initWithFormat:pausedText, mLevelController->WorldId() + 1, mLevelController->LevelId() + 1];
	
	mLabel.string = labelText;
	
	[labelText release];
	[pausedText release];
	
	// ---
	
	TextButton* resumeButton = [mButtons objectForKey:@"Resume"];
	[resumeButton refreshWithlocalizedTextName:"Resume"];
	
	TextButton* restartButton = [mButtons objectForKey:@"Restart"];
	[restartButton refreshWithlocalizedTextName:"Retry"];
	
	TextButton* quitButton = [mButtons objectForKey:@"Quit"];
	[quitButton refreshWithlocalizedTextName:"Menu"];
}

-(void) refreshStats
{
	NSString* txtCoins = [[NSString alloc] initWithFormat:@"%d/%d", mLevelController->NumCoinsCollected(), mLevelController->NumCoinsToCollect()];
	mCoinsLabel.string = txtCoins;
	[txtCoins release];
	
	// ---
	
	for (int i = 0; i < 3; ++i)
	{
		CCSprite* heart = [mLives objectAtIndex:i];
		heart.opacity = (i < mLevelController->NumLivesLeft()) ? 255 : 64;
	}
	
	// ---
	
	int timeLeft = (int)ceilf(mLevelController->TimeLeft());
	
	NSString* txtTime = [[NSString alloc] initWithFormat:@"%d:%02d", timeLeft / 60, timeLeft % 60];
	mTimeLabel.string = txtTime;
	[txtTime release];
}

@end
