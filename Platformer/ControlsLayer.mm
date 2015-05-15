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

#import "ControlsLayer.h"
#import "Game.h"
#import "SceneController.h"
#import "TextButton.h"
#import "TextLabel.h"


@implementation ControlsLayer

-(id) initWithSceneController:(SceneController*)controller
{
	return [self initWithSceneController:controller color:ccc4(16, 16, 16, 230)];
}

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	self = [super initWithSceneController:controller color:color];
	if (self)
	{
		self.visible = NO;
		self.touchEnabled = NO;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		CGFloat labelOffset = PNGMakeFloat(15);
		
		mLabel = [[TextLabel alloc] initWithStringValue:@""
												  width:PNGMakeFloat(400)
											  alignment:kCCTextAlignmentCenter];
		
		mLabel.position = ccp(0.5 * winSize.width, winSize.height - labelOffset);
		mLabel.anchorPoint = ccp(0.5, 1);
		[mContainer addChild:mLabel];
		
		mMessageLabel = [[TextLabel alloc] initWithStringValue:@""
														 width:PNGMakeFloat(320)
													 alignment:kCCTextAlignmentCenter];
		
		mMessageLabel.position = ccp(0.5 * winSize.width, 0.5 * winSize.height);
		mMessageLabel.anchorPoint = ccp(0.5, 1);
		mMessageLabel.scale = 1;
		[mContainer addChild:mMessageLabel];
		
		mMessageLabel2 = [[TextLabel alloc] initWithStringValue:@""
														  width:PNGMakeFloat(320)
													  alignment:kCCTextAlignmentCenter];
		
		mMessageLabel2.position = ccpAdd(mMessageLabel.position, PNGMakePoint(0, -40));
		mMessageLabel2.anchorPoint = ccp(0.5, 1);
		mMessageLabel2.scale = 1;
		[mContainer addChild:mMessageLabel2];
		
		// --------------
		
		mControlButtons = [[NSMutableDictionary alloc] initWithCapacity:10];
		mControlTouches = [[NSMutableDictionary alloc] initWithCapacity:10];
		
		CGFloat offset = PNGMakeFloat(5);
		GLubyte opacity = 127;
		
		TextButton* goBackButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		goBackButton.position = ccp(0.5 * winSize.width - 3 * offset - goBackButton.width, 0.5 * winSize.height + PNGMakeFloat(64));
		goBackButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Apply));
		mPreferredFocusButton = goBackButton;
		[mContainer addChild:goBackButton z:10];
		[mButtons setObject:goBackButton forKey:@"Back"];
		[goBackButton release];
		
		TextButton* resetButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		resetButton.position = ccp(0.5 * winSize.width, goBackButton.position.y);
		resetButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Reset));
		[mContainer addChild:resetButton z:10];
		[mButtons setObject:resetButton forKey:@"Reset"];
		[resetButton release];
		
		TextButton* useGesturesButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		useGesturesButton.position = ccp(0.5 * winSize.width + 3 * offset + useGesturesButton.width, goBackButton.position.y);
		useGesturesButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_UseGestures));
		[mContainer addChild:useGesturesButton z:10];
		[mButtons setObject:useGesturesButton forKey:@"UseGestures"];
		[useGesturesButton release];
		
		TextButton* useArrowsButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		useArrowsButton.position = useGesturesButton.position;
		useArrowsButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_UseGestures));
		[mContainer addChild:useArrowsButton z:10];
		[mButtons setObject:useArrowsButton forKey:@"UseArrows"];
		[useArrowsButton release];
		
		// Controls
		
		CCSprite* leftButton = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(@"LeftNormal")];
		leftButton.position = Game::Instance()->ControlPosition("Left");
		leftButton.opacity = opacity;
		[mContainer addChild:leftButton z:8];
		[mControlButtons setObject:leftButton forKey:@"Left"];
		[leftButton release];
		
		CCSprite* rightButton = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(@"RightNormal")];
		rightButton.position = Game::Instance()->ControlPosition("Right");
		rightButton.opacity = opacity;
		[mContainer addChild:rightButton z:8];
		[mControlButtons setObject:rightButton forKey:@"Right"];
		[rightButton release];
		
		CCSprite* fireButton = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(@"FireNormal")];
		fireButton.position = Game::Instance()->ControlPosition("Fire");
		fireButton.opacity = opacity;
		[mContainer addChild:fireButton z:8];
		[mControlButtons setObject:fireButton forKey:@"Fire"];
		[fireButton release];
		
		CCSprite* jumpButton = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(@"JumpNormal")];
		jumpButton.position = Game::Instance()->ControlPosition("Jump");
		jumpButton.opacity = opacity;
		[mContainer addChild:jumpButton z:8];
		[mControlButtons setObject:jumpButton forKey:@"Jump"];
		[jumpButton release];
		
		// --------------
		
		[self preDisplay];
	}
	return self;
}

