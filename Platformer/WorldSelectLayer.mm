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

#import "WorldSelectLayer.h"
#import "LevelSelectionController.h"
#import "Game.h"
#import "TextButton.h"
#import "TextLabel.h"
#import "ColorSprite.h"
#import "GameControllerManager.h"


@implementation WorldSelectLayer

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	return nil;
}

-(id) initWithLevelSelectionController:(LevelSelectionController*)controller;
{
	self = [super initWithSceneController:controller color:ccc4(0, 0, 0, 0)];
	if (self)
	{
		self.touchEnabled = YES;
		
		mLevelSelectionController = controller;
		
		// --------------
		
		mItemIndex = 0;
		mMoved = NO;
		mCanSwipe = true;
		mGesturesEnabled = true;
		
		// --------------
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		mTemplate = [[CCSprite alloc] initWithFile:@"BackgroundLevels.png"];
		
		mRenderTexture = [[CCRenderTexture alloc] initWithWidth:(2 * mTemplate.contentSize.width) height:(2 * mTemplate.contentSize.height) pixelFormat:kCCTexture2DPixelFormat_RGB888];
		[self renderBackground];
		
		mBackground = [[CCSprite alloc] initWithTexture:mRenderTexture.sprite.texture];
		mBackground.position = ccp(0.5 * winSize.width, 0.5 * winSize.height);
		[self addChild:mBackground];
		
		// --------------
		
		CGFloat labelOffset = PNGMakeFloat(25);
		
		mLabel = [[TextLabel alloc] initWithLocalizedStringName:"SelectWorld"
														  width:PNGMakeFloat(400)
													  alignment:kCCTextAlignmentCenter
													  smallFont:false];
		
		mLabel.position = ccp(0.5 * winSize.width, winSize.height - labelOffset);
		mLabel.anchorPoint = ccp(0.5, 1);
		[self addChild:mLabel];
		
		// --------------
		
		mWorldButtonsHolder = [[CCNode alloc] init];
		mWorldButtonsHolder.position = ccp(0, 0);
		[self addChild:mWorldButtonsHolder z:5];
		
		mButtonKeys = [[NSMutableArray alloc] initWithCapacity:20];
		mWorldButtons = [[NSMutableArray alloc] initWithCapacity:20];
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* goBackButton = [[TextButton alloc] initWithName:@"Back"];
		goBackButton.position = ccp(offset + 0.5 * goBackButton.width, offset + 0.5 * goBackButton.height);
		goBackButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Back));
		[self addChild:goBackButton z:10];
		[mButtons setObject:goBackButton forKey:@"Back"];
		[goBackButton release];
		
		TextButton* storeButton = [[TextButton alloc] initWithName:@"Store"];
		storeButton.position = ccp(winSize.width - offset - 0.5 * storeButton.width, offset + 0.5 * storeButton.height);
		storeButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Store));
		//storeButton.visible = (Game::Instance()->Distributable() == Distributable_AppStore) ? YES : NO;
		storeButton.visible = NO;
		[self addChild:storeButton z:10];
		[mButtons setObject:storeButton forKey:@"Store"];
		[storeButton release];
		
		// This is a placeholder button, needed only to make possible the navigation by controller over world buttons.
		TextButton* worldSelectButton = [[TextButton alloc] initWithName:@"Settings"];
		worldSelectButton.position = ccp(0.5 * winSize.width, 0.5 * winSize.height);
		worldSelectButton.visible = NO; // Not visible (== not touchable), but it can be focused by game controller.
		worldSelectButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_World));
		mPreferredFocusButton = worldSelectButton;
		[self addChild:worldSelectButton z:10];
		[mButtons setObject:worldSelectButton forKey:@"WorldSelect"];
		[worldSelectButton release];
		
		// --------------
		
		mDeltaItemPos = PNGMakePoint(300, 0);

		[self showWorlds];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: WorldSelectLayer");
	
	mLevelSelectionController = NULL;
	
	[mButtonKeys release];
	[mWorldButtons release];
	[mWorldButtonsHolder stopAllActions];
	[mWorldButtonsHolder release];
	
	[mLabel release];
	
	[mRenderTexture release];
	[mBackground release];
	[mTemplate release];
	
	[super dealloc];
}

-(void) onExit
{
	[super onExit];
	[self removeGestureRecognizer];
}

