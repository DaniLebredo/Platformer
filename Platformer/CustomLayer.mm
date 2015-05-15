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

#import "CustomLayer.h"
#import "SceneController.h"
#import "Utility.h"
#import "GameControllerManager.h"


@implementation CustomLayer

@synthesize canTouch = mCanTouch;

-(void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(id) initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h
{
	return nil;
}

-(id) initWithSceneController:(SceneController*)controller
{
	return [self initWithSceneController:controller color:ccc4(0, 0, 0, 0)];
}

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	self = [super initWithColor:color width:winSize.width height:winSize.height];
	if (self)
	{
		mSceneController = controller;
		
		mContainer = [[CCNode alloc] init];
		[self addChild:mContainer];
		
		mButtons = [[NSMutableDictionary alloc] initWithCapacity:10];
		
		mFocusedButton = nil;
		mPreferredFocusButton = nil;
		
		[self resetFocusDirectionValues];
		
		mCanTouch = true;
		
		mAnimDuration = 0.2;
	}
	return self;
}

-(void) dealloc
{
	mSceneController = NULL;
	
	[mContainer release];
	
	[mButtons release];
	
	[super dealloc];
}

-(void) animate
{
	mCanTouch = false;
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	[mContainer stopAllActions];
	//mContainer.position = ccp(0.5 * winSize.width, 0);
	mContainer.position = ccp(0, 0.5 * winSize.height);
	
	[mContainer runAction:[CCSequence actions:[CCEaseExponentialOut actionWithAction:
											   [CCMoveTo actionWithDuration:mAnimDuration position:PNGMakePoint(0, 0)]],
						   [CCCallFuncN actionWithTarget:self selector:@selector(appearAnimationFinished:)],
						   nil]];
}

-(void) appearAnimationFinished:(CCNode*)node
{
	mCanTouch = true;
}

// ---------------------------------------------------------------------------

-(bool) isFocusDirectionSpecified
{
	return mFocusDirection[FocusDir_Up] || mFocusDirection[FocusDir_Down] ||
			mFocusDirection[FocusDir_Left] || mFocusDirection[FocusDir_Right];
}

-(void) resetFocusDirectionValues
{
	mFocusDirection[FocusDir_Up] = false;
	mFocusDirection[FocusDir_Down] = false;
	mFocusDirection[FocusDir_Left] = false;
	mFocusDirection[FocusDir_Right] = false;
}

-(bool) canButtonBeFocused:(TextButton*)button
{
	return button && button.visible;
}

-(void) setFocusToButton:(TextButton*)button
{
	for (NSString* key in mButtons)
	{
		TextButton* txtButton = [mButtons objectForKey:key];
		
		if (txtButton == button && [self canButtonBeFocused:txtButton])
		{
			[self removeFocus];
			
			txtButton.focused = true;
			mFocusedButton = txtButton;
			
			return;
		}
	}
}

-(void) setFocusToFirstPossibleButton
{
	if ([self canButtonBeFocused:mPreferredFocusButton])
	{
		[self setFocusToButton:mPreferredFocusButton];
	}
	else
	{
		for (NSString* key in mButtons)
		{
			TextButton* txtButton = [mButtons objectForKey:key];
			
			if ([self canButtonBeFocused:txtButton])
			{
				[self setFocusToButton:txtButton];
				return;
			}
		}
	}
}