-(void) dealloc
{
	[mLabel release];
	[mMessageLabel release];
	[mMessageLabel2 release];
	
	[mControlTouches release];
	[mControlButtons release];
	
	[super dealloc];
}

-(void) preDisplay
{
	// Buttons
	
	TextButton* goBackButton = [mButtons objectForKey:@"Back"];
	[goBackButton refreshWithlocalizedTextName:"Save"];
	
	TextButton* resetButton = [mButtons objectForKey:@"Reset"];
	[resetButton refreshWithlocalizedTextName:"Reset"];
	
	TextButton* useGesturesButton = [mButtons objectForKey:@"UseGestures"];
	[useGesturesButton refreshWithlocalizedTextName:"UseGestures"];
	useGesturesButton.visible = Game::Instance()->UseGestures() ? NO : YES;
	
	TextButton* useArrowsButton = [mButtons objectForKey:@"UseArrows"];
	[useArrowsButton refreshWithlocalizedTextName:"UseArrows"];
	useArrowsButton.visible = !useGesturesButton.visible;
	
	if (useGesturesButton.visible && useArrowsButton.focused)
	{
		[self removeFocus];
		[self setFocusToButton:useGesturesButton];
	}
	else if (useArrowsButton.visible && useGesturesButton.focused)
	{
		[self removeFocus];
		[self setFocusToButton:useArrowsButton];
	}
	
	// ---
	
	CCSprite* leftButton = [mControlButtons objectForKey:@"Left"];
	leftButton.visible = useGesturesButton.visible;
	
	CCSprite* rightButton = [mControlButtons objectForKey:@"Right"];
	rightButton.visible = useGesturesButton.visible;
	
	// Labels
	
	[mLabel refreshWithLocalizedStringName:"Controls" smallFont:false];
	
	[mMessageLabel refreshWithLocalizedStringName:"AdjustCtrlMsg1" smallFont:true];
	
	[mMessageLabel2 refreshWithLocalizedStringName:"AdjustCtrlMsg2" smallFont:true];
	mMessageLabel2.visible = !useGesturesButton.visible;
}

-(void) setButton:(CCSprite*)button atPosition:(CGPoint)pos
{
	CCSprite* leftButton = [mControlButtons objectForKey:@"Left"];
	CCSprite* rightButton = [mControlButtons objectForKey:@"Right"];
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	CGFloat quant = Game::Instance()->Quant();
	
	if (button == leftButton)
	{
		pos.x = Clamp(pos.x,
					  0.5F * Game::Instance()->ControlButtonWidth(),
					  winSize.width - 1.5F * Game::Instance()->ControlButtonWidth());
	}
	else if (button == rightButton)
	{
		pos.x = Clamp(pos.x,
					  1.5F * Game::Instance()->ControlButtonWidth(),
					  winSize.width - 0.5F * Game::Instance()->ControlButtonWidth());
	}
	else
	{
		pos.x = Clamp(pos.x,
					  0.5F * Game::Instance()->ControlButtonWidth(),
					  winSize.width - 0.5F * Game::Instance()->ControlButtonWidth());
	}
	
	CGFloat divX = (int)(pos.x / quant);
	CGFloat residueX = pos.x / quant - divX;
	pos.x = (residueX < 0.5) ? divX * quant : (divX + 1) * quant;
	
	pos.y = Clamp(pos.y,
				  0.5F * Game::Instance()->ControlButtonWidth(),
				  0.5F * winSize.height - 0.5F * Game::Instance()->ControlButtonWidth());
	CGFloat divY = (int)(pos.y / quant);
	CGFloat residueY = pos.y / quant - divY;
	pos.y = (residueY < 0.5) ? divY * quant : (divY + 1) * quant;
	
	button.position = pos;
}

-(void) resetButtonPositions
{
	for (NSString* key in mControlButtons)
	{
		CGPoint origPosition = Game::Instance()->OrigControlPosition([key UTF8String]);
		Game::Instance()->SetControlPosition([key UTF8String], origPosition);
		
		CCSprite* button = [mControlButtons objectForKey:key];
		button.position = origPosition;
	}
}

// ---------------------------------------------------------------------------

-(void) clickFocusedButton
{
	if (!mCanTouch) return;
	
	if (mFocusedButton)
	{
		TextButton* nextFocusedButton = nil;
		
		if ([mButtons objectForKey:@"UseGestures"] == mFocusedButton)
		{
			nextFocusedButton = [mButtons objectForKey:@"UseArrows"];
		}
		else if ([mButtons objectForKey:@"UseArrows"] == mFocusedButton)
		{
			nextFocusedButton = [mButtons objectForKey:@"UseGestures"];
		}
		
		[super clickFocusedButton];
		
		if (nextFocusedButton != nil)
		{
			[self removeFocus];
			[self setFocusToButton:nextFocusedButton];
		}
	}
}

