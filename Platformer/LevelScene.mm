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

#import "LevelScene.h"
#import "ActionLayer.h"
#import "HUDLayer.h"
#import "PauseMenuLayer.h"
#import "LevelCompleteLayer.h"
#import "LifeLostLayer.h"
#import "GetReadyLayer.h"
#import "ScrollableLayer.h"
#import "SettingsLayer.h"
#import "ControlsLayer.h"
#import "GameCompleteLayer.h"

#import "Game.h"
#import "LevelController.h"
#import "PlayerNormal.h"
#import "PlayerGravity.h"

#import "AppDelegate.h"
#import <Social/Social.h>


@implementation LevelScene

@synthesize actionLayer = mActionLayer;
@synthesize scrollableLayer = mScrollableLayer;

-(id) init
{
	return nil;
}

-(id) initWithSceneController:(SceneController*)scene
{
	return nil;
}

-(id) initWithLevelController:(LevelController*)controller
{
	self = [super initWithSceneController:controller];
	if (self)
	{
		WorldData& wd = Game::Instance()->Data().World(controller->WorldId());
		
		NSString* bkgFilename = [NSString stringWithUTF8String:wd.StaticBackground().c_str()];
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		mBackground = [[CCSprite alloc] initWithFile:bkgFilename];
		mBackground.anchorPoint = ccp(0, 1);
		mBackground.position = ccp(0, winSize.height);
		mBackground.scale = 2;
		if (Game::Instance()->DebugOn()) mBackground.opacity = 0;
		[self addChild:mBackground z:0];
		
		mScrollableLayer = [[ScrollableLayer alloc] initWithImage:@"Hills" numTiles:2 numVisibleTiles:3];
		[self addChild:mScrollableLayer z:10];
		
		mActionLayer = [[ActionLayer alloc] initWithLevelController:controller];
		//float yOffset = IsRunningOnPad() ? -6 : -35;
		//mActionLayer.position = ccp(mActionLayer.position.x, yOffset);
		[self addChild:mActionLayer z:20];
		
		mHUDLayer = [[HUDLayer alloc] initWithLevelController:controller];
		[self addChild:mHUDLayer z:30];
		
		mPauseMenuLayer = [[PauseMenuLayer alloc] initWithLevelController:controller];
		[self addChild:mPauseMenuLayer z:40];
		
		mLevelCompleteLayer = [[LevelCompleteLayer alloc] initWithLevelController:controller];
		[self addChild:mLevelCompleteLayer z:40];
		
		mLifeLostLayer = [[LifeLostLayer alloc] initWithLevelController:controller];
		[self addChild:mLifeLostLayer z:40];
		
		mGetReadyLayer = [[GetReadyLayer alloc] initWithLevelController:controller];
		[self addChild:mGetReadyLayer z:40];
		
		mSettingsLayer = [[SettingsLayer alloc] initWithSceneController:controller];
		[self addChild:mSettingsLayer z:40];
		
		mControlsLayer = [[ControlsLayer alloc] initWithSceneController:controller];
		[self addChild:mControlsLayer z:50];
		
		// This layer will be created just before it's displayed on screen.
		mGameCompleteLayer = nil;
	}
	return self;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: LevelScene");
	
	[mBackground release];
	[mScrollableLayer release];
	[mActionLayer release];
	[mHUDLayer release];
	[mPauseMenuLayer release];
	[mLevelCompleteLayer release];
	[mLifeLostLayer release];
	[mGetReadyLayer release];
	[mSettingsLayer release];
	[mControlsLayer release];
	[mGameCompleteLayer release];
	
	[super dealloc];
}

-(void) addGameObject:(GameObject*)gObj
{
	[mActionLayer addGameObject:gObj];
}

-(void) updateCamera:(CGPoint)targetPos
{
}

