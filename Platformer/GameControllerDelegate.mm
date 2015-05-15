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

#import "GameControllerDelegate.h"
#import "Game.h"


@implementation GameControllerDelegate

@synthesize gameController = mGameController;

-(id) init
{
	self = [super init];
	if (self)
	{
		mGameController = nil;
		
		[self resetLastValues];
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) resetLastValues
{
	mLastValues[GCBtn_DPadUp]		= false;
	mLastValues[GCBtn_DPadDown]		= false;
	mLastValues[GCBtn_DPadLeft]		= false;
	mLastValues[GCBtn_DPadRight]	= false;
	mLastValues[GCBtn_LThumbUp]		= false;
	mLastValues[GCBtn_LThumbDown]	= false;
	mLastValues[GCBtn_LThumbLeft]	= false;
	mLastValues[GCBtn_LThumbRight]	= false;
	mLastValues[GCBtn_RThumbUp]		= false;
	mLastValues[GCBtn_RThumbDown]	= false;
	mLastValues[GCBtn_RThumbLeft]	= false;
	mLastValues[GCBtn_RThumbRight]	= false;
	mLastValues[GCBtn_ButtonA]		= false;
	mLastValues[GCBtn_ButtonB]		= false;
	mLastValues[GCBtn_ButtonX]		= false;
	mLastValues[GCBtn_ButtonY]		= false;
	mLastValues[GCBtn_ButtonL1]		= false;
	mLastValues[GCBtn_ButtonR1]		= false;
	mLastValues[GCBtn_ButtonL2]		= false;
	mLastValues[GCBtn_ButtonR2]		= false;
}

-(void) controllerDidConnect:(NSNotification*)notification
{
	if (![[GCController controllers] containsObject:self.gameController])
		self.gameController = nil;
	
	if (self.gameController != nil) return; // We already have a connected controller.
	
	[self setupController:(GCController*)notification.object];
	
	// State changed because now there is a controller.
	Game::Instance()->OnControllerStateChanged();
}

-(void) controllerDidDisconnect:(NSNotification*)notification
{
	if (self.gameController == notification.object)
	{
		self.gameController = nil;
		
		if ([[GCController controllers] count] > 0)
		{
			[self setupController:[[GCController controllers] firstObject]];
		}
		else
		{
			[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
			
			// State changed because now there are no controllers.
			Game::Instance()->OnControllerStateChanged();
		}
	}
}

-(void) setupController:(GCController*)controller
{
	self.gameController = controller;
	
	GCGamepad* profile = self.gameController.gamepad;
	
	if (profile == nil)
	{
		self.gameController = nil;
		return;
	}
	
	[self resetLastValues];
	
	// Prevent auto-lock.
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	// Pause/resume button handler.
	self.gameController.controllerPausedHandler = ^(GCController *controller)
	{
		Game::Instance()->ActiveSceneController()->OnButtonClicked(Btn_Pause);
	};
	
	// Basic profile.
	
	profile.dpad.left.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_DPadLeft pressedValue:value];
	};
	
	profile.dpad.right.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_DPadRight pressedValue:value];
	};
	
	profile.dpad.up.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_DPadUp pressedValue:value];
	};
	
	profile.dpad.down.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_DPadDown pressedValue:value];
	};
	
	profile.buttonA.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_ButtonA pressedValue:value];
	};
	
	profile.buttonB.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_ButtonB pressedValue:value];
	};
	
	profile.buttonX.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_ButtonX pressedValue:value];
	};
	
	profile.buttonY.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_ButtonY pressedValue:value];
	};
	
	/*
	profile.leftShoulder.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_ButtonL1 pressed:(value > 0)];
	};
	
	profile.rightShoulder.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
	{
		[self checkIfStateChangedFor:GCBtn_ButtonR1 pressed:(value > 0)];
	};
	 */
	
	// Extended profile.
	
	GCExtendedGamepad* extendedProfile = self.gameController.extendedGamepad;
	
	if (extendedProfile != nil)
	{
		extendedProfile.leftThumbstick.left.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_LThumbLeft pressedValue:value];
		};
		
		extendedProfile.leftThumbstick.right.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_LThumbRight pressedValue:value];
		};
		
		extendedProfile.leftThumbstick.up.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_LThumbUp pressedValue:value];
		};
		
		extendedProfile.leftThumbstick.down.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_LThumbDown pressedValue:value];
		};
		
		extendedProfile.rightThumbstick.left.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_RThumbLeft pressedValue:value];
		};
		
		extendedProfile.rightThumbstick.right.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_RThumbRight pressedValue:value];
		};
		
		extendedProfile.rightThumbstick.up.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_RThumbUp pressedValue:value];
		};
		
		extendedProfile.rightThumbstick.down.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_RThumbDown pressedValue:value];
		};
		
		/*
		extendedProfile.leftTrigger.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_ButtonL2 pressed:(value > 0)];
		};
		
		extendedProfile.rightTrigger.valueChangedHandler = ^(GCControllerButtonInput* button, float value, BOOL pressed)
		{
			[self checkIfStateChangedFor:GCBtn_ButtonR2 pressed:(value > 0)];
		};
		 */
	}
}

-(void) checkIfStateChangedFor:(GCButtonType)gcButtonId pressedValue:(float)value
{
	bool isPressed = Game::Instance()->ActiveSceneController()->IsGCButtonPressed(gcButtonId, value);
	
	if (mLastValues[gcButtonId] != isPressed)
	{
		//NSLog(@"STATE CHANGED: BUTTON %d ==> PRESSED: %d", gcButtonId, isPressed);

		mLastValues[gcButtonId] = isPressed;
		
		ButtonType buttonId = Game::Instance()->ActiveSceneController()->TranslateGCButtonToButton(gcButtonId);
		
		if (buttonId != Btn_Invalid)
		{
			if (isPressed)
				Game::Instance()->ActiveSceneController()->OnButtonPressed(buttonId);
			else Game::Instance()->ActiveSceneController()->OnButtonReleased(buttonId);
		}
	}
}

@end
