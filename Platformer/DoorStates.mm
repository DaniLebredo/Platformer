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

#import "DoorStates.h"
#import "Door.h"

// -------------------------------------------------------------------------------------

template<> State<Door>* CommonState_Init<Door>::mNextState = DoorState_Normal::Instance();

// -------------------------------------------------------------------------------------

void DoorState_Global::Execute(Door* agent)
{
}

bool DoorState_Global::OnMessage(Door* agent, const Telegram& telegram)
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

void DoorState_Normal::Enter(Door* agent)
{
	CCLOG(@"Door: NORMAL");
}

void DoorState_Normal::Execute(Door* agent)
{
	agent->ProcessContacts();
}

bool DoorState_Normal::OnMessage(Door* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOnScreen:
		{
			agent->OnWentOnScreen();
			return true;
		}
		
		case Msg_WentOffScreen:
		{
			agent->OnWentOffScreen();
			return true;
		}
		
		case Msg_Activated:
		{
			agent->FSM()->ChangeState(DoorState_Opened::Instance());
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

void DoorState_Opened::Enter(Door* agent)
{
	CCLOG(@"Door: OPENED");
	agent->Open();
}

void DoorState_Opened::Execute(Door* agent)
{
	if (agent->IsActionDone("Open"))
	{
		agent->SetDestroyed(true);
	}
}

// -------------------------------------------------------------------------------------
