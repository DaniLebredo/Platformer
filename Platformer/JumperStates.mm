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

#import "JumperStates.h"
#import "Jumper.h"

// -------------------------------------------------------------------------------------

template<> State<Jumper>* CommonState_Init<Jumper>::mNextState = JumperState_OnTheFloor::Instance();

// -------------------------------------------------------------------------------------

void JumperState_Global::Execute(Jumper* agent)
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
		
		if (!agent->FSM()->IsInState(JumperState_Dead::Instance()) &&
			!agent->FSM()->IsInState(JumperState_Drowned::Instance()))
		{
			if (agent->NumDeadlyContacts() > 0)
			{
				agent->FSM()->ChangeState(JumperState_Dead::Instance());
			}
		}
	}
}

bool JumperState_Global::OnMessage(Jumper* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(JumperState_Dead::Instance()) &&
				!agent->FSM()->IsInState(JumperState_Drowned::Instance()) &&
				!agent->FSM()->IsInState(CommonState_OffScreen<Jumper>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<Jumper>::Instance());
			}
			return true;
		}
			
		case Msg_StompedByPlayer:
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		case Msg_BeginCollisionWithConcreteSlab:
		{
			if (!agent->FSM()->IsInState(JumperState_Dead::Instance()) &&
				!agent->FSM()->IsInState(JumperState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(JumperState_Dead::Instance());
			}
			return true;
		}
			
		case Msg_BeginCollisionWithWater:
		{
			if (!agent->FSM()->IsInState(JumperState_Dead::Instance()) &&
				!agent->FSM()->IsInState(JumperState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(JumperState_Drowned::Instance());
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

void JumperState_OnTheFloor::Enter(Jumper* agent)
{
	CCLOG(@"JUMPER: ON THE FLOOR");
	agent->ResetTimeSinceJumped();
	agent->StartAction("Idle");
}

void JumperState_OnTheFloor::Execute(Jumper* agent)
{
	if (agent->TouchingFloor())
	{
		agent->LookAtPlayer();
		
		agent->UpdateTimeSinceJumped();
		
		if (agent->TimeSinceJumped() >= 1)
		{
			agent->Jump();
			agent->FSM()->ChangeState(JumperState_Jump::Instance());
		}
		else if (agent->NumPlayerContacts() > 0)
		{
			agent->FSM()->ChangeState(JumperState_Attack::Instance());
		}
	}
	else agent->FSM()->ChangeState(JumperState_Jump::Instance());
}

void JumperState_OnTheFloor::Exit(Jumper* agent)
{
	agent->StopAction("Idle");
}

// -------------------------------------------------------------------------------------

void JumperState_Attack::Enter(Jumper* agent)
{
	CCLOG(@"JUMPER: ATTACK");
	agent->StartAction("Attack");
	agent->LookAtPlayer();
}

void JumperState_Attack::Execute(Jumper* agent)
{
	if (agent->IsActionDone("Attack"))
	{
		agent->LookAtPlayer();
		
		if (agent->NumPlayerContacts() == 0)
		{
			agent->FSM()->ChangeState(JumperState_OnTheFloor::Instance());
		}
		else
		{
			// Restart attack action.
			agent->StopAction("Attack");
			agent->StartAction("Attack");
		}
	}
}

void JumperState_Attack::Exit(Jumper* agent)
{
	agent->StopAction("Attack");
}

// -------------------------------------------------------------------------------------

void JumperState_Jump::Enter(Jumper* agent)
{
	CCLOG(@"JUMPER: JUMP");
	CCSprite* sprite = (CCSprite*)agent->Node();
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Rabbit0"];
}

void JumperState_Jump::Execute(Jumper* agent)
{
	b2Vec2 vel = agent->PhyBody()->GetLinearVelocity();
	
	if (agent->TouchingFloor() && vel.y == 0)
	{
		agent->FSM()->ChangeState(JumperState_OnTheFloor::Instance());
	}
	else if (vel.y < 0)
	{
		CCSprite* sprite = (CCSprite*)agent->Node();
		sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Rabbit1"];
	}
}

// -------------------------------------------------------------------------------------

void JumperState_Dead::Enter(Jumper* agent)
{
	agent->Die();
}

void JumperState_Dead::Execute(Jumper* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool JumperState_Dead::OnMessage(Jumper* agent, const Telegram& telegram)
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

void JumperState_Drowned::Enter(Jumper* agent)
{
	CCLOG(@"Jumper: DROWNED");
	agent->Drown();
}

void JumperState_Drowned::Execute(Jumper* agent)
{
	agent->Sink();
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool JumperState_Drowned::OnMessage(Jumper* agent, const Telegram& telegram)
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
