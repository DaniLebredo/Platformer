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

#import "MainMenuScene.h"
#import "ControlsLayer.h"
#import "CreditsLayer.h"
#import "StartMenuLayer.h"
#import "SettingsLayer.h"
#import "QuitLayer.h"
#import "MainMenuController.h"
#import "Game.h"

#import "AppDelegate.h"


@implementation MainMenuScene

-(id) init
{
	return nil;
}

-(id) initWithSceneController:(SceneController*)scene
{
	return nil;
}

-(id) initWithMainMenuController:(MainMenuController*)controller
{
	self = [super initWithSceneController:controller];
	if (self)
	{
		mStartMenuLayer = [[StartMenuLayer alloc] initWithMainMenuController:controller];
		[self addChild:mStartMenuLayer z:5];
		
		mCreditsLayer = [[CreditsLayer alloc] initWithMainMenuController:controller];
		[self addChild:mCreditsLayer z:10];
		
		mQuitLayer = [[QuitLayer alloc] initWithMainMenuController:controller];
		[self addChild:mQuitLayer z:10];
		
		mSettingsLayer = [[SettingsLayer alloc] initWithSceneController:controller];
		[self addChild:mSettingsLayer z:10];
		
		mControlsLayer = [[ControlsLayer alloc] initWithSceneController:controller];
		[self addChild:mControlsLayer z:20];
	}
	return self;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: MainMenuScene");
	
	[mStartMenuLayer release];
	[mCreditsLayer release];
	[mControlsLayer release];
	[mSettingsLayer release];
	[mQuitLayer release];
	
	[super dealloc];
}

-(void) pause
{
	CCLOG(@"NOTHING TO PAUSE HERE");
}

-(void) showLayer:(CCLayer*)layer
{
	layer.visible = YES;
	layer.touchEnabled = YES;
}

-(void) hideLayer:(CCLayer*)layer
{
	layer.visible = NO;
	layer.touchEnabled = NO;
}

-(void) showSplashScreen
{
	[mStartMenuLayer showButtons];
	mFocusedLayer = mStartMenuLayer;
}

-(void) hideSplashScreen
{
	[mStartMenuLayer hideButtons];
}

-(void) showSettings
{
	[mSettingsLayer preDisplay];
	[self showLayer:mSettingsLayer];
	mFocusedLayer = mSettingsLayer;
}

-(void) hideSettings
{
	[self hideLayer:mSettingsLayer];
}

-(void) refreshSettings
{
	[mSettingsLayer preDisplay];
}

-(void) animateSettings
{
	[mSettingsLayer animate];
}

-(void) showControls
{
	[mControlsLayer preDisplay];
	[self showLayer:mControlsLayer];
	mFocusedLayer = mControlsLayer;
}

-(void) hideControls
{
	[self hideLayer:mControlsLayer];
}

-(void) resetControls
{
	[mControlsLayer resetButtonPositions];
}

-(void) refreshControls
{
	[mControlsLayer preDisplay];
}

-(void) animateControls
{
	[mControlsLayer animate];
}

-(void) showCredits
{
	[mCreditsLayer preDisplay];
	[self showLayer:mCreditsLayer];
	mFocusedLayer = mCreditsLayer;
}

-(void) hideCredits
{
	[self hideLayer:mCreditsLayer];
}

-(void) animateCredits
{
	[mCreditsLayer animate];
}

-(void) showQuit
{
	[mQuitLayer preDisplay];
	[self showLayer:mQuitLayer];
	mFocusedLayer = mQuitLayer;
}

-(void) hideQuit
{
	[self hideLayer:mQuitLayer];
}

-(void) animateQuit
{
	[mQuitLayer animate];
}

-(void) showLeaderboards
{
	GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
	
	if (gameCenterController != nil)
	{
		gameCenterController.gameCenterDelegate = self;
		gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
		gameCenterController.leaderboardTimeScope = GKLeaderboardTimeScopeAllTime;
		gameCenterController.leaderboardCategory = @"eu.pointynose.lethallance.totalscore";
		
		mFocusedLayer.canTouch = false;
		
		AppController* delegate = [UIApplication sharedApplication].delegate;
		[delegate.navController presentViewController:gameCenterController animated:YES completion:nil];
	}
}

-(void) showAchievements
{
	GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
	
    if (gameCenterController != nil)
    {
		gameCenterController.gameCenterDelegate = self;
		gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
		
		mFocusedLayer.canTouch = false;
		
		AppController* delegate = [UIApplication sharedApplication].delegate;
		[delegate.navController presentViewController:gameCenterController animated:YES completion:nil];
    }
}

-(void) gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterController
{
	mFocusedLayer.canTouch = true;
	
	AppController* delegate = [UIApplication sharedApplication].delegate;
	[delegate.navController dismissViewControllerAnimated:YES completion:nil];
	[gameCenterController release];
}

@end