-(void) renderBackground
{
	ccColor4B bkgColors[] = {
		ccc4(138, 84, 94, 255),
		ccc4(88, 130, 143, 255),
		ccc4(127, 140, 105, 255),
		ccc4(252, 83, 4, 255),
		ccc4(8, 45, 143, 255),
	};
	
	// ---
	
	[mRenderTexture begin];
	
	ColorSprite* sprite = [[ColorSprite alloc] initWithFile:@"BackgroundLevels.png"];
	sprite.position = ccp(0.5 * mRenderTexture.contentSize.width, 0.5 * mRenderTexture.contentSize.height);
	sprite.scaleX = 2;
	sprite.scaleY = -2;
	sprite.color = ccc4FFromccc4B(bkgColors[4]);
	[sprite visit];
	[sprite release];
	
	[mRenderTexture end];
}

-(void) update:(ccTime)dt
{
	[self scaleWorldButtons];
}

-(void) addGestureRecognizer
{
	UIPanGestureRecognizer* panRecognizer;
	panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
	panRecognizer.minimumNumberOfTouches = 1;
	[[[CCDirector sharedDirector] view] addGestureRecognizer:panRecognizer];
	[panRecognizer release];
}

-(void) removeGestureRecognizer
{
	NSArray *grs = [[[CCDirector sharedDirector] view] gestureRecognizers];
	
	for (UIGestureRecognizer* gesture in grs)
	{
		if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
		{
			[[[CCDirector sharedDirector] view] removeGestureRecognizer:gesture];
		}
	}
}

-(void) selectButton:(int)index
{
	/*
	TextButton* button = [mWorldButtons objectAtIndex:index];
	[button stopAllActions];
	[button runAction:[CCTintTo actionWithDuration:0.25 red:255 green:0 blue:0]];
	 */
}

-(void) deselectButton:(int)index
{
	/*
	TextButton* button = [mWorldButtons objectAtIndex:index];
	[button stopAllActions];
	[button runAction:[CCTintTo actionWithDuration:0.25 red:255 green:255 blue:255]];
	 */
}

-(void) handlePanFrom:(UIPanGestureRecognizer*)recognizer
{
	if (!mGesturesEnabled)
	{
		// This cancels gesture recognizer if a user clicked on a button first.
		recognizer.enabled = NO;
		recognizer.enabled = YES;
		return;
	}
	
	if (recognizer.state == UIGestureRecognizerStateBegan ||
		recognizer.state == UIGestureRecognizerStateChanged)
	{
		CGPoint translation = [recognizer translationInView:recognizer.view];
		[recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];
	
		[mWorldButtonsHolder stopAllActions];
		mWorldButtonsHolder.position = ccpAdd(mWorldButtonsHolder.position, ccp(0.75 * translation.x, 0));
		
		int newItemIndex = (0.5 * mDeltaItemPos.x - mWorldButtonsHolder.position.x) / mDeltaItemPos.x;
		newItemIndex = Clamp(newItemIndex, 0, Game::Instance()->Data().NumWorlds() - 1);
		
		if (mItemIndex != newItemIndex)
		{
			[self deselectButton:mItemIndex];
			[self selectButton:newItemIndex];
			
			mCanSwipe = false;
			mItemIndex = newItemIndex;
			
			// Refactor this... probably should go through scene controller instead going directly to game singleton.
			Game::Instance()->SetWorldId(mItemIndex);
		}
		
		CCLOG(@"mItemIndex = %d", mItemIndex);
	}
	else if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		CCLOG(@"Pan gesture recognized.");
		CGPoint velocity = [recognizer velocityInView:recognizer.view];
		CCLOG(@"VEL: X: %f Y: %f", velocity.x, velocity.y);
		
		// Get the location of the touch in Cocos coordinates.
		//CGPoint touchLocation = [recognizer locationInView:recognizer.view];
		
		bool swiped = false;
		
		if (mCanSwipe && fabs(velocity.x) > 500)
		{
			swiped = true;
			
			int newItemIndex = (velocity.x < 0) ? mItemIndex + 1 : mItemIndex - 1;
			newItemIndex = Clamp(newItemIndex, 0, Game::Instance()->Data().NumWorlds() - 1);
			
			[self deselectButton:mItemIndex];
			[self selectButton:newItemIndex];
			
			mItemIndex = newItemIndex;
		}
		
		CCLOG(@"mItemIndex = %d", mItemIndex);
		
		CGFloat newX = -mItemIndex * mDeltaItemPos.x;
		
		CGFloat duration = swiped ? 1 : 1.5;
		
		[mWorldButtonsHolder stopAllActions];
		CCActionInterval* myAction = [CCMoveTo actionWithDuration:duration position:ccp(newX, 0)];
		[mWorldButtonsHolder runAction:[CCEaseExponentialOut actionWithAction:myAction]];
		
		mCanSwipe = true;
		
		// Refactor this... probably should go through scene controller instead going directly to game singleton.
		Game::Instance()->SetWorldId(mItemIndex);
	}
}

