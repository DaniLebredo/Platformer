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

#import "LevelStates.h"
#import "LevelController.h"
#import "Game.h"
#import "GCManager.h"

// -------------------------------------------------------------------------------------

void LevelState_Global::Execute(LevelController* agent)
{
	agent->ApplyMoveFocus();
}

bool LevelState_Global::OnMessage(LevelController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonPressed:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Up:
					agent->MoveFocus(FocusDir_Up);
					break;
					
				case Btn_Down:
					agent->MoveFocus(FocusDir_Down);
					break;
					
				case Btn_Left:
					agent->MoveFocus(FocusDir_Left);
					break;
					
				case Btn_Right:
					agent->MoveFocus(FocusDir_Right);
					break;
					
				case Btn_A:
				case Btn_B:
					agent->ClickFocusedButton();
					break;
					
				default:
					return false;
			}
			
			return true;
		}
			
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Restart:
					Game::Instance()->GoToLevel(agent->WorldId(), agent->LevelId());
					break;
					
				case Btn_Quit:
					Game::Instance()->GoToLoading(Scene_LevelSelection, agent->WorldId(), agent->LevelId());
					break;
					
				default:
					return false;
			}
			
			SoundManager::Instance()->ScheduleEffect("ButtonClicked.caf");
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

void LevelState_EnterTransition::Enter(LevelController* agent)
{
	CCLOG(@"Level: ENTER TRANSITION");
	
	if (Game::Instance()->MusicOn())
		SoundManager::Instance()->SetBackgroundMusicVolume(BkgMusic_Loud);
}

bool LevelState_EnterTransition::OnMessage(LevelController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_SceneEntered:
		{
			agent->FSM()->ChangeState(LevelState_GetReady::Instance());
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

void LevelState_GetReady::Enter(LevelController* agent)
{
	CCLOG(@"Level: GET READY");
	agent->PauseGameObjects();
	agent->ResetReadyTimer();
}

void LevelState_GetReady::Execute(LevelController* agent)
{
	agent->UpdateReadyTimer();
	
	// After 2 secs in this state, switch to Normal state.
	if (agent->ReadyTimerValue() >= 2)
		agent->FSM()->ChangeState(LevelState_Normal::Instance());
}

void LevelState_GetReady::Exit(LevelController* agent)
{
	agent->HideGetReadyScreen();
}

bool LevelState_GetReady::OnMessage(LevelController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Ready:
					agent->FSM()->ChangeState(LevelState_Normal::Instance());
					break;
					
				default:
					return false;
			}
			
			return true;
		}
			
		case Msg_ButtonReleased:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_A:
				case Btn_B:
					agent->FSM()->ChangeState(LevelState_Normal::Instance());
					break;
					
				default:
					return false;
			}
			
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

void LevelState_Normal::Enter(LevelController* agent)
{
	CCLOG(@"Level: NORMAL");
	agent->ShowHUD();
	
	if (Game::Instance()->MusicOn())
		SoundManager::Instance()->SetBackgroundMusicVolume(BkgMusic_Loud);
	
	// All states that lead here (GetReady and Normal) have paused game objects.
	// That's why we need to resume them here.
	agent->ResumeGameObjects();
}

void LevelState_Normal::Execute(LevelController* agent)
{
	if (agent->TimeLeft() > 0) agent->UpdateTimeElapsed();
	agent->UpdateAll();
}

void LevelState_Normal::Exit(LevelController* agent)
{
	agent->HideHUD();
	
	if (Game::Instance()->MusicOn())
		SoundManager::Instance()->SetBackgroundMusicVolume(BkgMusic_Quiet);
}

