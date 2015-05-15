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

#import "FlyerStates.h"
#import "Flyer.h"

// -------------------------------------------------------------------------------------

template<> State<Flyer>* CommonState_Init<Flyer>::mNextState = FlyerState_Fly::Instance();

// -------------------------------------------------------------------------------------

void FlyerState_Global::Execute(Flyer* agent)
{
	agent->ProcessContacts();
	
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
	{
		agent->SetDestroyed(true);
	}
	else
	{
		if (!agent->FSM()->IsInState(FlyerState_Dead::Instance()))
		{
			if (agent->NumDeadlyContacts() > 0)
			{
				agent->FSM()->ChangeState(FlyerState_Dead::Instance());
			}
		}
	}
}

bool FlyerState_Global::OnMessage(Flyer* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(FlyerState_Dead::Instance()) &&
				!agent->FSM()->IsInState(CommonState_OffScreen<Flyer>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<Flyer>::Instance());
			}
			return true;
		}

		case Msg_StompedByPlayer:
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		case Msg_BeginCollisionWithConcreteSlab:
		{
			if (!agent->FSM()->IsInState(FlyerState_Dead::Instance()))
			{
				agent->FSM()->ChangeState(FlyerState_Dead::Instance());
				return true;
			}
		}
			break;
			
		default:
		{
			return false;
		}
			break;
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void FlyerState_Fly::Enter(Flyer* agent)
{
	CCLOG(@"FLYER: FLY");
	agent->StartAction("Fly");
}

void FlyerState_Fly::Execute(Flyer* agent)
{
	agent->Fly();
}

void FlyerState_Fly::Exit(Flyer* agent)
{
	agent->StopAction("Fly");
}

// -------------------------------------------------------------------------------------

void FlyerState_Dead::Enter(Flyer* agent)
{
	agent->Die();
}

void FlyerState_Dead::Execute(Flyer* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool FlyerState_Dead::OnMessage(Flyer* agent, const Telegram& telegram)
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
