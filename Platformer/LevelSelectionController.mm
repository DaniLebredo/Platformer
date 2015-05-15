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

#import "LevelSelectionController.h"
#import "LevelSelectionStates.h"
#import "LevelSelectionScene.h"

#import "Game.h"
#import "IAPManager.h"


LevelSelectionController::LevelSelectionController(int centeredWorldId, int levelId) :
	mSelectedWorldId(-1),
	mSelectedLevelId(-1)
{
	mScene = [[LevelSelectionScene alloc] initWithLevelSelectionController:this];
	
	[mScene centerWorld:centeredWorldId];
	
	if (levelId > -1 && SelectWorld(centeredWorldId))
	{
		HideWorldsScreen();
		ShowLevelsScreen(levelId);
		mNextState = LevelSelectionState_Levels::Instance();
	}
	else
	{
		mNextState = LevelSelectionState_Worlds::Instance();
	}
	
	State<LevelSelectionController>* startState = LevelSelectionState_EnterTransition::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(LevelSelectionState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

LevelSelectionController::~LevelSelectionController()
{
	CCLOG(@"DEALLOC: LevelSelectionController");
	
	[mScene release];
	
	CCLOG(@"END DEALLOC: LevelSelectionController");
}

void LevelSelectionController::OnSceneEntered()
{
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_SceneEntered, NULL);
	HandleMessage(telegram);
}

void LevelSelectionController::ShowWorldsScreen()
{
	if (mSelectedWorldId > -1)
		[mScene centerWorld:mSelectedWorldId];
	
	[mScene showWorlds];
}

void LevelSelectionController::HideWorldsScreen()
{
	[mScene hideWorlds];
}

void LevelSelectionController::ShowLevelsScreen(int levelId)
{
	[mScene showLevelsForWorld:mSelectedWorldId focusLevel:levelId];
}

void LevelSelectionController::HideLevelsScreen()
{
	[mScene hideLevels];
}

void LevelSelectionController::AnimateLevelsScreen()
{
	[mScene animateLevels];
}

void LevelSelectionController::ShowStoreScreen()
{
	[mScene showStore];
}

void LevelSelectionController::HideStoreScreen()
{
	[mScene hideStore];
}

void LevelSelectionController::SetStoreAvailability(bool available)
{
	[mScene setStoreAvailability:available];
}

void LevelSelectionController::ShowBusyScreen()
{
	[mScene showBusy];
}

void LevelSelectionController::HideBusyScreen()
{
	[mScene hideBusy];
}

bool LevelSelectionController::SelectWorld(int worldId)
{
	if (Game::Instance()->Data().World(worldId).Locked())
	{
		CCLOG(@"LOCKED WORLD: %d", worldId);
		return false;
	}
	else
	{
		mSelectedWorldId = worldId;
		return true;
	}
}

bool LevelSelectionController::SelectLevel(int levelId)
{
	if (Game::Instance()->Data().World(mSelectedWorldId).Level(levelId).Locked())
	{
		CCLOG(@"LOCKED LEVEL: %d-%d", mSelectedWorldId, levelId);
		return false;
	}
	else
	{
		mSelectedLevelId = levelId;
		return true;
	}
}

void LevelSelectionController::GoToSelectedWorldAndLevel()
{
	Game::Instance()->GoToLoading(Scene_Level, mSelectedWorldId, mSelectedLevelId);
}