bool LevelState_Normal::OnMessage(LevelController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Back:		// to account for Android's back button
				case Btn_Pause:
					agent->FSM()->ChangeState(LevelState_Paused::Instance());
					break;
					
				default:
					return false;
			}
			
			SoundManager::Instance()->ScheduleEffect("ButtonClicked.caf");
			return true;
		}
			
		case Msg_ButtonPressed:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Left:
					agent->PlayerObj()->OnButtonLeftPressed();
					break;
					
				case Btn_Right:
					agent->PlayerObj()->OnButtonRightPressed();
					break;
					
				case Btn_A:
					agent->PlayerObj()->OnButtonAPressed();
					break;
					
				case Btn_B:
					agent->PlayerObj()->OnButtonBPressed();
					break;
					
				default:
					return false;
			}
			
			return true;
		}
			
		case Msg_ButtonReleased:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Left:
					agent->PlayerObj()->OnButtonLeftReleased();
					break;
					
				case Btn_Right:
					agent->PlayerObj()->OnButtonRightReleased();
					break;
					
				case Btn_A:
					agent->PlayerObj()->OnButtonAReleased();
					break;
					
				case Btn_B:
					agent->PlayerObj()->OnButtonBReleased();
					break;
					
				default:
					return false;
			}
			
			return true;
		}
			
		case Msg_PauseGame:
		{
			agent->FSM()->ChangeState(LevelState_Paused::Instance());
			return true;
		}
			
		case Msg_LifeLost:
		{
			agent->FSM()->ChangeState(LevelState_LifeLost::Instance());
			return true;
		}
			
		case Msg_LevelComplete:
		{
			agent->BreakUpdateLoop();
			agent->FSM()->ChangeState(LevelState_LevelComplete::Instance());
			return true;
		}
			
		case Msg_HealthChanged:
		{
			CCLOG(@"LEVEL: Health Changed!");
			agent->UpdateStatusBar();
			return true;
		}
			
		case Msg_ControllerStateChanged:
			agent->RefreshControlsInHUD();
			break;
			
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void LevelState_Paused::Enter(LevelController* agent)
{
	CCLOG(@"Level: PAUSED");
	
	agent->ShowPauseScreen();
	
	if (agent->FSM()->WasInState(LevelState_Normal::Instance()))
	{
		agent->AnimatePauseScreen();
		
		agent->PauseGameObjects();
		
		// Immediately release all of the control buttons, because otherwise they
		// could get stuck when a player resumes the game.
		agent->PlayerObj()->OnButtonLeftReleased();
		agent->PlayerObj()->OnButtonRightReleased();
		agent->PlayerObj()->OnButtonAReleased();
		agent->PlayerObj()->OnButtonBReleased();
	}
}

void LevelState_Paused::Exit(LevelController* agent)
{
	agent->HidePauseScreen();
}

bool LevelState_Paused::OnMessage(LevelController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Back:		// to account for Android's back button
				case Btn_Pause:		// to account for MFi gamepad's pause button
				case Btn_Resume:
					agent->FSM()->ChangeState(LevelState_Normal::Instance());
					break;
					
				case Btn_Settings:
					agent->FSM()->ChangeState(LevelState_Settings::Instance());
					break;
					
				default:
					return false;
			}
			
			SoundManager::Instance()->ScheduleEffect("ButtonClicked.caf");
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

void LevelState_Settings::Enter(LevelController* agent)
{
	CCLOG(@"Level: SETTINGS");
	agent->ShowSettingsScreen();
	
	if (agent->FSM()->WasInState(LevelState_Paused::Instance()))
	{
		agent->AnimateSettingsScreen();
	}
}

void LevelState_Settings::Exit(LevelController* agent)
{
	agent->HideSettingsScreen();
}

bool LevelState_Settings::OnMessage(LevelController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Back:
					Game::Instance()->SaveStats();
					agent->FSM()->ChangeState(LevelState_Paused::Instance());
					break;
					
				case Btn_Controls:
					agent->FSM()->ChangeState(LevelState_Controls::Instance());
					break;
					
				case Btn_Music:
					Game::Instance()->SetMusicOn(!Game::Instance()->MusicOn());
					if (Game::Instance()->MusicOn())
						SoundManager::Instance()->SetBackgroundMusicVolume(BkgMusic_Quiet);
					agent->RefreshSettingsScreen();
					break;
					
				case Btn_Sound:
					Game::Instance()->SetSoundOn(!Game::Instance()->SoundOn());
					agent->RefreshSettingsScreen();
					break;
					
				case Btn_Language:
					Game::Instance()->Data().SelectNextLanguage();
					agent->RefreshSettingsScreen();
					agent->RefreshGameObjectTexts();
					break;
					
				default:
					return false;
			}
			
			SoundManager::Instance()->ScheduleEffect("ButtonClicked.caf");
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

void LevelState_Controls::Enter(LevelController* agent)
{
	CCLOG(@"Level: CONTROLS");
	agent->ShowControlsScreen();
	
	if (agent->FSM()->WasInState(LevelState_Settings::Instance()))
	{
		agent->AnimateControlsScreen();
	}
}

void LevelState_Controls::Exit(LevelController* agent)
{
	agent->HideControlsScreen();
}

bool LevelState_Controls::OnMessage(LevelController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Back:		// to account for Android's back button
				case Btn_Apply:
					Game::Instance()->SaveStats();
					agent->FSM()->ChangeState(LevelState_Settings::Instance());
					break;
					
				case Btn_Reset:
					agent->ResetControls();
					break;
					
				case Btn_UseGestures:
					Game::Instance()->SetUseGestures(!Game::Instance()->UseGestures());
					agent->RefreshControlsScreen();
					break;
					
				default:
					return false;
			}
			
			SoundManager::Instance()->ScheduleEffect("ButtonClicked.caf");
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

