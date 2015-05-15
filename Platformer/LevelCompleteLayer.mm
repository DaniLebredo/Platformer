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

#import "LevelCompleteLayer.h"
#import "LevelController.h"
#import "Game.h"
#import "TextButton.h"
#import "TextLabel.h"


@implementation LevelCompleteLayer

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
		
		mTimer = 0;
		mShortBreak = false;
		
		// Number of coins is initially set to -1, in order for update function to work properly.
		// The same goes for time. For lives, this is not necessary.
		mCountedCoins = -1;
		mCountedLives = 0;
		mCountedTime = -1;
		
		// --------------
		
		mCanTouch = false;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		mLabel = [[TextLabel alloc] initWithStringValue:@""
												  width:PNGMakeFloat(400)
											  alignment:kCCTextAlignmentCenter
											  smallFont:false];
		
		mLabel.position = ccp(0.5 * winSize.width, winSize.height - PNGMakeFloat(25));
		mLabel.anchorPoint = ccp(0.5, 1);
		[self addChild:mLabel];
		
		// --------------
		
		mCoinsIcon = [[CCSprite alloc] initWithFile:@"Coin.png"];
		mCoinsIcon.position = ccp(0.5 * winSize.width - PNGMakeFloat(140), 0.5 * winSize.height + PNGMakeFloat(55));
		mCoinsIcon.visible = NO;
		[self addChild:mCoinsIcon];
		
		mLives = [[NSMutableArray alloc] initWithCapacity:3];
		for (int i = 0; i < 3; ++i)
		{
			CCSprite* heart = [[CCSprite alloc] initWithFile:@"Heart.png"];
			heart.position = ccpAdd(mCoinsIcon.position, PNGMakePoint(35 * i, -50));
			heart.visible = NO;
			[self addChild:heart];
			[mLives addObject:heart];
			[heart release];
		}
		
		mTimeIcon = [[CCSprite alloc] initWithFile:@"Clock.png"];
		mTimeIcon.position = ccpAdd(mCoinsIcon.position, PNGMakePoint(0, -100));
		mTimeIcon.visible = NO;
		[self addChild:mTimeIcon];
		
		// --------------
		
		mCoinsLabel = [[TextLabel alloc] initWithStringValue:@""
													   width:PNGMakeFloat(320)
												   alignment:kCCTextAlignmentLeft
												   smallFont:true];
		
		mCoinsLabel.position = ccpAdd(mCoinsIcon.position, PNGMakePoint(30, -2));
		mCoinsLabel.anchorPoint = ccp(0, 0.5);
		mCoinsLabel.visible = NO;
		[self addChild:mCoinsLabel];
		
		mTimeLabel = [[TextLabel alloc] initWithStringValue:@""
													  width:PNGMakeFloat(320)
												  alignment:kCCTextAlignmentLeft
												  smallFont:true];
		
		mTimeLabel.position = ccpAdd(mTimeIcon.position, PNGMakePoint(30, -2));
		mTimeLabel.anchorPoint = ccp(0, 0.5);
		mTimeLabel.visible = NO;
		[self addChild:mTimeLabel];
		
		// --------------
		
		mStars = [[NSMutableArray alloc] initWithCapacity:3];
		mGlitter = [[NSMutableArray alloc] initWithCapacity:3];
		
		for (int i = 0; i < 3; ++i)
		{
			CCSprite* star = [[CCSprite alloc] initWithSpriteFrameName:@"Star0"];
			star.position = ccpAdd(mCoinsIcon.position, PNGMakePoint(125, -50 * i));
			star.visible = NO;
			[self addChild:star];
			[mStars addObject:star];
			[star release];
			
			CCSprite* glitter = [[CCSprite alloc] initWithSpriteFrameName:@"Stars0"];
			glitter.position = star.position;
			glitter.visible = NO;
			glitter.scale = 2;
			[self addChild:glitter];
			[mGlitter addObject:glitter];
			[glitter release];
		}
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* advanceButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		advanceButton.position = ccp(0.5 * winSize.width + 3 * offset + advanceButton.width, offset + 0.5 * advanceButton.height);
		advanceButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Advance));
		advanceButton.opacity = 0;
		[self addChild:advanceButton z:10];
		[mButtons setObject:advanceButton forKey:@"Advance"];
		[advanceButton release];
		
		TextButton* worldCompletedButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		worldCompletedButton.position = advanceButton.position;
		worldCompletedButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_WorldCompleted));
		worldCompletedButton.opacity = 0;
		[self addChild:worldCompletedButton z:10];
		[mButtons setObject:worldCompletedButton forKey:@"WorldCompleted"];
		[worldCompletedButton release];
		
		TextButton* gameCompletedButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		gameCompletedButton.position = advanceButton.position;
		gameCompletedButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_GameCompleted));
		gameCompletedButton.opacity = 0;
		[self addChild:gameCompletedButton z:10];
		[mButtons setObject:gameCompletedButton forKey:@"GameCompleted"];
		[gameCompletedButton release];
		
		TextButton* restartButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		restartButton.position = ccp(0.5 * winSize.width, advanceButton.position.y);
		restartButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Restart));
		restartButton.opacity = 0;
		[self addChild:restartButton z:10];
		[mButtons setObject:restartButton forKey:@"Restart"];
		[restartButton release];
		
		TextButton* quitButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		quitButton.position = ccp(0.5 * winSize.width - 3 * offset - advanceButton.width, advanceButton.position.y);
		quitButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Quit));
		quitButton.opacity = 0;
		[self addChild:quitButton z:10];
		[mButtons setObject:quitButton forKey:@"Quit"];
		[quitButton release];
		
		TextButton* facebookButton = [[TextButton alloc] initWithName:@"Facebook"];
		facebookButton.position = ccp(0.5 * facebookButton.width + PNGMakeFloat(10),
									   0.5 * winSize.height + 0.5 * facebookButton.height + PNGMakeFloat(10));
		facebookButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Facebook));
		facebookButton.opacity = 0;
