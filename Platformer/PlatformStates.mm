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

#import "PlatformStates.h"
#import "Platform.h"

// -------------------------------------------------------------------------------------

template<> State<Platform>* CommonState_Init<Platform>::mNextState = PlatformState_Inactive::Instance();

// -------------------------------------------------------------------------------------

void PlatformState_Global::Execute(Platform* agent)
{
}

bool PlatformState_Global::OnMessage(Platform* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_PreSolve:
		{
			agent->PreSolve(static_cast<CollisionInfo*>(telegram.ExtraInfo));
			return true;
		}
			
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
		
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void PlatformState_Inactive::Enter(Platform* agent)
{
}

void PlatformState_Inactive::Execute(Platform* agent)
{
	// This gets executed if Platform was set as active in level editor.
	if (!agent->Inactive())
		agent->FSM()->ChangeState(PlatformState_Moving::Instance());
}

bool PlatformState_Inactive::OnMessage(Platform* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_Activated:
		{
			agent->FSM()->ChangeState(PlatformState_Moving::Instance());
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

void PlatformState_Moving::Enter(Platform* agent)
{
	CCLOG(@"Platform: MOVING");
}

void PlatformState_Moving::Execute(Platform* agent)
{
	agent->Move();
	
	if ((agent->PhyBody()->GetPosition() - agent->NextWayPoint()).LengthSquared() <= 1e-6)
	{
		agent->FSM()->ChangeState(PlatformState_Stop::Instance());
	}
}

// -------------------------------------------------------------------------------------

void PlatformState_Stop::Enter(Platform* agent)
{
	CCLOG(@"Platform: STOP");
	agent->StopMoving();
}

void PlatformState_Stop::Execute(Platform* agent)
{
	agent->Idle();
	
	if (agent->IdleTime() >= agent->MaxIdleTime())
	{
		agent->SwitchToNextWayPoint();
		agent->FSM()->ChangeState(PlatformState_Moving::Instance());
	}
}

void PlatformState_Stop::Exit(Platform* agent)
{
}

// -------------------------------------------------------------------------------------
