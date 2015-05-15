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

#import "MainMenuController.h"
#import "MainMenuStates.h"
#import "MainMenuScene.h"

#import "Game.h"
#import "GCManager.h"
#import "IAPManager.h"


MainMenuController::MainMenuController()
{
	mScene = [[MainMenuScene alloc] initWithMainMenuController:this];
	
	State<MainMenuController>* startState = MainMenuState_EnterTransition::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(MainMenuState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

MainMenuController::~MainMenuController()
{
	CCLOG(@"DEALLOC: MainMenuController");
	
	[mScene release];
	
	CCLOG(@"END DEALLOC: MainMenuController");
}

void MainMenuController::OnSceneEntered()
{
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_SceneEntered, NULL);
	HandleMessage(telegram);
}

void MainMenuController::ShowSplashScreen()
{
	[mScene showSplashScreen];
}

void MainMenuController::HideSplashScreen()
{
	[mScene hideSplashScreen];
}

void MainMenuController::ShowCreditsScreen()
{
	[mScene showCredits];
}

void MainMenuController::HideCreditsScreen()
{
	[mScene hideCredits];
}

void MainMenuController::AnimateCreditsScreen()
{
	[mScene animateCredits];
}

void MainMenuController::ShowQuitScreen()
{
	[mScene showQuit];
}

void MainMenuController::HideQuitScreen()
{
	[mScene hideQuit];
}

void MainMenuController::AnimateQuitScreen()
{
	[mScene animateQuit];
}

void MainMenuController::ShowSettingsScreen()
{
	[mScene showSettings];
}

void MainMenuController::HideSettingsScreen()
{
	[mScene hideSettings];
}

void MainMenuController::AnimateSettingsScreen()
{
	[mScene animateSettings];
}

void MainMenuController::ShowControlsScreen()
{
	[mScene showControls];
}

void MainMenuController::HideControlsScreen()
{
	[mScene hideControls];
}

void MainMenuController::ResetControls()
{
	[mScene resetControls];
}

void MainMenuController::AnimateControlsScreen()
{
	[mScene animateControls];
}

void MainMenuController::RefreshSettingsScreen()
{
	[mScene refreshSettings];
}

void MainMenuController::RefreshControlsScreen()
{
	[mScene refreshControls];
}

void MainMenuController::ShowLeaderboards()
{
	if (GCManager::Instance()->PlayerAuthenticated())
	{
		[mScene showLeaderboards];
	}
}

void MainMenuController::ShowAchievements()
{
	if (GCManager::Instance()->PlayerAuthenticated())
	{
		[mScene showAchievements];
	}
}