#ifdef ANDROID
		facebookButton.visible = NO;
#endif
		[self addChild:facebookButton z:10];
		[mButtons setObject:facebookButton forKey:@"Facebook"];
		[facebookButton release];
		
		TextButton* twitterButton = [[TextButton alloc] initWithName:@"Twitter"];
		twitterButton.position = ccp(facebookButton.position.x,
									  0.5 * winSize.height - 0.5 * twitterButton.height - PNGMakeFloat(10));
		twitterButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Twitter));
		twitterButton.opacity = 0;
#ifdef ANDROID
		twitterButton.visible = NO;
#endif
		[self addChild:twitterButton z:10];
		[mButtons setObject:twitterButton forKey:@"Twitter"];
		[twitterButton release];
		
		TextButton* leaderboardsButton = [[TextButton alloc] initWithName:@"Leaderboards"];
		leaderboardsButton.position = ccp(winSize.width - 0.5 * leaderboardsButton.width - PNGMakeFloat(10),
										  0.5 * winSize.height + 0.5 * leaderboardsButton.height + PNGMakeFloat(10));
		leaderboardsButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Leaderboards));
		leaderboardsButton.opacity = 0;
#ifdef ANDROID
		leaderboardsButton.visible = NO;
#endif
		[self addChild:leaderboardsButton z:10];
		[mButtons setObject:leaderboardsButton forKey:@"Leaderboards"];
		[leaderboardsButton release];
		
		TextButton* achievementsButton = [[TextButton alloc] initWithName:@"Achievements"];
		achievementsButton.position = ccp(leaderboardsButton.position.x,
										  0.5 * winSize.height - 0.5 * achievementsButton.height - PNGMakeFloat(10));
		achievementsButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Achievements));
		achievementsButton.opacity = 0;
#ifdef ANDROID
		achievementsButton.visible = NO;
#endif
		[self addChild:achievementsButton z:10];
		[mButtons setObject:achievementsButton forKey:@"Achievements"];
		[achievementsButton release];
	}
	return self;
}

-(void) dealloc
{
	mLevelController = NULL;
	
	[mStars release];
	[mGlitter release];
	
	[mLives release];
	
	[mLabel release];
	[mCoinsLabel release];
	[mTimeLabel release];
	
	[mCoinsIcon release];
	[mTimeIcon release];
	
	[super dealloc];
}

-(void) preDisplay
{
	bool advanceButtonVisible = false;
	bool gameCompletedButtonVisible = false;
	bool worldCompletedButtonVisible = false;
	
	if (mLevelController->NextWorldId() == -1 && mLevelController->NextLevelId() == -1)
	{
		// Entire game completed!
		gameCompletedButtonVisible = true;
	}
	else if (mLevelController->NextLevelId() == 0)
	{
		// World completed!
		worldCompletedButtonVisible = true;
	}
	else
	{
		// Level completed!
		advanceButtonVisible = true;
	}
	
	TextButton* advanceButton = [mButtons objectForKey:@"Advance"];
	[advanceButton refreshWithlocalizedTextName:"Next"];
	advanceButton.visible = advanceButtonVisible ? YES : NO;
	if (advanceButtonVisible) mPreferredFocusButton = advanceButton;
	
	TextButton* gameCompletedButton = [mButtons objectForKey:@"GameCompleted"];
	[gameCompletedButton refreshWithlocalizedTextName:"Next"];
	gameCompletedButton.visible = gameCompletedButtonVisible ? YES : NO;
	if (gameCompletedButtonVisible) mPreferredFocusButton = gameCompletedButton;
	
	TextButton* worldCompletedButton = [mButtons objectForKey:@"WorldCompleted"];
	[worldCompletedButton refreshWithlocalizedTextName:"Next"];
	worldCompletedButton.visible = worldCompletedButtonVisible ? YES : NO;
	if (worldCompletedButtonVisible) mPreferredFocusButton = worldCompletedButton;
	
	TextButton* restartButton = [mButtons objectForKey:@"Restart"];
	[restartButton refreshWithlocalizedTextName:"Retry"];
	
	TextButton* quitButton = [mButtons objectForKey:@"Quit"];
	[quitButton refreshWithlocalizedTextName:"Menu"];
	
	// ---
	
	const std::string& strLevelCompleted = Game::Instance()->Data().LocalizedText("LevelCompleted");
	NSString* levelCompletedText = [[NSString alloc] initWithUTF8String:strLevelCompleted.c_str()];
	NSString* labelText = [[NSString alloc] initWithFormat:levelCompletedText, mLevelController->WorldId() + 1, mLevelController->LevelId() + 1];
	
	mLabel.string = labelText;
	
	[labelText release];
	[levelCompletedText release];
}

