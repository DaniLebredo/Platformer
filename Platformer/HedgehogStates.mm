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

#import "HedgehogStates.h"
#import "Hedgehog.h"

// -------------------------------------------------------------------------------------

template<> State<Hedgehog>* CommonState_Init<Hedgehog>::mNextState = HedgehogState_Walk::Instance();

// -------------------------------------------------------------------------------------

void HedgehogState_Global::Execute(Hedgehog* agent)
{
	agent->ProcessContacts();
	
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
	{
		agent->SetDestroyed(true);
	}
	else
	{
		if (!agent->FSM()->IsInState(HedgehogState_Dead::Instance()) &&
			!agent->FSM()->IsInState(HedgehogState_Drowned::Instance()))
		{
			if (agent->NumDeadlyContacts() > 0)
			{
				agent->FSM()->ChangeState(HedgehogState_Dead::Instance());
			}
		}
	}
}

bool HedgehogState_Global::OnMessage(Hedgehog* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(HedgehogState_Dead::Instance()) &&
				!agent->FSM()->IsInState(HedgehogState_Drowned::Instance()) &&
				!agent->FSM()->IsInState(CommonState_OffScreen<Hedgehog>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<Hedgehog>::Instance());
			}
			return true;
		}
			
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		{
			if (!agent->FSM()->IsInState(HedgehogState_Dead::Instance()) &&
				!agent->FSM()->IsInState(HedgehogState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(HedgehogState_Dead::Instance());
			}
			return true;
		}
			
		case Msg_BeginCollisionWithWater:
		{
			if (!agent->FSM()->IsInState(HedgehogState_Dead::Instance()) &&
				!agent->FSM()->IsInState(HedgehogState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(HedgehogState_Drowned::Instance());
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

void HedgehogState_Walk::Enter(Hedgehog* agent)
{
	CCLOG(@"HEDGEHOG: WALK");
	agent->StartAction("Walk");
	agent->ResetWalkTime();
}

void HedgehogState_Walk::Execute(Hedgehog* agent)
{
	agent->UpdateWalkTime();
	agent->Walk();
	
	if (agent->WalkTime() > 3)
		agent->FSM()->ChangeState(HedgehogState_Think::Instance());
}

void HedgehogState_Walk::Exit(Hedgehog* agent)
{
	agent->StopAction("Walk");
}

// -------------------------------------------------------------------------------------

void HedgehogState_Think::Enter(Hedgehog* agent)
{
	CCLOG(@"HEDGEHOG: THINK");
	agent->StartAction("Think");
	agent->ResetThinkTime();
}

void HedgehogState_Think::Execute(Hedgehog* agent)
{
	agent->UpdateThinkTime();
	agent->Think();
	
	if (agent->ThinkTime() > 2)
		agent->FSM()->ChangeState(HedgehogState_Walk::Instance());
}

void HedgehogState_Think::Exit(Hedgehog* agent)
{
	agent->StopAction("Think");
}

// -------------------------------------------------------------------------------------

void HedgehogState_Dead::Enter(Hedgehog* agent)
{
	agent->Die();
}

void HedgehogState_Dead::Execute(Hedgehog* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool HedgehogState_Dead::OnMessage(Hedgehog* agent, const Telegram& telegram)
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

void HedgehogState_Drowned::Enter(Hedgehog* agent)
{
	CCLOG(@"Hedgehog: DROWNED");
	agent->Drown();
}

void HedgehogState_Drowned::Execute(Hedgehog* agent)
{
	agent->Sink();
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool HedgehogState_Drowned::OnMessage(Hedgehog* agent, const Telegram& telegram)
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
