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

#import "FatBoyStates.h"
#import "FatBoy.h"

// -------------------------------------------------------------------------------------

template<> State<FatBoy>* CommonState_Init<FatBoy>::mNextState = FatBoyState_Walk::Instance();

// -------------------------------------------------------------------------------------

void FatBoyState_Global::Execute(FatBoy* agent)
{
	agent->ProcessContacts();
	
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
	{
		agent->SetDestroyed(true);
	}
	else
	{
		if (!agent->FSM()->IsInState(FatBoyState_Dead::Instance()) &&
			!agent->FSM()->IsInState(FatBoyState_Drowned::Instance()))
		{
			if (agent->NumDeadlyContacts() > 0)
			{
				agent->FSM()->ChangeState(FatBoyState_Dead::Instance());
			}
		}
	}
}

bool FatBoyState_Global::OnMessage(FatBoy* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(FatBoyState_Dead::Instance()) &&
				!agent->FSM()->IsInState(FatBoyState_Drowned::Instance()) &&
				!agent->FSM()->IsInState(CommonState_OffScreen<FatBoy>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<FatBoy>::Instance());
			}
			return true;
		}
			
		case Msg_StompedByPlayer:
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		case Msg_BeginCollisionWithConcreteSlab:
		{
			if (!agent->FSM()->IsInState(FatBoyState_Dead::Instance()) &&
				!agent->FSM()->IsInState(FatBoyState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(FatBoyState_Dead::Instance());
			}
			return true;
		}
			
		case Msg_BeginCollisionWithWater:
		{
			if (!agent->FSM()->IsInState(FatBoyState_Dead::Instance()) &&
				!agent->FSM()->IsInState(FatBoyState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(FatBoyState_Drowned::Instance());
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

void FatBoyState_Walk::Enter(FatBoy* agent)
{
	CCLOG(@"FATBOY: WALK");
	agent->ResetTimeSinceLastScan();
	agent->StartAction("Walk");
}

void FatBoyState_Walk::Execute(FatBoy* agent)
{
	agent->Walk();
	
	agent->UpdateTimeSinceLastScan();
	
	if (agent->TimeSinceLastScan() >= 1)
	{
		agent->ResetTimeSinceLastScan();
		
		if (agent->ScanForPlayer())
		{
			agent->FSM()->ChangeState(FatBoyState_Fire::Instance());
		}
	}
}

void FatBoyState_Walk::Exit(FatBoy* agent)
{
	agent->StopAction("Walk");
}

// -------------------------------------------------------------------------------------

void FatBoyState_Fire::Enter(FatBoy* agent)
{
	CCLOG(@"FATBOY: FIRE");
	agent->StopWalking();
	agent->ResetShotCounter();
	agent->StartAction("Attack");
}

void FatBoyState_Fire::Execute(FatBoy* agent)
{
	if (agent->IsActionDone("Attack"))
	{
		if (agent->NumShotsFired() < 3)
		{
			agent->StopAction("Attack");
			
			if (agent->NumShotsFired() < 2)
				agent->StartAction("Attack");
			
			agent->Fire();
		}
		else if (agent->TimeSinceLastShot() >= 0.6)
		{
			agent->FSM()->ChangeState(FatBoyState_Walk::Instance());
		}
	}
}

void FatBoyState_Fire::Exit(FatBoy* agent)
{
	agent->StopAction("Attack");
}

// -------------------------------------------------------------------------------------

void FatBoyState_Dead::Enter(FatBoy* agent)
{
	agent->Die();
}

void FatBoyState_Dead::Execute(FatBoy* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool FatBoyState_Dead::OnMessage(FatBoy* agent, const Telegram& telegram)
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

void FatBoyState_Drowned::Enter(FatBoy* agent)
{
	CCLOG(@"FatBoy: DROWNED");
	agent->Drown();
}

void FatBoyState_Drowned::Execute(FatBoy* agent)
{
	agent->Sink();
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool FatBoyState_Drowned::OnMessage(FatBoy* agent, const Telegram& telegram)
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
