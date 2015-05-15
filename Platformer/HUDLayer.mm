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

#import "HUDLayer.h"
#import "Game.h"
#import "GameControllerManager.h"
#import "LevelController.h"

bool ButtonType1ContainsPoint(CCSprite* sprite, CGPoint pos)
{
	return fabs(pos.x - sprite.position.x) <= 0.5 * Game::Instance()->ControlButtonWidth();
}

bool ButtonType2ContainsPoint(CCSprite* sprite, CGPoint pos)
{
	return fabs(pos.x - sprite.position.x) <= 0.5 * Game::Instance()->ControlButtonWidth() &&
		fabs(pos.y - sprite.position.y) <= 0.5 * Game::Instance()->ControlButtonWidth();
}

@implementation HUDLayer

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(id) init
{
	return nil;
}

-(id) initWithLevelController:(LevelController*)controller
{
	self = [super init];
	if (self)
	{
		self.touchEnabled = NO;
		self.visible = NO;
		
		mSceneController = controller;
		
		mScore = -1;
		mLives = -1;
		mNumKeys = -1;
		mMinutes = -1;
		mSeconds = -1;
		
		mIconsScale = 0.75;
		
		// --------------
		
		mPauseTouch = nil;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		mHearts = [[NSMutableArray alloc] initWithCapacity:5];
		for (int i = 0; i < 3; ++i)
		{
			CCSprite* heart = [[CCSprite alloc] initWithFile:@"Heart.png"];
			heart.position = ccp(PNGMakeFloat(5 * (1 + i)) + mIconsScale * i * heart.contentSize.width, winSize.height - PNGMakeFloat(5));
			heart.anchorPoint = ccp(0, 1);
			heart.scale = mIconsScale;
			[self addChild:heart];
			[mHearts addObject:heart];
			[heart release];
		}
		
		// --------------
		
		mScoreIcon = [[CCSprite alloc] initWithFile:@"Coin.png"];
		mScoreIcon.position = ccp(PNGMakeFloat(200 - 5), winSize.height - PNGMakeFloat(5));
		mScoreIcon.scale = mIconsScale;
		mScoreIcon.anchorPoint = ccp(0, 1);
		[self addChild:mScoreIcon];
		
		// --------------
		
		mTimeIcon = [[CCSprite alloc] initWithFile:@"Clock.png"];
		mTimeIcon.position = ccp(PNGMakeFloat(350 - 5) + mIconsScale * 0.5 * mTimeIcon.contentSize.width,
								 winSize.height - PNGMakeFloat(5) - mIconsScale * 0.5 * mTimeIcon.contentSize.height);
		mTimeIcon.scale = mIconsScale;
		mTimeIcon.anchorPoint = ccp(0.5, 0.5);
		[self addChild:mTimeIcon];
		
		// --------------
		
		mKeys = [[NSMutableArray alloc] initWithCapacity:5];
		for (int i = 0; i < 5; ++i)
		{
			CCSprite* key = [[CCSprite alloc] initWithSpriteFrameName:@"Key0"];
			key.position = ccp(PNGMakeFloat(5) + 0.5 * key.contentSize.width,
							   winSize.height - 0.5 * key.contentSize.height - PNGMakeFloat(35) - PNGMakeFloat(15) * i);
			key.anchorPoint = ccp(0.5, 0.5);
			key.visible = NO;
			[self addChild:key];
			[mKeys addObject:key];
			[key release];
		}
		
		// --------------
		
		mBatch = [[CCSpriteBatchNode alloc] initWithFile:@"UIButtons.png" capacity:15];
		[self addChild:mBatch z:10];
		
		mControlButtons = [[NSMutableDictionary alloc] initWithCapacity:10];
		mControlTouches = [[NSMutableDictionary alloc] initWithCapacity:10];

		CGFloat offset = PNGMakeFloat(5);
		
		if (mSceneController->LvlType() == Level_Normal)
		{
			mLeftButton = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(@"LeftNormal")];
			mLeftButton.position = Game::Instance()->ControlPosition("Left");
			[mBatch addChild:mLeftButton];
			[mControlButtons setObject:mLeftButton forKey:@"Left"];
			mControlTypes["Left"] = Btn_Left;
			
			mRightButton = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(@"RightNormal")];
			mRightButton.position = Game::Instance()->ControlPosition("Right");
			[mBatch addChild:mRightButton];
			[mControlButtons setObject:mRightButton forKey:@"Right"];
			mControlTypes["Right"] = Btn_Right;
		}
		else
		{
			mLeftButton = mRightButton = nil;
		}
		
		CCSprite* fireButton = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(@"FireNormal")];
		fireButton.position = Game::Instance()->ControlPosition("Fire");
		[mBatch addChild:fireButton];
		[mControlButtons setObject:fireButton forKey:@"Fire"];
		mControlTypes["Fire"] = Btn_B;
		[fireButton release];
		
		CCSprite* jumpButton = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(@"JumpNormal")];
		jumpButton.position = Game::Instance()->ControlPosition("Jump");
		[mBatch addChild:jumpButton];
		[mControlButtons setObject:jumpButton forKey:@"Jump"];
		mControlTypes["Jump"] = Btn_A;
		[jumpButton release];
		
		mPauseButton = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(@"PauseNormal")];
		mPauseButton.position = ccp(winSize.width - offset - 0.5 * mPauseButton.contentSize.width,
									winSize.height - offset - 0.5 * mPauseButton.contentSize.height);
		mPauseButton.opacity = 127;
		[mBatch addChild:mPauseButton];
		
		// --------------
		
		CGFloat labelOffset = PNGMakeFloat(9);
		
		mScoreLabel = [[CCLabelBMFont alloc] initWithString:@"Coins: -"
													fntFile:@"GroboldSmall.fnt"
													  width:PNGMakeFloat(150)
												  alignment:kCCTextAlignmentLeft];
		
		mScoreLabel.position = ccp(mScoreIcon.position.x + PNGMakeFloat(30), winSize.height - labelOffset);
		mScoreLabel.anchorPoint = ccp(0, 1);
		[self addChild:mScoreLabel];
		

		
		mTimeLabel = [[CCLabelBMFont alloc] initWithString:@"Time: -"
												   fntFile:@"GroboldSmall.fnt"
													 width:PNGMakeFloat(100)
												 alignment:kCCTextAlignmentLeft];
		
		mTimeLabel.position = ccp(mTimeIcon.position.x + PNGMakeFloat(30) - mIconsScale * 0.5 * mTimeIcon.contentSize.width, winSize.height - labelOffset);
		mTimeLabel.anchorPoint = ccp(0, 1);
		[self addChild:mTimeLabel];
	}
	return self;
}