// ---------------------------------------------------------------------------

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	// First, check whether any of the TextButtons was clicked, e.g. "Save",
	// "Reset", "Switch to Gestures".
	
	TextButton* button = [self processButtonForTouchBegan:touch];
	
	// If not, check whether any of the control buttons was clicked.
	
	if (button == nil)
	{
		// Determine which control button is the closest to where the touch occured.
		CCSprite* closestButton = nil;
		NSString* closestButtonKey = nil;
		CGFloat minDistance = 1000000000;
		
		for (NSString* key in mControlButtons)
		{
			CCSprite* ctrlButton = [mControlButtons objectForKey:key];
			
			if (ctrlButton && ctrlButton.visible && SpriteContainsPoint(ctrlButton, location))
			{
				CGFloat distance = ccpDistanceSQ(ctrlButton.position, location);
				
				if (distance < minDistance)
				{
					closestButton = ctrlButton;
					
					[closestButtonKey release];
					closestButtonKey = [key retain];
					
					minDistance = distance;
				}
			}
		}
		
		if (closestButton)
		{
			NSString* name = [[NSString alloc] initWithFormat:@"%@Selected", closestButtonKey];
			SetSpriteFrame(closestButton, Game::Instance()->Data().ButtonFrameName(name));
			[name release];
			
			[mControlTouches setObject:touch forKey:closestButtonKey];
			
			mOffset[[closestButtonKey UTF8String]] = ccpSub(closestButton.position, location);
			
			[closestButtonKey release];
		}
	}
	
	return YES;
}

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	// First, check whether any of the TextButtons was moved, e.g. "Save",
	// "Reset", "Switch to Gestures".
	
	TextButton* button = [self processButtonForTouchMoved:touch];
	
	// If not, check whether any of the control buttons was moved.
	
	if (button == nil)
	{
		for (NSString* key in mControlTouches)
		{
			UITouch* controlTouch = [mControlTouches objectForKey:key];
			
			if (touch == controlTouch)
			{
				CCSprite* ctrlButton = [mControlButtons objectForKey:key];
				[self setButton:ctrlButton atPosition:ccpAdd(mOffset[[key UTF8String]], location)];
				
				CCSprite* leftButton = [mControlButtons objectForKey:@"Left"];
				CCSprite* rightButton = [mControlButtons objectForKey:@"Right"];
				
				if (ctrlButton == leftButton)
				{
					CGPoint rightBtnPos = ccpAdd(leftButton.position, ccp(Game::Instance()->ControlButtonWidth(), 0));
					[self setButton:rightButton atPosition:rightBtnPos];
				}
				else if (ctrlButton == rightButton)
				{
					CGPoint leftBtnPos = ccpAdd(rightButton.position, ccp(-Game::Instance()->ControlButtonWidth(), 0));
					[self setButton:leftButton atPosition:leftBtnPos];
				}
				
				break;
			}
		}
	}
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	// First, check whether any of the TextButtons was released, e.g. "Save",
	// "Reset", "Switch to Gestures".
	
	TextButton* button = [self processButtonForTouchEnded:touch];
	
	// If not, check whether any of the control buttons was released.

	if (button == nil)
	{
		for (NSString* key in mControlTouches)
		{
			UITouch* controlTouch = [mControlTouches objectForKey:key];
			
			if (touch == controlTouch)
			{
				CCSprite* ctrlButton = [mControlButtons objectForKey:key];
				[self setButton:ctrlButton atPosition:ccpAdd(mOffset[[key UTF8String]], location)];
				
				Game::Instance()->SetControlPosition([key UTF8String], ctrlButton.position);
				
				CCSprite* leftButton = [mControlButtons objectForKey:@"Left"];
				CCSprite* rightButton = [mControlButtons objectForKey:@"Right"];
				
				if (ctrlButton == leftButton)
				{
					CGPoint rightBtnPos = ccpAdd(leftButton.position, ccp(Game::Instance()->ControlButtonWidth(), 0));
					[self setButton:rightButton atPosition:rightBtnPos];
					Game::Instance()->SetControlPosition("Right", rightButton.position);
				}
				else if (ctrlButton == rightButton)
				{
					CGPoint leftBtnPos = ccpAdd(rightButton.position, ccp(-Game::Instance()->ControlButtonWidth(), 0));
					[self setButton:leftButton atPosition:leftBtnPos];
					Game::Instance()->SetControlPosition("Left", leftButton.position);
				}
				
				NSString* name = [[NSString alloc] initWithFormat:@"%@Normal", key];
				SetSpriteFrame(ctrlButton, Game::Instance()->Data().ButtonFrameName(name));
				[name release];
				
				[mControlTouches removeObjectForKey:key];
				break;
			}
		}
	}
}

@end
