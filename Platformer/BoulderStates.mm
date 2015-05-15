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

#import "BoulderStates.h"
#import "Boulder.h"

// -------------------------------------------------------------------------------------

template<> State<Boulder>* CommonState_Init<Boulder>::mNextState = BoulderState_Roll::Instance();

// -------------------------------------------------------------------------------------

void BoulderState_Global::Execute(Boulder* agent)
{
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
		agent->SetDestroyed(true);
}

bool BoulderState_Global::OnMessage(Boulder* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_PreSolve:
		{
			agent->PreSolve(static_cast<CollisionInfo*>(telegram.ExtraInfo));
			return true;
		}
			
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(CommonState_OffScreen<Boulder>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<Boulder>::Instance());
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

void BoulderState_Roll::Enter(Boulder* agent)
{
	CCLOG(@"BOULDER: ROLL");
	agent->StartAction("Roll");
}

void BoulderState_Roll::Execute(Boulder* agent)
{
	agent->ProcessContacts();
	agent->Roll();
}

void BoulderState_Roll::Exit(Boulder* agent)
{
	agent->StopAction("Roll");
}

bool BoulderState_Roll::OnMessage(Boulder* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_BoulderStopped:
		{
			agent->FSM()->ChangeState(BoulderState_Stopped::Instance());
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

void BoulderState_Stopped::Enter(Boulder* agent)
{
	agent->Stop();
}

void BoulderState_Stopped::Execute(Boulder* agent)
{
	agent->Rest();
}

bool BoulderState_Stopped::OnMessage(Boulder* agent, const Telegram& telegram)
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
