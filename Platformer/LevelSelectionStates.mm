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

#import "LevelSelectionStates.h"
#import "LevelSelectionController.h"

#import "Game.h"
#import "IAPManager.h"

// -------------------------------------------------------------------------------------

void LevelSelectionState_Global::Execute(LevelSelectionController* agent)
{
	agent->ApplyMoveFocus();
}

bool LevelSelectionState_Global::OnMessage(LevelSelectionController* agent, const Telegram& telegram)
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

void LevelSelectionState_EnterTransition::Enter(LevelSelectionController* agent)
{
	CCLOG(@"LevelSelection: ENTER TRANSITION");
}

bool LevelSelectionState_EnterTransition::OnMessage(LevelSelectionController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_SceneEntered:
		{
			agent->FSM()->ChangeState(agent->NextState());
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

void LevelSelectionState_Worlds::Enter(LevelSelectionController* agent)
{
	CCLOG(@"LevelSelection: WORLDS");
	agent->ShowWorldsScreen();
}

void LevelSelectionState_Worlds::Exit(LevelSelectionController* agent)
{
	agent->HideWorldsScreen();
}

bool LevelSelectionState_Worlds::OnMessage(LevelSelectionController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Back:
					Game::Instance()->GoToLoading(Scene_MainMenu, 0, 0, Loading_TextMessage, false);
					break;
					
				case Btn_World:
				{
					int worldId = reinterpret_cast<int>(telegram.ExtraInfo2);
					if (agent->SelectWorld(worldId))
						agent->FSM()->ChangeState(LevelSelectionState_Levels::Instance());
					break;
				}
					
				case Btn_Store:
					agent->FSM()->ChangeState(LevelSelectionState_Store::Instance());
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

void LevelSelectionState_Levels::Enter(LevelSelectionController* agent)
{
	CCLOG(@"LevelSelection: LEVELS");
	if (agent->FSM()->WasInState(LevelSelectionState_Worlds::Instance()))
	{
		agent->ShowLevelsScreen();
		agent->AnimateLevelsScreen();
	}
}

void LevelSelectionState_Levels::Exit(LevelSelectionController* agent)
{
	agent->HideLevelsScreen();
}

bool LevelSelectionState_Levels::OnMessage(LevelSelectionController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Back:
					agent->FSM()->ChangeState(LevelSelectionState_Worlds::Instance());
					break;
					
				case Btn_Level:
				{
					int levelId = reinterpret_cast<int>(telegram.ExtraInfo2);
					if (agent->SelectLevel(levelId))
						agent->GoToSelectedWorldAndLevel();
					break;
				}
					
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

void LevelSelectionState_Store::Enter(LevelSelectionController* agent)
{
	CCLOG(@"LevelSelection: STORE");
	agent->ShowStoreScreen();
	IAPManager::Instance()->ValidateProductIdentifiers(Game::Instance()->Data().ProductRepo().ItemNames());
}

void LevelSelectionState_Store::Exit(LevelSelectionController* agent)
{
	agent->HideStoreScreen();
}

bool LevelSelectionState_Store::OnMessage(LevelSelectionController* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_ButtonClicked:
		{
			ButtonType btnType = static_cast<ButtonType>(reinterpret_cast<int>(telegram.ExtraInfo));
			
			switch (btnType)
			{
				case Btn_Back:
					agent->FSM()->ChangeState(LevelSelectionState_Worlds::Instance());
					break;
					
				case Btn_BuyFullVersion:
					IAPManager::Instance()->BuyFullVersion();
					agent->ShowBusyScreen();
					break;
					
				case Btn_RestorePurchases:
					IAPManager::Instance()->RestorePurchases();
					agent->ShowBusyScreen();
					break;
					
				default:
					return false;
			}
			
			SoundManager::Instance()->ScheduleEffect("ButtonClicked.caf");
			return true;
		}
		
		case Msg_ProductValidationCompleted:
		{
			bool success = static_cast<bool>(reinterpret_cast<int>(telegram.ExtraInfo));
			agent->SetStoreAvailability(success);
			return true;
		}
			
		case Msg_RestoreTransactionsCompleted:
		{
			//bool success = static_cast<bool>(reinterpret_cast<int>(telegram.ExtraInfo));
			agent->HideBusyScreen();
			return true;
		}
			
		case Msg_TransactionCompleted:
		{
			//bool success = static_cast<bool>(reinterpret_cast<int>(telegram.ExtraInfo));
			agent->HideBusyScreen();
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