-(void) showStarAtIndex:(int)index
{
	CCSprite* star = [mStars objectAtIndex:index];
	
	star.scale = 0;
	star.visible = YES;
	
	[star runAction:[CCEaseElasticOut actionWithAction:
					 [CCScaleTo actionWithDuration:1 scale:1]]];
}

-(void) showGlitterForStarAtIndex:(int)index
{
	CCSpriteFrameCache* sfc = [CCSpriteFrameCache sharedSpriteFrameCache];
	
	NSArray* spriteFrames = [[NSArray alloc] initWithObjects:
							 [sfc spriteFrameByName:@"Stars0"],
							 [sfc spriteFrameByName:@"Stars1"],
							 [sfc spriteFrameByName:@"Stars2"],
							 [sfc spriteFrameByName:@"Stars3"],
							 nil];
	
	CCAnimation* animation = [[CCAnimation alloc] initWithSpriteFrames:spriteFrames delay:0.05];
	CCFiniteTimeAction* animAction = [[CCAnimate alloc] initWithAnimation:animation];
	
	CCSprite* glitter = [mGlitter objectAtIndex:index];
	glitter.visible = YES;
	[glitter runAction:[CCSequence actions:animAction, [CCFadeTo actionWithDuration:0.2 opacity:0], nil]];
	
	[animAction release];
	[animation release];
	[spriteFrames release];
}

-(void) setStarAtIndex:(int)index success:(BOOL)success
{
	if (success)
	{
		[self showStarAtIndex:index];
		[self showGlitterForStarAtIndex:index];
		SoundManager::Instance()->ScheduleEffect("EndOfLevel.caf");
	}
	else
	{
		CCSprite* star = [mStars objectAtIndex:index];
		star.opacity = 64;
		[self showStarAtIndex:index];
		SoundManager::Instance()->ScheduleEffect("EnemyKilled.caf");
	}
}

-(void) calculateStats
{
	mTimer = 0;
	mShortBreak = true;
	
	NSString* coinsText = [[NSString alloc] initWithFormat:@"0/%d", mLevelController->NumCoinsToCollect()];
	mCoinsLabel.string = coinsText;
	[coinsText release];
	
	mTimeLabel.string = @"0:00";
	
	[self scheduleUpdate];
}

-(void) countCoins
{
	ccTime countTreshold = 0.01;
	
	if (mTimer > countTreshold)
	{
		while (mTimer > countTreshold)
		{
			++mCountedCoins;
			mTimer -= countTreshold;
		}
		
		mCountedCoins = Clamp(mCountedCoins, 0, mLevelController->NumCoinsCollected());
		
		NSString* newText = [[NSString alloc] initWithFormat:@"%d/%d", mCountedCoins, mLevelController->NumCoinsToCollect()];
		mCoinsLabel.string = newText;
		[newText release];
		
		if (mCountedCoins == mLevelController->NumCoinsCollected())
		{
			BOOL success = (mCountedCoins == mLevelController->NumCoinsToCollect()) ? YES : NO;
			
			[self setStarAtIndex:0 success:success];
			
			mTimer = 0;
			mShortBreak = true;
		}
	}
}