-(void) dealloc
{
	mSceneController = NULL;
	
	[mKeys release];
	[mHearts release];
	[mScoreIcon release];
	[mTimeIcon release];
	
	[mTimeLabel release];
	[mScoreLabel release];
	
	[mControlTouches release];
	[mControlButtons release];
	
	[mLeftButton release];
	[mRightButton release];
	[mPauseButton release];
	
	[mBatch release];
	
	[super dealloc];
}

-(void) onExit
{
	[super onExit];
	[self removeGestureRecognizer];
}

-(void) addGestureRecognizer
{
	UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
	panRecognizer.minimumNumberOfTouches = 1;
	panRecognizer.maximumNumberOfTouches = 1;
	panRecognizer.delegate = self;
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

-(BOOL) gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	for (NSString* key in mControlButtons)
	{
		CCSprite* button = [mControlButtons objectForKey:key];
		
		if (button && button.visible && [self button:button containsPoint:location])
		{
			return NO;
		}
	}
	
	if ([self mPauseButtonContainsPoint:location])
		return NO;
	
	return YES;
}

-(void) handlePanFrom:(UIPanGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan ||
		recognizer.state == UIGestureRecognizerStateChanged)
	{
		CGPoint translation = [recognizer translationInView:recognizer.view];
		[recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view];
		
		ButtonType buttonId = Btn_Invalid;
		
		float epsilon = 0;
		
		if (recognizer.state == UIGestureRecognizerStateChanged)
			epsilon = 4;
		
		if (translation.x > epsilon)
		{
			buttonId = Btn_Right;
		}
		else if (translation.x < -epsilon)
		{
			buttonId = Btn_Left;
		}
		
		if (buttonId != Btn_Invalid)
		{
			ButtonType releasedButtonId = (buttonId == Btn_Left) ? Btn_Right : Btn_Left;
			
			if (mSceneController)
			{
				Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_ButtonReleased, reinterpret_cast<void*>(releasedButtonId));
				mSceneController->HandleMessage(telegram);
			}
			
			if (mSceneController)
			{
				Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_ButtonPressed, reinterpret_cast<void*>(buttonId));
				mSceneController->HandleMessage(telegram);
			}
		}
	}
	else if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		if (mSceneController)
		{
			// Stop moving.
			mSceneController->HandleMessage(Telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_ButtonReleased, reinterpret_cast<void*>(Btn_Left)));
			mSceneController->HandleMessage(Telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_ButtonReleased, reinterpret_cast<void*>(Btn_Right)));
		}
	}
}

