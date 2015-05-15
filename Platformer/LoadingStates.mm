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

#import "LoadingStates.h"
#import "LoadingController.h"
#import "Game.h"
#import "GCManager.h"

// -------------------------------------------------------------------------------------

void LoadingState_Global::Execute(LoadingController* agent)
{
	agent->UpdateTimeElapsed();
}

bool LoadingState_Global::OnMessage(LoadingController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void LoadingState_EnterTransition::Enter(LoadingController* agent)
{
	CCLOG(@"Loading: ENTER TRANSITION");
}

bool LoadingState_EnterTransition::OnMessage(LoadingController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_SceneEntered:
		{
			agent->FSM()->ChangeState(LoadingState_LoadAssets::Instance());
			return true;
		}
			
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void LoadingState_LoadAssets::Enter(LoadingController* agent)
{
	CCLOG(@"Loading: LOAD ASSETS");
}

void LoadingState_LoadAssets::Execute(LoadingController* agent)
{
	if (agent->ShouldWaitUntilBackgroundMusicStops())
	{
		// Wait until the old background music has stopped playing.
	}
	else
	{
		agent->LoadAssets();
		agent->FSM()->ChangeState(LoadingState_Wait::Instance());
	}
}

void LoadingState_LoadAssets::Exit(LoadingController* agent)
{
}

bool LoadingState_LoadAssets::OnMessage(LoadingController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void LoadingState_Wait::Enter(LoadingController* agent)
{
	CCLOG(@"Loading: WAIT");
}

void LoadingState_Wait::Execute(LoadingController* agent)
{
	if (agent->Mode() == Loading_Logo && agent->TimeElapsed() < 3)
	{
		// Wait until our logo has been displayed for some time.
	}
	else
	{
		agent->FSM()->ChangeState(LoadingState_ChangeScene::Instance());
	}
}

void LoadingState_Wait::Exit(LoadingController* agent)
{
}

bool LoadingState_Wait::OnMessage(LoadingController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void LoadingState_ChangeScene::Enter(LoadingController* agent)
{
	CCLOG(@"Loading: CHANGE SCENE");
	agent->ChangeScene();
}

void LoadingState_ChangeScene::Exit(LoadingController* agent)
{
}

bool LoadingState_ChangeScene::OnMessage(LoadingController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------