-(void) countLives
{
	ccTime countTreshold = 0.075;
	
	if (mTimer > countTreshold)
	{
		while (mTimer > countTreshold)
		{
			++mCountedLives;
			mTimer -= countTreshold;
		}
		
		mCountedLives = Clamp(mCountedLives, 0, mLevelController->NumLivesTotal());
		
		for (int index = 0; index < mCountedLives; ++index)
		{
			CCSprite* heart = [mLives objectAtIndex:index];
			heart.opacity = (index < mLevelController->NumLivesLeft()) ? 255 : 64;
			
			if (!heart.visible)
			{
				heart.visible = YES;
				heart.scale = 0;
				
				[heart runAction:
				 [CCEaseElasticOut actionWithAction:
				  [CCScaleTo actionWithDuration:0.5 scale:1]]
				 ];
			}
		}
		
		if (mCountedLives == mLevelController->NumLivesTotal())
		{
			BOOL success = (mLevelController->NumLivesLeft() == mLevelController->NumLivesTotal()) ? YES : NO;
			
			[self setStarAtIndex:1 success:success];
			
			mTimer = 0;
			mShortBreak = true;
		}
	}
}

-(void) showTime
{
	mCountedTime = (int)ceilf(mLevelController->TimeLeft());
	
	NSString* newText = [[NSString alloc] initWithFormat:@"%d:%02d", mCountedTime / 60, mCountedTime % 60];
	mTimeLabel.string = newText;
	[newText release];
	
	BOOL success = (mCountedTime > 0) ? YES : NO;
	
	[self setStarAtIndex:2 success:success];
	
	mTimer = 0;
	mShortBreak = true;
}

-(void) myCallback:(CCNode*)node
{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	CCSpriteFrameCache* sfc = [CCSpriteFrameCache sharedSpriteFrameCache];
	
	NSArray* spriteFrames = [[NSArray alloc] initWithObjects:
							 [sfc spriteFrameByName:@"Explosion0"],
							 [sfc spriteFrameByName:@"Explosion1"],
							 [sfc spriteFrameByName:@"Explosion2"],
							 [sfc spriteFrameByName:@"Explosion3"],
							 [sfc spriteFrameByName:@"Explosion4"],
							 [sfc spriteFrameByName:@"Explosion5"],
							 [sfc spriteFrameByName:@"Explosion6"],
							 [sfc spriteFrameByName:@"Explosion7"],
							 [sfc spriteFrameByName:@"Explosion8"],
							 nil];
	
	CCAnimation* animation = [[CCAnimation alloc] initWithSpriteFrames:spriteFrames delay:0.05];
	CCFiniteTimeAction* animAction = [[CCAnimate alloc] initWithAnimation:animation];
	
	CCSprite* smoke = [CCSprite spriteWithSpriteFrameName:@"Stars0"];
	smoke.position = ccp(0.5 * winSize.width + PNGMakeFloat(95), 0.5 * winSize.height);
	smoke.scale = 4;
	[smoke runAction:[CCSequence actions:animAction, [CCFadeTo actionWithDuration:0.1 opacity:0], nil]];
	[self addChild:smoke z:8];
	
	[animAction release];
	[animation release];
	[spriteFrames release];
	
	//SoundManager::Instance()->ScheduleEffect("StarCollected.caf");
}

-(void) update:(ccTime)dt
{
	mTimer += dt;
	
	if (mShortBreak)
	{
		if (mTimer > 0.5)
		{
			mTimer = 0;
			mShortBreak = false;
		}
	}
	else if (mCountedCoins != mLevelController->NumCoinsCollected())
	{
		mCoinsIcon.visible = YES;
		mCoinsLabel.visible = YES;
		[self countCoins];
	}
	else if (mCountedLives != mLevelController->NumLivesTotal())
	{
		[self countLives];
	}
	else if (mCountedTime != (int)ceilf(mLevelController->TimeLeft()))
	{
		mTimeIcon.visible = YES;
		mTimeLabel.visible = YES;
		[self showTime];
	}
	else
	{
		[self unscheduleUpdate];
		
		// ---
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		NSString* frameName = [[NSString alloc] initWithFormat:@"Medal%d.png", 3 - mLevelController->NumStarsCollected()];
		
		CCSprite* medalIcon = [[CCSprite alloc] initWithFile:frameName];
		medalIcon.position = ccp(0.5 * winSize.width + PNGMakeFloat(95), 0.5 * winSize.height);
		medalIcon.scale = 2;
		medalIcon.opacity = 0;
		[medalIcon runAction:[CCEaseExponentialIn actionWithAction:[CCScaleTo actionWithDuration:0.4 scale:1]]];
		[medalIcon runAction:[CCSequence actions:
							  [CCFadeTo actionWithDuration:0.4 opacity:255],
							  [CCCallFuncN actionWithTarget:self selector:@selector(myCallback:)],
							  nil]];
		[self addChild:medalIcon z:10];
		[medalIcon release];
		
		[frameName release];
		
		SoundManager::Instance()->ScheduleEffect("Medal.caf");
		
		// ---
		
		for (NSString* key in mButtons)
		{
			TextButton* button = [mButtons objectForKey:key];
			
			if (button)
			{
				[button runAction:[CCFadeIn actionWithDuration:1]];
			}
		}
		
		mCanTouch = true;
	}
}

@end