-(void) refreshControls
{
	GLubyte opacity = GameControllerManager::Instance()->ControllerConnected() ? 0 : 127;
	
	mLeftButton.opacity = opacity;
	mRightButton.opacity = opacity;
	
	CCSprite* fireButton = [mControlButtons objectForKey:@"Fire"];
	fireButton.opacity = opacity;
	
	CCSprite* jumpButton = [mControlButtons objectForKey:@"Jump"];
	jumpButton.opacity = opacity;
}

-(void) preDisplay
{
	if (mSceneController->LvlType() == Level_Normal)
	{
		if (Game::Instance()->UseGestures())
			[self addGestureRecognizer];
		
		mLeftButton.position = Game::Instance()->ControlPosition("Left");
		mLeftButton.visible = Game::Instance()->UseGestures() ? NO : YES;
		SetSpriteFrame(mLeftButton, Game::Instance()->Data().ButtonFrameName(@"LeftNormal"));
		[mControlTouches removeObjectForKey:@"Left"];
		
		mRightButton.position = Game::Instance()->ControlPosition("Right");
		mRightButton.visible = mLeftButton.visible;
		SetSpriteFrame(mRightButton, Game::Instance()->Data().ButtonFrameName(@"RightNormal"));
		[mControlTouches removeObjectForKey:@"Right"];
	}
	
	CCSprite* fireButton = [mControlButtons objectForKey:@"Fire"];
	fireButton.position = Game::Instance()->ControlPosition("Fire");
	SetSpriteFrame(fireButton, Game::Instance()->Data().ButtonFrameName(@"FireNormal"));
	[mControlTouches removeObjectForKey:@"Fire"];
	
	CCSprite* jumpButton = [mControlButtons objectForKey:@"Jump"];
	jumpButton.position = Game::Instance()->ControlPosition("Jump");
	SetSpriteFrame(jumpButton, Game::Instance()->Data().ButtonFrameName(@"JumpNormal"));
	[mControlTouches removeObjectForKey:@"Jump"];
	
	[self refreshControls];
}

-(void) preHide
{
	if (Game::Instance()->UseGestures())
		[self removeGestureRecognizer];
}

-(void) setScoreLabel:(int)score outOf:(int)maxScore
{
	if (score != mScore)
	{
		mScore = score;
		
		NSString* text = [[NSString alloc] initWithFormat:@"%d/%d", score, maxScore];
		[mScoreLabel setString:text];
		[text release];
	}
}

-(void) setLivesLabel:(int)lives
{
	if (lives != mLives)
	{
		mLives = lives;
		
		for (int index = 0; index < 3; ++index)
		{
			CCSprite* heart = [mHearts objectAtIndex:index];
			//heart.visible = (index < mLives) ? YES : NO;
			heart.opacity = (index < mLives) ? 255 : 64;
		}
	}
}