-(void) showUI
{
	mGesturesEnabled = true;
	
	mLabel.visible = YES;
	
	TextButton* goBackButton = [mButtons objectForKey:@"Back"];
	goBackButton.visible = YES;
	
	TextButton* storeButton = [mButtons objectForKey:@"Store"];
	//storeButton.visible = (Game::Instance()->Distributable() == Distributable_AppStore) ? YES : NO;
	storeButton.visible = NO;
	
	[self showWorlds];
}

-(void) hideUI
{
	mGesturesEnabled = false;
	
	mLabel.visible = NO;
	
	TextButton* goBackButton = [mButtons objectForKey:@"Back"];
	goBackButton.visible = NO;
	
	TextButton* storeButton = [mButtons objectForKey:@"Store"];
	storeButton.visible = NO;
}

-(void) showWorlds
{
	[self removeFocus];
	
	// Remove all previously shown world buttons.
	[mButtons removeObjectsForKeys:mButtonKeys];
	[mButtonKeys removeAllObjects];
	
	[mWorldButtons removeAllObjects];
	[mWorldButtonsHolder removeAllChildren];
	
	// ---
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	CGPoint prevWorldPos = ccpSub(ccp(0.5 * winSize.width, 0.5 * winSize.height), mDeltaItemPos);
	
	for (int worldId = 0; worldId < Game::Instance()->Data().NumWorlds(); ++worldId)
	{
		WorldData& currWorld = Game::Instance()->Data().World(worldId);
		
		CCLOG(@"WORLD %d - NUMLEVELS: %d", worldId, currWorld.NumLevels());
		
		CCNode* btnContainer = [[CCNode alloc] init];
		btnContainer.position = ccpAdd(prevWorldPos, mDeltaItemPos);
		prevWorldPos = btnContainer.position;
		CGPoint btnContainerWorldPos = [mWorldButtonsHolder convertToWorldSpace:btnContainer.position];
		btnContainer.scale = [self getWorldButtonScaleForX:btnContainerWorldPos.x];
		[mWorldButtonsHolder addChild:btnContainer z:5 tag:worldId];
		
		NSString* btnName = [[NSString alloc] initWithFormat:@"World%d", worldId];
		TextButton* worldButton = [[TextButton alloc] initWithName:btnName];
		worldButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_World));
		worldButton.userInt = worldId;
		[btnContainer addChild:worldButton z:5];
		[mWorldButtons addObject:worldButton];
		
		// Only unlocked worlds can be clicked.
		if (!currWorld.Locked())
		{
			[mButtonKeys addObject:btnName];
			[mButtons setObject:worldButton forKey:btnName];
			
			CCSprite* star = [[CCSprite alloc] initWithSpriteFrameName:@"Star0"];
			star.position = PNGMakePoint(-25, -123);
			star.scale = 0.6;
			[btnContainer addChild:star z:15];
			[star release];
			
			NSString* text = [[NSString alloc] initWithFormat:@"%d/%d", currWorld.NumStarsCollected(), currWorld.MaxNumStars()];
			
			TextLabel* label = [[TextLabel alloc] initWithStringValue:text
																width:PNGMakeFloat(130)
															alignment:kCCTextAlignmentCenter
															smallFont:true];
			
			label.position = ccpAdd(star.position, PNGMakePoint(15, -1));
			label.anchorPoint = ccp(0, 0.5);
			label.scale = 1;
			[btnContainer addChild:label z:15];
			
			[label release];
			[text release];
		}
		else
		{
			// Add a lock on top of each locked world button.
			
			CCSprite* lock = [[CCSprite alloc] initWithFile:@"WorldLock.png"];
			[btnContainer addChild:lock z:10];
			[lock release];
			
			// Add number of stars necessary to unlock the world.
			
			int numStarsRequired = currWorld.NumStarsToUnlock() - Game::Instance()->Data().NumStarsCollected();
			if (numStarsRequired < 0) numStarsRequired = 0;
			
			if (numStarsRequired > 0)
			{
				CCSprite* cover = [[CCSprite alloc] initWithFile:@"WorldLockCover.png"];
				cover.position = PNGMakePoint(2, -20);
				[btnContainer addChild:cover z:11];
				[cover release];
				
				float starHorizontalOffset = -15;
				if (numStarsRequired < 10) starHorizontalOffset = -5;
				else if (numStarsRequired < 100) starHorizontalOffset = -10;
				
				CCSprite* star = [[CCSprite alloc] initWithSpriteFrameName:@"Star0"];
				star.position = PNGMakePoint(starHorizontalOffset, -20);
				star.scale = 0.6;
				[btnContainer addChild:star z:15];
				[star release];
				
				NSString* numStarsText = [[NSString alloc] initWithFormat:@"%d", numStarsRequired];
				
				TextLabel* numStarsLabel = [[TextLabel alloc] initWithStringValue:numStarsText
																			width:PNGMakeFloat(130)
																		alignment:kCCTextAlignmentCenter
																		smallFont:true];
				
				numStarsLabel.position = ccpAdd(star.position, PNGMakePoint(10, -1));
				numStarsLabel.anchorPoint = ccp(0, 0.5);
				numStarsLabel.scale = 1;
				[btnContainer addChild:numStarsLabel z:15];
				
				[numStarsLabel release];
				[numStarsText release];
			}
			
			// Add a label below each locked world button.
			
			if (worldId > 0)
			{
				TextLabel* label = [[TextLabel alloc] initWithStringValue:@""
																	width:PNGMakeFloat(200)
																alignment:kCCTextAlignmentCenter
																smallFont:true];
				label.position = PNGMakePoint(0, -125);
				label.scale = 1;
				[btnContainer addChild:label z:15];
				
				const WorldData& prevWorld = Game::Instance()->Data().World(worldId - 1);
				
				if (!prevWorld.CompletedAllLevels())
				{
					const std::string& strCompleteToUnlock = Game::Instance()->Data().LocalizedText("CompleteToUnlock");
					NSString* completeToUnlockText = [[NSString alloc] initWithUTF8String:strCompleteToUnlock.c_str()];
					NSString* completeToUnlockFormattedText = [[NSString alloc] initWithFormat:completeToUnlockText, prevWorld.Name().c_str()];
					
					label.string = completeToUnlockFormattedText;
					
					[completeToUnlockFormattedText release];
					[completeToUnlockText release];
				}
				else if (numStarsRequired > 0)
				{
					const std::string& strEarnStarsToUnlock = Game::Instance()->Data().LocalizedText("EarnStarsToUnlock");
					NSString* earnStarsToUnlockText = [[NSString alloc] initWithUTF8String:strEarnStarsToUnlock.c_str()];
					NSString* earnStarsToUnlockFormattedText = [[NSString alloc] initWithFormat:earnStarsToUnlockText, prevWorld.Name().c_str()];
					
					label.string = earnStarsToUnlockFormattedText;
					
					[earnStarsToUnlockFormattedText release];
					[earnStarsToUnlockText release];
				}
				
				[label release];
			}
			
			// Make the world button transparent and monochromatic.
			
			worldButton.opacity = 150;
			worldButton.grayscale = true;
		}
		
		[btnName release];
		[worldButton release];
		[btnContainer release];
	}
}

