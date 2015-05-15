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

#import "MainMenuStates.h"
#import "MainMenuController.h"
#import "Game.h"
#import "GCManager.h"

// -------------------------------------------------------------------------------------

void MainMenuState_Global::Execute(MainMenuController* agent)
{
	agent->ApplyMoveFocus();
}

bool MainMenuState_Global::OnMessage(MainMenuController* agent, const Telegram& telegram)
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

void MainMenuState_EnterTransition::Enter(MainMenuController* agent)
{
	CCLOG(@"MainMenu: ENTER TRANSITION");
}

bool MainMenuState_EnterTransition::OnMessage(MainMenuController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_SceneEntered:
		{
			agent->FSM()->ChangeState(MainMenuState_Normal::Instance());
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

void MainMenuState_Normal::Enter(MainMenuController* agent)
{
	CCLOG(@"MainMenu: NORMAL");
	agent->ShowSplashScreen();
}

void MainMenuState_Normal::Exit(MainMenuController* agent)
{
	agent->HideSplashScreen();
}

bool MainMenuState_Normal::OnMessage(MainMenuController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Start:
					Game::Instance()->GoToLoading(Scene_LevelSelection, Game::Instance()->WorldId(), -1, Loading_TextMessage, false);
					break;
					
				case Btn_Info:
					agent->FSM()->ChangeState(MainMenuState_Credits::Instance());
					break;
					
				case Btn_Back:		// to account for Android's back button
					agent->FSM()->ChangeState(MainMenuState_Quit::Instance());
					break;
					
				case Btn_Settings:
					agent->FSM()->ChangeState(MainMenuState_Settings::Instance());
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

void MainMenuState_Credits::Enter(MainMenuController* agent)
{
	CCLOG(@"MainMenu: CREDITS");
	agent->ShowCreditsScreen();
	
	if (agent->FSM()->WasInState(MainMenuState_Normal::Instance()))
	{
		agent->AnimateCreditsScreen();
	}
}

void MainMenuState_Credits::Exit(MainMenuController* agent)
{
	agent->HideCreditsScreen();
}

bool MainMenuState_Credits::OnMessage(MainMenuController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Back:
					agent->FSM()->ChangeState(MainMenuState_Normal::Instance());
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

void MainMenuState_Quit::Enter(MainMenuController* agent)
{
	CCLOG(@"MainMenu: QUIT");
	agent->ShowQuitScreen();
	
	if (agent->FSM()->WasInState(MainMenuState_Normal::Instance()))
	{
		agent->AnimateQuitScreen();
	}
}

void MainMenuState_Quit::Exit(MainMenuController* agent)
{
	agent->HideQuitScreen();
}

bool MainMenuState_Quit::OnMessage(MainMenuController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_ExitToOS:
					exit(0);
					break;
					
				case Btn_Back:
					agent->FSM()->ChangeState(MainMenuState_Normal::Instance());
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

void MainMenuState_Settings::Enter(MainMenuController* agent)
{
	CCLOG(@"MainMenu: SETTINGS");
	agent->ShowSettingsScreen();
	
	if (agent->FSM()->WasInState(MainMenuState_Normal::Instance()))
	{
		agent->AnimateSettingsScreen();
	}
}

void MainMenuState_Settings::Exit(MainMenuController* agent)
{
	agent->HideSettingsScreen();
}

bool MainMenuState_Settings::OnMessage(MainMenuController* agent, const Telegram& telegram)
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
					agent->FSM()->ChangeState(MainMenuState_Normal::Instance());
					break;
					
				case Btn_Controls:
					agent->FSM()->ChangeState(MainMenuState_Controls::Instance());
					break;
					
				case Btn_Music:
					Game::Instance()->SetMusicOn(!Game::Instance()->MusicOn());
					agent->RefreshSettingsScreen();
					break;
					
				case Btn_Sound:
					Game::Instance()->SetSoundOn(!Game::Instance()->SoundOn());
					agent->RefreshSettingsScreen();
					break;
					
				case Btn_Language:
					Game::Instance()->Data().SelectNextLanguage();
					agent->RefreshSettingsScreen();
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

void MainMenuState_Controls::Enter(MainMenuController* agent)
{
	CCLOG(@"MainMenu: CONTROLS");
	agent->ShowControlsScreen();
	
	if (agent->FSM()->WasInState(MainMenuState_Settings::Instance()))
	{
		agent->AnimateControlsScreen();
	}
}

void MainMenuState_Controls::Exit(MainMenuController* agent)
{
	agent->HideControlsScreen();
}

bool MainMenuState_Controls::OnMessage(MainMenuController* agent, const Telegram& telegram)
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
					agent->FSM()->ChangeState(MainMenuState_Settings::Instance());
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