-(void) updateStatusBar
{
	LevelController* controller = static_cast<LevelController*>(mSceneController);
	
	[mHUDLayer setScoreLabel:controller->NumCoinsCollected() outOf:controller->NumCoinsToCollect()];
	[mHUDLayer setLivesLabel:controller->NumLivesLeft()];
	[mHUDLayer setTimeLabel:ceilf(controller->TimeLeft())];
	
	if (controller->LvlType() == Level_Normal)
	{
		PlayerNormal* player = static_cast<PlayerNormal*>(controller->PlayerObj());
		[mHUDLayer setKeysLabel:player->NumKeys()];
	}
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

-(void) hideGetReadyLayer
{
	[self hideLayer:mGetReadyLayer];
}

-(void) showPauseLayer
{
	[mPauseMenuLayer preDisplay];
	[mPauseMenuLayer refreshStats];
	[self showLayer:mPauseMenuLayer];
	mFocusedLayer = mPauseMenuLayer;
}

-(void) hidePauseLayer
{
	[self hideLayer:mPauseMenuLayer];
}

-(void) animatePauseLayer
{
	[mPauseMenuLayer animate];
}

-(void) showHUDLayer
{
	[mHUDLayer preDisplay];
	[self showLayer:mHUDLayer];
	mFocusedLayer = nil;
}

-(void) hideHUDLayer
{
	[mHUDLayer preHide];
	[self hideLayer:mHUDLayer];
}

-(void) refreshControlsInHUDLayer
{
	[mHUDLayer refreshControls];
}

-(void) showLifeLostLayer
{
	[mLifeLostLayer preDisplay];
	[self showLayer:mLifeLostLayer];
	mFocusedLayer = mLifeLostLayer;
}

-(void) animateLifeLostLayer
{
	[mLifeLostLayer animate];
}

-(void) showLevelCompletedLayer
{
	[mLevelCompleteLayer preDisplay];
	[mLevelCompleteLayer calculateStats];
	[self showLayer:mLevelCompleteLayer];
	mFocusedLayer = mLevelCompleteLayer;
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

-(void) createGameCompleteLayer
{
	mGameCompleteLayer = [[GameCompleteLayer alloc] initWithLevelController:static_cast<LevelController*>(mSceneController)];
	[self addChild:mGameCompleteLayer z:50];
}

-(void) showWorldCompleted
{
	[self createGameCompleteLayer];
	[mGameCompleteLayer preDisplayWorldCompleted];
	[self showLayer:mGameCompleteLayer];
	mFocusedLayer = mGameCompleteLayer;
	
	[self hideLayer:mLevelCompleteLayer];
}

-(void) showGameCompleted
{
	[self createGameCompleteLayer];
	[mGameCompleteLayer preDisplayGameCompleted];
	[self showLayer:mGameCompleteLayer];
	mFocusedLayer = mGameCompleteLayer;
	
	[self hideLayer:mLevelCompleteLayer];
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

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterController
{
	mFocusedLayer.canTouch = true;
	
	AppController* delegate = [UIApplication sharedApplication].delegate;
	[delegate.navController dismissViewControllerAnimated:YES completion:nil];
	[gameCenterController release];
}

-(void) postTweet
{
	LevelController* controller = static_cast<LevelController*>(mSceneController);
	
	NSString* text = [[NSString alloc] initWithFormat:@"I've just finished level %d-%d in Lethal Lance!", controller->WorldId() + 1, controller->LevelId() + 1];
	
	SLComposeViewController* twitterController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	[twitterController setInitialText:text];
	[twitterController addURL:[NSURL URLWithString:@"http://www.lethallance.com"]];
	//[twitterController addImage:[UIImage imageNamed:@"test.jpg"]];
	
	[text release];
	
	AppController* delegate = [UIApplication sharedApplication].delegate;
	
	// Called when the tweet dialog has been closed.
	twitterController.completionHandler = ^(SLComposeViewControllerResult result)
	{
		mFocusedLayer.canTouch = true;
		
		if (IsOSVersionSupported(@"7.0"))
		{
			// Modal dialog is automatically dismissed on iOS 7, so don't do anything.
		}
		else
		{
			// Modal dialog has to be manually dismissed on iOS 6.
			[delegate.navController dismissViewControllerAnimated:YES completion:nil];
		}
	};
	
	mFocusedLayer.canTouch = false;
	
	[delegate.navController presentViewController:twitterController animated:YES completion:nil];
}

-(void) postFacebookMessage
{
	LevelController* controller = static_cast<LevelController*>(mSceneController);
	
	NSString* text = [[NSString alloc] initWithFormat:@"I've just finished level %d-%d in Lethal Lance!", controller->WorldId() + 1, controller->LevelId() + 1];
	
	SLComposeViewController* facebookController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
	[facebookController setInitialText:text];
	[facebookController addURL:[NSURL URLWithString:@"http://www.lethallance.com"]];
	//[facebookController addImage:[UIImage imageNamed:@"test.jpg"]];
	
	[text release];
	
	AppController* delegate = [UIApplication sharedApplication].delegate;
	
	// Called when the tweet dialog has been closed.
	facebookController.completionHandler = ^(SLComposeViewControllerResult result)
	{
		mFocusedLayer.canTouch = true;
		
		if (IsOSVersionSupported(@"7.0"))
		{
			// Modal dialog is automatically dismissed on iOS 7, so don't do anything.
		}
		else
		{
			// Modal dialog has to be manually dismissed on iOS 6.
			[delegate.navController dismissViewControllerAnimated:YES completion:nil];
		}
	};
	
	mFocusedLayer.canTouch = false;
	
	[delegate.navController presentViewController:facebookController animated:YES completion:nil];
}

@end
