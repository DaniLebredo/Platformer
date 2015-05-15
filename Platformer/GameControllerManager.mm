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

#import "GameControllerManager.h"
#import "Utility.h"

#import "GameControllerDelegate.h"


GameControllerManager::GameControllerManager() :
	mControllerAPIAvailable(false)
{
	mDelegate = nil;
	mControllerAPIAvailable = IsOSVersionSupported(@"7.0") && [GCController class];
	
	if (mControllerAPIAvailable)
	{
		mDelegate = [[GameControllerDelegate alloc] init];
		CCLOG(@"GAME CONTROLLER DELEGATE CREATED");
	}
}

GameControllerManager::~GameControllerManager()
{
	if (mControllerAPIAvailable)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:mDelegate
														name:GCControllerDidConnectNotification
													  object:nil];
		
		[[NSNotificationCenter defaultCenter] removeObserver:mDelegate
														name:GCControllerDidDisconnectNotification
													  object:nil];
	}
	
	[mDelegate release];
}

void GameControllerManager::RegisterControllerObserver()
{
	if (mControllerAPIAvailable)
	{
		[[NSNotificationCenter defaultCenter] addObserver:mDelegate
												 selector:@selector(controllerDidConnect:)
													 name:GCControllerDidConnectNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:mDelegate
												 selector:@selector(controllerDidDisconnect:)
													 name:GCControllerDidDisconnectNotification
												   object:nil];
	}
}

bool GameControllerManager::ControllerConnected() const
{
	if (!mControllerAPIAvailable) return false;
	
	return mDelegate.gameController != nil;
}