-(void) setKeysLabel:(int)keys
{
	if (keys != mNumKeys)
	{
		mNumKeys = keys;
		
		for (int index = 0; index < mKeys.count; ++index)
		{
			CCSprite* key = [mKeys objectAtIndex:index];
			
			bool shouldBeVisible = index < mNumKeys;
			
			if (!key.visible && shouldBeVisible)
			{
				key.visible = YES;
				key.scale = 0;
				
				[key runAction:
				 [CCEaseElasticOut actionWithAction:
				  [CCScaleTo actionWithDuration:0.5 scale:1]]
				];
			}
			else if (key.visible && !shouldBeVisible)
			{
				[key stopAllActions];
				key.visible = NO;
			}
		}
	}
}

-(void) setTimeLabel:(ccTime)time
{
	int minutes = (int)time / 60;
	int seconds = (int)time % 60;
	
	if (minutes != mMinutes || seconds != mSeconds)
	{
		mMinutes = minutes;
		mSeconds = seconds;
		
		NSString* text = [[NSString alloc] initWithFormat:@"%d:%02d", minutes, seconds];
		[mTimeLabel setString:text];
		[text release];
		
		if (mMinutes == 0 && mSeconds == 0)
		{
			mTimeIcon.scale = mIconsScale + 0.5;
			[mTimeIcon runAction:
			 [CCEaseElasticOut actionWithAction:
			  [CCScaleTo actionWithDuration:1 scale:mIconsScale]]
			];
		}
	}
}

-(bool) button:(CCSprite*)button containsPoint:(CGPoint)pos
{
	if (button == mLeftButton || button == mRightButton)
		return ButtonType1ContainsPoint(button, pos);
	else return ButtonType2ContainsPoint(button, pos);
}

