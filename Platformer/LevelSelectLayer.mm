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

#import "LevelSelectLayer.h"
#import "LevelSelectionController.h"
#import "Game.h"
#import "TextButton.h"
#import "ColorSprite.h"


@implementation LevelSelectLayer

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	return nil;
}

-(id) initWithLevelSelectionController:(LevelSelectionController*)controller
{
	self = [super initWithSceneController:controller color:ccc4(0, 0, 0, 0)];
	if (self)
	{
		self.touchEnabled = NO;
		self.visible = NO;
		
		mLevelSelectionController = controller;
		
		// --------------
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		mBackground = nil;

		mTemplate = [[CCSprite alloc] initWithFile:@"BackgroundLevels.png"];
		
		mRenderTexture = [[CCRenderTexture alloc] initWithWidth:(2 * mTemplate.contentSize.width) height:(2 * mTemplate.contentSize.height) pixelFormat:kCCTexture2DPixelFormat_RGB888];
		
		mAnimDuration = 0.5;
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		mLevelButtonsHolder = [[CCNode alloc] init];
		mLevelButtonsHolder.position = ccp(0, 0);
		[mContainer addChild:mLevelButtonsHolder z:5];
		
		mButtonKeys = [[NSMutableArray alloc] initWithCapacity:20];
		
		TextButton* goBackButton = [[TextButton alloc] initWithName:@"Back"];
		goBackButton.position = ccp(offset + 0.5 * goBackButton.width, offset + 0.5 * goBackButton.height);
		goBackButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Back));
		[self addChild:goBackButton z:5];
		[mButtons setObject:goBackButton forKey:@"Back"];
		[goBackButton release];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: LevelSelectLayer");
	
	mLevelSelectionController = NULL;
	
	[mButtonKeys release];
	[mLevelButtonsHolder release];
	
	[mRenderTexture release];
	[mBackground release];
	[mTemplate release];
	
	[super dealloc];
}

-(void) renderBackgroundForWorld:(int)worldId
{
	ccColor4B bkgColors[] = {
		ccc4(52, 97, 18, 255),
		ccc4(88, 130, 143, 255),
		ccc4(103, 79, 2, 255),
		ccc4(252, 83, 4, 255),
		ccc4(251, 148, 0, 255),
	};
	
	// ---
	
	[mRenderTexture begin];
	
	ColorSprite* sprite = [[ColorSprite alloc] initWithFile:@"BackgroundLevels.png"];
	sprite.position = ccp(0.5 * mRenderTexture.contentSize.width, 0.5 * mRenderTexture.contentSize.height);
	sprite.scaleX = 2;
	sprite.scaleY = -2;
	sprite.color = ccc4FFromccc4B(bkgColors[worldId]);
	[sprite visit];
	[sprite release];
	
	[mRenderTexture end];
}

-(void) showLevelsForWorld:(int)worldId focusLevel:(int)levelId
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	[self renderBackgroundForWorld:worldId];
	
	if (mBackground != nil)
	{
		[mBackground removeFromParentAndCleanup:NO];
		[mBackground release];
	}
	mBackground = [[CCSprite alloc] initWithTexture:mRenderTexture.sprite.texture];
	mBackground.position = ccp(0.5 * winSize.width, 0.5 * winSize.height);
	[self addChild:mBackground z:-5];
	
	[self removeFocus];
	
	// Remove all previously shown level buttons.
	[mButtons removeObjectsForKeys:mButtonKeys];
	[mButtonKeys removeAllObjects];
	
	[mLevelButtonsHolder removeAllChildren];
	
	// ---
	
	// Layout of sprites on screen.
	CGPoint startPoint = ccp(0.5 * winSize.width, winSize.height - PNGMakeFloat(50 + 32));
	CGPoint elemDist = PNGMakePoint(96, 96);
	int itemsPerRow = 4;
	int middleElemIndex = itemsPerRow / 2;
	
	WorldData& wd = Game::Instance()->Data().World(worldId);
	
	for (int levelIndex = 0; levelIndex < wd.NumLevels(); ++levelIndex)
	{
		LevelData& ld = wd.Level(levelIndex);
		
		NSString* btnName = [[NSString alloc] initWithFormat:@"Level%d", worldId];
		NSString* btnText = @"";
		
		if (!ld.Locked())
		{
			btnText = [[NSString alloc] initWithFormat:@"%d", levelIndex + 1];
		}
		
		TextButton* levelButton = [[TextButton alloc] initWithName:btnName text:btnText smallFont:false textOffset:PNGMakePoint(0, 4)];
		
		[btnName release];
		[btnText release];
		
		// Set focus if necessary.
		if (!ld.Locked() && levelIndex == levelId)
		{
			mPreferredFocusButton = levelButton;
		}
		
		// Calculate button position.
		CGFloat offsetX = 0;
		
		if (itemsPerRow % 2 != 0)
			offsetX = ((levelIndex % itemsPerRow) - middleElemIndex) * elemDist.x;
		else offsetX = ((levelIndex % itemsPerRow) - middleElemIndex + 0.5) * elemDist.x;
		
		levelButton.position = ccp(startPoint.x + offsetX, startPoint.y - elemDist.y * (levelIndex / itemsPerRow));
		levelButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Level));
		levelButton.userInt = levelIndex;
		levelButton.label.scale = 1.25;
		
		[mLevelButtonsHolder addChild:levelButton z:5];
		
		// Check if star(s) or a lock needs to be put on top of the button.
		if (!ld.Locked())
		{
			// Only unlocked levels can be clicked.
			NSString* btnKey = [[NSString alloc] initWithFormat:@"Level%d", levelIndex];
			
			[mButtonKeys addObject:btnKey];
			[mButtons setObject:levelButton forKey:btnKey];
			
			[btnKey release];
			
			for (int idx = 0; idx < 3; ++idx)
			{
				CGFloat yOffset = (idx == 1) ? PNGMakeFloat(21) : PNGMakeFloat(18);
				NSString* starFrameName = (idx < ld.NumStarsCollected()) ? @"Star0" : @"Star1";
				CCSprite* star = [[CCSprite alloc] initWithSpriteFrameName:starFrameName];
				star.position = ccp(levelButton.position.x + 0.6 * (idx - 1) * star.contentSize.width,
									levelButton.position.y - yOffset);
				star.scale = 0.6;
				[mLevelButtonsHolder addChild:star z:15];
				[star release];
			}
		}
		else
		{
			// Add a lock on top of the level button.
			CCSprite* lock = [[CCSprite alloc] initWithFile:@"LevelLock.png"];
			lock.position = levelButton.position;
			[mLevelButtonsHolder addChild:lock z:10];
			[lock release];
		}
		
		[levelButton release];
	}
}

@end