-(void) centerWorld:(int)worldId animate:(bool)animate
{
	mItemIndex = Clamp(worldId, 0, Game::Instance()->Data().NumWorlds() - 1);
	
	CGFloat newX = -mItemIndex * mDeltaItemPos.x;
	
	if (animate)
	{
		[mWorldButtonsHolder stopAllActions];
		CCActionInterval* myAction = [CCMoveTo actionWithDuration:0.35 position:ccp(newX, 0)];
		[mWorldButtonsHolder runAction:[CCEaseExponentialOut actionWithAction:myAction]];
	}
	else
	{
		mWorldButtonsHolder.position = ccp(newX, 0);
	}
	
	for (int index = 0; index < mWorldButtons.count; ++index)
	{
		TextButton* button = [mWorldButtons objectAtIndex:index];
		
		WorldData& world = Game::Instance()->Data().World(index);
		
		if (index == mItemIndex && !world.Locked() && [mButtons objectForKey:@"WorldSelect"] == mFocusedButton)
		{
			button.focused = true;
		}
		else
		{
			button.focused = false;
		}
	}
	
	[self scaleWorldButtons];
	
	// Refactor this... probably should go through scene controller instead going directly to game singleton.
	Game::Instance()->SetWorldId(mItemIndex);
}

-(CGFloat) getWorldButtonScaleForX:(CGFloat)x
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	CGFloat scaleLow = 0.8;
	CGFloat scaleHigh = 1;
	CGFloat treshold = PNGMakeFloat(125);
	
	CGFloat scale = fabs(x - 0.5 * winSize.width) * (scaleLow - scaleHigh) / treshold + scaleHigh;
	return Clamp(scale, scaleLow, scaleHigh);
}