-(bool) mPauseButtonContainsPoint:(CGPoint)pos
{
	return (pos.x - mPauseButton.position.x > -PNGMakeFloat(50)) &&
			(pos.y - mPauseButton.position.y > -PNGMakeFloat(50));
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	ButtonType buttonId = Btn_Invalid;
	
	if ([self mPauseButtonContainsPoint:location])
	{
		//CCLOG(@"Pause button pressed");
		SetSpriteFrame(mPauseButton, Game::Instance()->Data().ButtonFrameName(@"PauseSelected"));
		mPauseTouch = touch;
		buttonId = Btn_Pause;
	}
	else
	{
		// Determine which control button is the closest to where the touch occured.
		CCSprite* closestButton = nil;
		NSString* closestButtonKey = nil;
		CGFloat minDistance = 1000000000;
		
		for (NSString* key in mControlButtons)
		{
			CCSprite* button = [mControlButtons objectForKey:key];
			
			if (button && button.visible && [self button:button containsPoint:location])
			{
				CGFloat distance = ccpDistanceSQ(button.position, location);
				
				if (distance < minDistance)
				{
					closestButton = button;
					
					[closestButtonKey release];
					closestButtonKey = [key retain];
					
					minDistance = distance;
				}
			}
		}
		
		if (closestButton)
		{
			if (closestButton == mLeftButton && [mControlTouches objectForKey:@"Right"])
			{
				SetSpriteFrame(mRightButton, Game::Instance()->Data().ButtonFrameName(@"RightNormal"));
				[mControlTouches removeObjectForKey:@"Right"];
				if (mSceneController) mSceneController->OnButtonReleased(Btn_Right);
			}
			else if (closestButton == mRightButton && [mControlTouches objectForKey:@"Left"])
			{
				SetSpriteFrame(mLeftButton, Game::Instance()->Data().ButtonFrameName(@"LeftNormal"));
				[mControlTouches removeObjectForKey:@"Left"];
				if (mSceneController) mSceneController->OnButtonReleased(Btn_Left);
			}
			
			NSString* name = [[NSString alloc] initWithFormat:@"%@Selected", closestButtonKey];
			SetSpriteFrame(closestButton, Game::Instance()->Data().ButtonFrameName(name));
			[name release];
			
			[mControlTouches setObject:touch forKey:closestButtonKey];
			
			buttonId = mControlTypes[[closestButtonKey UTF8String]];
			
			[closestButtonKey release];
		}
	}
	
	if (buttonId != Btn_Invalid)
	{
		if (mSceneController) mSceneController->OnButtonPressed(buttonId);
	}
	
	return YES;
}

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	ButtonType buttonId = Btn_Invalid;
	
	if (touch == mPauseTouch)
	{
		if ([self mPauseButtonContainsPoint:location])
			SetSpriteFrame(mPauseButton, Game::Instance()->Data().ButtonFrameName(@"PauseSelected"));
		else SetSpriteFrame(mPauseButton, Game::Instance()->Data().ButtonFrameName(@"PauseNormal"));
	}
	else
	{
		if (touch == [mControlTouches objectForKey:@"Left"] && [self button:mRightButton containsPoint:location])
		{
			//CCLOG(@"Left button released");
			SetSpriteFrame(mLeftButton, Game::Instance()->Data().ButtonFrameName(@"LeftNormal"));
			[mControlTouches removeObjectForKey:@"Left"];
			
			//CCLOG(@"Right button pressed");
			SetSpriteFrame(mRightButton, Game::Instance()->Data().ButtonFrameName(@"RightSelected"));
			[mControlTouches setObject:touch forKey:@"Right"];
			buttonId = Btn_Right;
		}
		else if (touch == [mControlTouches objectForKey:@"Right"] && [self button:mLeftButton containsPoint:location])
		{
			//CCLOG(@"Right button released");
			SetSpriteFrame(mRightButton, Game::Instance()->Data().ButtonFrameName(@"RightNormal"));
			[mControlTouches removeObjectForKey:@"Right"];
			
			//CCLOG(@"Left button pressed");
			SetSpriteFrame(mLeftButton, Game::Instance()->Data().ButtonFrameName(@"LeftSelected"));
			[mControlTouches setObject:touch forKey:@"Left"];
			buttonId = Btn_Left;
		}
	}
	
	if (buttonId != Btn_Invalid)
	{
		ButtonType releasedButtonId = (buttonId == Btn_Left) ? Btn_Right : Btn_Left;
		
		if (mSceneController)
		{
			mSceneController->OnButtonReleased(releasedButtonId);
			mSceneController->OnButtonPressed(buttonId);
		}
	}
}

-(void) processButtonForTouchEnded:(UITouch*)touch cancelled:(bool)cancelled
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	ButtonType buttonId = Btn_Invalid;
	
	bool buttonClicked = false;
	
	if (touch == mPauseTouch)
	{
		//CCLOG(@"Pause button released");
		SetSpriteFrame(mPauseButton, Game::Instance()->Data().ButtonFrameName(@"PauseNormal"));
		mPauseTouch = nil;
		buttonId = Btn_Pause;
		buttonClicked = [self mPauseButtonContainsPoint:location];
	}
	else
	{
		for (NSString* key in mControlTouches)
		{
			UITouch* controlTouch = [mControlTouches objectForKey:key];
			
			if (touch == controlTouch)
			{
				CCSprite* button = [mControlButtons objectForKey:key];
				
				NSString* name = [[NSString alloc] initWithFormat:@"%@Normal", key];
				SetSpriteFrame(button, Game::Instance()->Data().ButtonFrameName(name));
				[name release];
				
				[mControlTouches removeObjectForKey:key];
				
				buttonId = mControlTypes[[key UTF8String]];
				buttonClicked = [self button:button containsPoint:location];
				break;
			}
		}
	}
	
	if (buttonId != Btn_Invalid)
	{
		if (mSceneController) mSceneController->OnButtonReleased(buttonId);
		
		if (mSceneController && buttonClicked && !cancelled) mSceneController->OnButtonClicked(buttonId);
	}
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	[self processButtonForTouchEnded:touch cancelled:false];
}

-(void) ccTouchCancelled:(UITouch*)touch withEvent:(UIEvent*)event
{
	[self processButtonForTouchEnded:touch cancelled:true];
}

@end