void LevelState_LifeLost::Enter(LevelController* agent)
{
	CCLOG(@"Level: LIFE LOST");
	agent->ShowLifeLostScreen();
	
	if (agent->FSM()->WasInState(LevelState_Normal::Instance()))
	{
		agent->AnimateLifeLostScreen();
	}
}

void LevelState_LifeLost::Execute(LevelController* agent)
{
	if (!agent->Paused()) agent->UpdateAll();
}

void LevelState_LifeLost::Exit(LevelController* agent)
{
}

bool LevelState_LifeLost::OnMessage(LevelController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_PauseGame:
		{
			agent->PauseGameObjects();
			return true;
		}
			
		case Msg_ResumeGame:
		{
			agent->ResumeGameObjects();
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

void LevelState_LevelComplete::Enter(LevelController* agent)
{
	CCLOG(@"Level: LEVEL COMPLETE");
	agent->PauseGameObjects();
	
	// ---
	
	GameData& gameData = Game::Instance()->Data();
	WorldData& currWorld = gameData.World(agent->WorldId());
	LevelData& currLevel = currWorld.Level(agent->LevelId());
	
	currLevel.SetCompleted(true);
	
	// Check if the score improved.
	agent->CalculateNumStarsCollected();
	if (currLevel.NumStarsCollected() < agent->NumStarsCollected())
		currLevel.SetNumStarsCollected(agent->NumStarsCollected());
	
	// ---
	
	// Report Game Center score.
	
	GCManager::Instance()->ReportScore("eu.pointynose.lethallance.totalscore", gameData.TotalScore());
	
	// Report Game Center achievements if necessary.
	
	std::string achievementIdPrefix = "eu.pointynose.lethallance.world";
	
	if (currWorld.CompletedAllLevels())
	{
		std::ostringstream oss;
		oss << achievementIdPrefix << std::setfill('0') << std::setw(3) << agent->WorldId() + 1;
		std::string achievementId = oss.str();
		GCManager::Instance()->ReportAchievement(achievementId, 100);
	}
	
	if (currWorld.CollectedAllStars())
	{
		int allStarsOffset = 20;
		std::ostringstream oss;
		oss << achievementIdPrefix << std::setfill('0') << std::setw(3) << allStarsOffset + agent->WorldId() + 1;
		std::string achievementId = oss.str();
		GCManager::Instance()->ReportAchievement(achievementId, 100);
	}
	
	// ---
	
	if (agent->NextWorldId() == -1 && agent->NextLevelId() == -1)
	{
		// Finished the entire game, but don't do anything about it here.
		// Everything is handled inside LevelCompleteLayer.
	}
	else
	{
		// Unlock next level (and world, if needed).
		WorldData& nextWorld = gameData.World(agent->NextWorldId());
		LevelData& nextLevel = nextWorld.Level(agent->NextLevelId());
		
		gameData.UnlockAvailableWorlds();
		if (nextLevel.Locked()) nextLevel.SetLocked(false);
	}
	
	agent->ShowLevelCompleteScreen();
	
	Game::Instance()->SaveStats();
}

void LevelState_LevelComplete::Exit(LevelController* agent)
{
}

bool LevelState_LevelComplete::OnMessage(LevelController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Advance:
					if (!Game::Instance()->Data().World(agent->NextWorldId()).Locked())
					{
						if (agent->WorldId() == agent->NextWorldId())
						{
							// Same world, so loading assets not required.
							Game::Instance()->GoToLevel(agent->NextWorldId(), agent->NextLevelId());
						}
						else
						{
							// Different world, we need to load assets first.
							Game::Instance()->GoToLoading(Scene_Level, agent->NextWorldId(), agent->NextLevelId());
						}
					}
					else
					{
						// World is locked, go back to world selection.
						Game::Instance()->GoToLoading(Scene_LevelSelection, agent->NextWorldId(), -1);
					}
					break;
					
				case Btn_WorldCompleted:
					agent->ShowWorldCompletedScreen();
					break;
					
				case Btn_GameCompleted:
					agent->ShowGameCompleteScreen();
					break;
					
				case Btn_Facebook:
					agent->PostFacebookMessage();
					break;
					
				case Btn_Twitter:
					agent->PostTweet();
					break;
					
				case Btn_Leaderboards:
					agent->ShowLeaderboards();
					break;
					
				case Btn_Achievements:
					agent->ShowAchievements();
					break;
					
				default:
					return false;
			}
			
			SoundManager::Instance()->ScheduleEffect("ButtonClicked.caf");
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
