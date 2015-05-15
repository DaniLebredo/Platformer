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

#import "StomperStates.h"
#import "Stomper.h"

// -------------------------------------------------------------------------------------

template<> State<Stomper>* CommonState_Init<Stomper>::mNextState = StomperState_FallingDown::Instance();

// -------------------------------------------------------------------------------------

void StomperState_Global::Execute(Stomper* agent)
{
}

bool StomperState_Global::OnMessage(Stomper* agent, const Telegram& telegram)
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
			
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void StomperState_FallingDown::Enter(Stomper* agent)
{
	agent->Joint()->SetMotorSpeed(15);
}

void StomperState_FallingDown::Execute(Stomper* agent)
{
	if (fabs(agent->Joint()->GetJointTranslation() - agent->Joint()->GetUpperLimit()) < 0.05)
		agent->FSM()->ChangeState(StomperState_Waiting::Instance());
}

// -------------------------------------------------------------------------------------

void StomperState_RisingUp::Enter(Stomper* agent)
{
	agent->Joint()->SetMotorSpeed(-1);
}

void StomperState_RisingUp::Execute(Stomper* agent)
{
	if (fabs(agent->Joint()->GetJointTranslation() - agent->Joint()->GetLowerLimit()) < 0.05)
		agent->FSM()->ChangeState(StomperState_Waiting::Instance());
}

// -------------------------------------------------------------------------------------

void StomperState_Waiting::Enter(Stomper* agent)
{
	agent->ResetWaitTimer();
}

void StomperState_Waiting::Execute(Stomper* agent)
{
	agent->UpdateWaitTimer();
	
	if (agent->WaitTimerValue() >= 2)
	{
		if (agent->FSM()->WasInState(StomperState_FallingDown::Instance()))
			agent->FSM()->ChangeState(StomperState_RisingUp::Instance());
		else if (agent->FSM()->WasInState(StomperState_RisingUp::Instance()))
			agent->FSM()->ChangeState(StomperState_FallingDown::Instance());
	}
}

// -------------------------------------------------------------------------------------
