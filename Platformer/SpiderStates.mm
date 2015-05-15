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

#import "SpiderStates.h"
#import "Spider.h"

// -------------------------------------------------------------------------------------

template<> State<Spider>* CommonState_Init<Spider>::mNextState = SpiderState_Walk::Instance();

// -------------------------------------------------------------------------------------

void SpiderState_Global::Execute(Spider* agent)
{
	agent->ProcessContacts();
	
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
	{
		agent->SetDestroyed(true);
	}
	else
	{
		agent->LimitFallingVelocity();
		
		if (!agent->FSM()->IsInState(SpiderState_Dead::Instance()) &&
			!agent->FSM()->IsInState(SpiderState_Drowned::Instance()))
		{
			if (agent->NumDeadlyContacts() > 0)
			{
				agent->FSM()->ChangeState(SpiderState_Dead::Instance());
			}
		}
	}
}

bool SpiderState_Global::OnMessage(Spider* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(SpiderState_Dead::Instance()) &&
				!agent->FSM()->IsInState(SpiderState_Drowned::Instance()) &&
				!agent->FSM()->IsInState(CommonState_OffScreen<Spider>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<Spider>::Instance());
			}
			return true;
		}
			
		case Msg_StompedByPlayer:
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		case Msg_BeginCollisionWithConcreteSlab:
		{
			if (!agent->FSM()->IsInState(SpiderState_Dead::Instance()) &&
				!agent->FSM()->IsInState(SpiderState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(SpiderState_Dead::Instance());
			}
			return true;
		}
			
		case Msg_BeginCollisionWithWater:
		{
			if (!agent->FSM()->IsInState(SpiderState_Dead::Instance()) &&
				!agent->FSM()->IsInState(SpiderState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(SpiderState_Drowned::Instance());
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

void SpiderState_Walk::Enter(Spider* agent)
{
	CCLOG(@"Spider: WALK");
	agent->StartAction("Walk");
}

void SpiderState_Walk::Execute(Spider* agent)
{
	agent->Walk();
	
	if (agent->NumPlayerContacts() > 0)
	{
		agent->FSM()->ChangeState(SpiderState_Attack::Instance());
	}
}

void SpiderState_Walk::Exit(Spider* agent)
{
	agent->StopAction("Walk");
}

// -------------------------------------------------------------------------------------

void SpiderState_Attack::Enter(Spider* agent)
{
	CCLOG(@"Spider: ATTACK");
	agent->StartAction("Attack");
	agent->LookAtPlayer();
	
	ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(0, agent->PhyBody()->GetLinearVelocity().y));
}

void SpiderState_Attack::Execute(Spider* agent)
{
	if (agent->IsActionDone("Attack"))
	{
		agent->LookAtPlayer();
		
		if (agent->NumPlayerContacts() == 0)
		{
			agent->FSM()->ChangeState(SpiderState_Walk::Instance());
		}
		else
		{
			// Restart attack action.
			agent->StopAction("Attack");
			agent->StartAction("Attack");
		}
	}
}

void SpiderState_Attack::Exit(Spider* agent)
{
	agent->StopAction("Attack");
}

// -------------------------------------------------------------------------------------

void SpiderState_Dead::Enter(Spider* agent)
{
	CCLOG(@"Spider: DEAD");
	agent->Die();
}

void SpiderState_Dead::Execute(Spider* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool SpiderState_Dead::OnMessage(Spider* agent, const Telegram& telegram)
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

void SpiderState_Drowned::Enter(Spider* agent)
{
	CCLOG(@"Spider: DROWNED");
	agent->Drown();
}

void SpiderState_Drowned::Execute(Spider* agent)
{
	agent->Sink();
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool SpiderState_Drowned::OnMessage(Spider* agent, const Telegram& telegram)
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