-(void) scaleWorldButtons
{
	for (int index = 0; index < mWorldButtons.count; ++index)
	{
		CCNode* btnContainer = [mWorldButtonsHolder getChildByTag:index];
		
		if (btnContainer != nil)
		{
			CGPoint btnContainerWorldPos = [mWorldButtonsHolder convertToWorldSpace:btnContainer.position];
			
			btnContainer.scale = [self getWorldButtonScaleForX:btnContainerWorldPos.x];
		}
	}
}

// ---------------------------------------------------------------------------

-(bool) canButtonBeFocused:(TextButton*)button
{
	if (button)
	{
		if (button.visible)
		{
			// All visible button except the ones that represent worlds can be focused.
			if (![mWorldButtons containsObject:button]) return true;
		}
		else
		{
			// This is the only invisible button that can be focused.
			if ([mButtons objectForKey:@"WorldSelect"] == button) return true;
		}
	}
	
	return false;
}

-(void) setFocusToButton:(TextButton*)button
{
	[super setFocusToButton:button];
	
	if ([mButtons objectForKey:@"WorldSelect"] == mFocusedButton)
	{
		[self centerWorld:mItemIndex animate:true];
	}
	else
	{
		[self removeFocusFromWorldButtons];
	}
}

-(void) applyMoveFocus
{
	if (!mCanTouch) return;
	
	if (GameControllerManager::Instance()->ControllerConnected())
	{
		if (!mFocusedButton)
		{
			[self setFocusToFirstPossibleButton];
		}
		else
		{
			if (![self isFocusDirectionSpecified]) return;
			
			// Special case: world selection.
			if ((mFocusDirection[FocusDir_Left] || mFocusDirection[FocusDir_Right]) &&
				[mButtons objectForKey:@"WorldSelect"] == mFocusedButton)
			{
				if (mFocusDirection[FocusDir_Left])
				{
					[self centerWorld:(mItemIndex - 1) animate:true];
				}
				else if (mFocusDirection[FocusDir_Right])
				{
					[self centerWorld:(mItemIndex + 1) animate:true];
				}
			}
			else
			{
				[self setFocusToClosestButtonInFocusDirection];
			}
		}
	}
	else
	{
		[self removeFocus];
		[self removeFocusFromWorldButtons];
	}
	
	[self resetFocusDirectionValues];
}

-(void) clickFocusedButton
{
	if (!mCanTouch) return;
	
	if (mFocusedButton)
	{
		ButtonType buttonId = static_cast<ButtonType>(reinterpret_cast<int>(mFocusedButton.userData));
		void* userData = reinterpret_cast<void*>(mFocusedButton.userInt);
		
		// If the invisible button was focused and clicked, it means a user has selected a world.
		if ([mButtons objectForKey:@"WorldSelect"] == mFocusedButton)
		{
			WorldData& selectedWorld = Game::Instance()->Data().World(mItemIndex);
				
			if (selectedWorld.Locked()) return;
			
			userData = reinterpret_cast<void*>(mItemIndex);
		}
		
		if (mSceneController) mSceneController->OnButtonClicked(buttonId, userData);
	}
}

-(void) removeFocusFromWorldButtons
{
	for (int index = 0; index < mWorldButtons.count; ++index)
	{
		TextButton* button = [mWorldButtons objectAtIndex:index];
		button.focused = false;
	}
}

// ---------------------------------------------------------------------------

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	TextButton* button = [self processButtonForTouchBegan:touch];
	
	if (button != nil && [mWorldButtons containsObject:button] == NO)
	{
		mGesturesEnabled = false;
	}
	
	return YES;
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	TextButton* button = [self processButtonForTouchEnded:touch];
	
	if (button != nil && [mWorldButtons containsObject:button] == NO)
	{
		mGesturesEnabled = true;
	}
}

@end