-(void) setFocusToClosestButtonInFocusDirection
{
	if (![self isFocusDirectionSpecified]) return;
	
	if (!mFocusedButton)
	{
		[self setFocusToFirstPossibleButton];
		return;
	}
	
	TextButton* closestButton = nil;
	CGFloat minDistance = 1000000000;
	
	for (NSString* key in mButtons)
	{
		TextButton* button = [mButtons objectForKey:key];
		
		if (![self canButtonBeFocused:button]) continue;
		
		if (mFocusDirection[FocusDir_Up])
		{
			if (button.position.y < mFocusedButton.position.y + 0.9 * 0.5 * mFocusedButton.height) continue;
		}
		else if (mFocusDirection[FocusDir_Down])
		{
			if (button.position.y > mFocusedButton.position.y - 0.9 * 0.5 * mFocusedButton.height) continue;
		}
		
		if (mFocusDirection[FocusDir_Left])
		{
			if (button.position.x > mFocusedButton.position.x - 0.9 * 0.5 * mFocusedButton.width) continue;
		}
		else if (mFocusDirection[FocusDir_Right])
		{
			if (button.position.x < mFocusedButton.position.x + 0.9 * 0.5 * mFocusedButton.width) continue;
		}
		
		CGFloat distance = ccpDistanceSQ(button.position, mFocusedButton.position);
		
		if (distance < minDistance)
		{
			closestButton = button;
			minDistance = distance;
		}
	}
	
	if (closestButton)
	{
		[self setFocusToButton:closestButton];
	}
}

-(void) removeFocus
{
	if (mFocusedButton)
	{
		mFocusedButton.focused = false;
		mFocusedButton = nil;
	}
}

-(void) moveFocus:(FocusDirection)focusDirection
{
	if (!mCanTouch) return;
	
	mFocusDirection[focusDirection] = true;
	
	// Cancel opposite directions, as they don't make sense.
	
	switch (focusDirection)
	{
		case FocusDir_Up:
			mFocusDirection[FocusDir_Down] = false;
			break;
			
		case FocusDir_Down:
			mFocusDirection[FocusDir_Up] = false;
			break;
			
		case FocusDir_Left:
			mFocusDirection[FocusDir_Right] = false;
			break;
			
		case FocusDir_Right:
			mFocusDirection[FocusDir_Left] = false;
			break;
			
		default:
			break;
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
			[self setFocusToClosestButtonInFocusDirection];
		}
	}
	else
	{
		[self removeFocus];
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
		
		if (mSceneController) mSceneController->OnButtonClicked(buttonId, userData);
	}
}

// ---------------------------------------------------------------------------

-(TextButton*) processButtonForTouchBegan:(UITouch*)touch
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	for (NSString* key in mButtons)
	{
		TextButton* button = [mButtons objectForKey:key];
		
		if (button && button.visible && [button containsPoint:location])
		{
			button.selected = true;
			button.userObject = touch;
			
			ButtonType buttonId = static_cast<ButtonType>(reinterpret_cast<int>(button.userData));
			void* userData = reinterpret_cast<void*>(button.userInt);
			
			if (mSceneController) mSceneController->OnButtonPressed(buttonId, userData);
			
			return button;
		}
	}
	
	return nil;
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	if (mCanTouch)
	{
		[self processButtonForTouchBegan:touch];
	}
	
	return YES;
}

// ---------------------------------------------------------------------------

-(TextButton*) processButtonForTouchMoved:(UITouch*)touch
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	for (NSString* key in mButtons)
	{
		TextButton* button = [mButtons objectForKey:key];
		
		if (button && button.visible && button.userObject == touch)
		{
			button.selected = [button containsPoint:location];
			return button;
		}
	}
	
	return nil;
}

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
	[self processButtonForTouchMoved:touch];
}

// ---------------------------------------------------------------------------

-(TextButton*) processButtonForTouchEnded:(UITouch*)touch
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	for (NSString* key in mButtons)
	{
		TextButton* button = [mButtons objectForKey:key];
		
		if (button && button.visible && button.userObject == touch)
		{
			button.selected = false;
			button.userObject = nil;
			
			ButtonType buttonId = static_cast<ButtonType>(reinterpret_cast<int>(button.userData));
			void* userData = reinterpret_cast<void*>(button.userInt);
			
			if (mSceneController)
			{
				mSceneController->OnButtonReleased(buttonId, userData);
				
				if ([button containsPoint:location])
					mSceneController->OnButtonClicked(buttonId, userData);
			}
			
			return button;
		}
	}
	
	return nil;
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	[self processButtonForTouchEnded:touch];
}

@end
