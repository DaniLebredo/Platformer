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

#import "RunningManStates.h"
#import "RunningMan.h"

// -------------------------------------------------------------------------------------

template<> State<RunningMan>* CommonState_Init<RunningMan>::mNextState = RunningManState_Walk::Instance();

// -------------------------------------------------------------------------------------

void RunningManState_Global::Execute(RunningMan* agent)
{
	agent->ProcessContacts();
	
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
	{
		agent->SetDestroyed(true);
	}
	else
	{
		if (!agent->FSM()->IsInState(RunningManState_Dead::Instance()) &&
			!agent->FSM()->IsInState(RunningManState_Drowned::Instance()))
		{
			if (agent->NumDeadlyContacts() > 0)
			{
				agent->FSM()->ChangeState(RunningManState_Dead::Instance());
			}
		}
	}
}

bool RunningManState_Global::OnMessage(RunningMan* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(RunningManState_Dead::Instance()) &&
				!agent->FSM()->IsInState(RunningManState_Drowned::Instance()) &&
				!agent->FSM()->IsInState(CommonState_OffScreen<RunningMan>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<RunningMan>::Instance());
			}
			return true;
		}
			
		case Msg_StompedByPlayer:
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		case Msg_BeginCollisionWithConcreteSlab:
		{
			if (!agent->FSM()->IsInState(RunningManState_Dead::Instance()) &&
				!agent->FSM()->IsInState(RunningManState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(RunningManState_Dead::Instance());
			}
			return true;
		}
			
		case Msg_BeginCollisionWithWater:
		{
			if (!agent->FSM()->IsInState(RunningManState_Dead::Instance()) &&
				!agent->FSM()->IsInState(RunningManState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(RunningManState_Drowned::Instance());
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

void RunningManState_Walk::Enter(RunningMan* agent)
{
	CCLOG(@"RUNNINGMAN: WALK");
	agent->ResetTimeSinceLastScan();
	agent->StartAction("Walk");
}

void RunningManState_Walk::Execute(RunningMan* agent)
{
	agent->UpdateTimeSinceLastScan();
	agent->Walk();
	
	if (agent->TimeSinceLastScan() >= 1)
	{
		agent->ResetTimeSinceLastScan();
		
		if (agent->ScanForPlayer())
		{
			agent->FSM()->ChangeState(RunningManState_Fire::Instance());
		}
	}
}

void RunningManState_Walk::Exit(RunningMan* agent)
{
	agent->StopAction("Walk");
}

// -------------------------------------------------------------------------------------

void RunningManState_Fire::Enter(RunningMan* agent)
{
	CCLOG(@"RUNNINGMAN: FIRE");
	agent->ResetTimeSinceLastShot();
	agent->StartAction("Attack");
}

void RunningManState_Fire::Execute(RunningMan* agent)
{
	agent->UpdateTimeSinceLastShot();
	agent->Fire();
	
	if (agent->TimeSinceLastShot() >= 5)
	{
		agent->ResetTimeSinceLastShot();
		
		if (!agent->ScanForPlayer())
		{
			agent->FSM()->ChangeState(RunningManState_Walk::Instance());
		}
	}
}

void RunningManState_Fire::Exit(RunningMan* agent)
{
	agent->StopAction("Attack");
}

// -------------------------------------------------------------------------------------

void RunningManState_Dead::Enter(RunningMan* agent)
{
	agent->Die();
}

void RunningManState_Dead::Execute(RunningMan* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool RunningManState_Dead::OnMessage(RunningMan* agent, const Telegram& telegram)
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

void RunningManState_Drowned::Enter(RunningMan* agent)
{
	CCLOG(@"RunningMan: DROWNED");
	agent->Drown();
}

void RunningManState_Drowned::Execute(RunningMan* agent)
{
	agent->Sink();
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool RunningManState_Drowned::OnMessage(RunningMan* agent, const Telegram& telegram)
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
