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

#import "FishStates.h"
#import "Fish.h"

// -------------------------------------------------------------------------------------

template<> State<Fish>* CommonState_Init<Fish>::mNextState = FishState_Swim::Instance();

// -------------------------------------------------------------------------------------

void FishState_Global::Execute(Fish* agent)
{
	agent->ProcessContacts();
	
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
	{
		agent->SetDestroyed(true);
	}
	else
	{
		if (!agent->FSM()->IsInState(FishState_Dead::Instance()))
		{
			if (agent->NumDeadlyContacts() > 0)
			{
				agent->FSM()->ChangeState(FishState_Dead::Instance());
			}
			else
			{
				agent->UpdateTimeSinceLastJump();
				
				if (agent->TimeSinceLastJump() >= 4)
				{
					agent->ResetTimeSinceLastJump();
					agent->TryToJump();
				}
			}
		}
	}
}

bool FishState_Global::OnMessage(Fish* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(FishState_Dead::Instance()) &&
				!agent->FSM()->IsInState(CommonState_OffScreen<Fish>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<Fish>::Instance());
			}
			return true;
		}
			
		case Msg_StompedByPlayer:
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		case Msg_BeginCollisionWithConcreteSlab:
		{
			if (!agent->FSM()->IsInState(FishState_Dead::Instance()))
			{
				agent->FSM()->ChangeState(FishState_Dead::Instance());
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

void FishState_Swim::Enter(Fish* agent)
{
	CCLOG(@"Fish: WALK");
	agent->StartAction("Swim");
	agent->Node().scaleX = 1;
	agent->Node().scaleY = 1;
}

void FishState_Swim::Execute(Fish* agent)
{
	agent->GoToInitialPosition();
}

void FishState_Swim::Exit(Fish* agent)
{
	agent->StopAction("Swim");
}

bool FishState_Swim::OnMessage(Fish* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_Activated:
		{
			agent->Jump();
			agent->FSM()->ChangeState(FishState_Fly::Instance());
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

void FishState_Fly::Enter(Fish* agent)
{
	CCLOG(@"Fish: WALK");
	agent->StartAction("Bite");
	agent->Node().scaleX = -1;
}

void FishState_Fly::Execute(Fish* agent)
{
	if (agent->PhyBody()->GetLinearVelocity().y < 0)
	{
		agent->Fall();
		agent->Node().scaleY = -1;
	}
	
	if (agent->ShouldGoToInitialPosition())
		agent->GoToInitialPosition();
	
	if (agent->IsAtInitialPosition())
		agent->FSM()->ChangeState(FishState_Swim::Instance());
}

void FishState_Fly::Exit(Fish* agent)
{
	agent->StopAction("Bite");
}

// -------------------------------------------------------------------------------------

void FishState_Dead::Enter(Fish* agent)
{
	agent->Node().scaleX = -1;
	agent->Die();
}

void FishState_Dead::Execute(Fish* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

// -------------------------------------------------------------------------------------
