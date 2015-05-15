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

#import "PlayerGravityStates.h"
#import "PlayerGravity.h"

// -------------------------------------------------------------------------------------

void PlayerGravityState_Global::Execute(PlayerGravity* agent)
{
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
	{
		if (!agent->FSM()->IsInState(PlayerGravityState_Done::Instance()))
			agent->FSM()->ChangeState(PlayerGravityState_Done::Instance());
	}
	else
	{
		if (!agent->FSM()->IsInState(PlayerGravityState_Dead::Instance()) &&
			!agent->FSM()->IsInState(PlayerGravityState_Done::Instance()))
		{
			agent->Walk();
		}
	}
}

bool PlayerGravityState_Global::OnMessage(PlayerGravity* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_BeginContact:
		{
			agent->BeginContact(static_cast<CollisionInfo*>(telegram.ExtraInfo));
			return true;
		}
			
		case Msg_EndContact:
		{
			agent->EndContact(static_cast<CollisionInfo*>(telegram.ExtraInfo));
			return true;
		}
			
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		{
			if (!agent->FSM()->IsInState(PlayerGravityState_Dead::Instance()) &&
				!agent->FSM()->IsInState(PlayerGravityState_Done::Instance()))
			{
				agent->GotHit();
			}
			
			return true;
		}
			
		case Msg_ZeroHealth:
		{
			if (!agent->FSM()->IsInState(PlayerGravityState_Dead::Instance()) &&
				!agent->FSM()->IsInState(PlayerGravityState_Done::Instance()))
			{
				agent->FSM()->ChangeState(PlayerGravityState_Dead::Instance());
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

void PlayerGravityState_OnTheFloor::Enter(PlayerGravity* agent)
{
	CCLOG(@"PLAYER GRAVITY: ON THE FLOOR");
	agent->StartWalkAnimation();
}

void PlayerGravityState_OnTheFloor::Execute(PlayerGravity* agent)
{
	if (agent->NumFootContacts() == 0)
		agent->FSM()->ChangeState(PlayerGravityState_InTheAir::Instance());
}

void PlayerGravityState_OnTheFloor::Exit(PlayerGravity* agent)
{
	agent->StopWalkAnimation();
}

// -------------------------------------------------------------------------------------

void PlayerGravityState_InTheAir::Enter(PlayerGravity* agent)
{
	CCLOG(@"PLAYER GRAVITY: IN THE AIR");
	agent->StartFallAnimation();
}

void PlayerGravityState_InTheAir::Execute(PlayerGravity* agent)
{
	if (agent->NumFootContacts() > 0)
		agent->FSM()->ChangeState(PlayerGravityState_OnTheFloor::Instance());
}

// -------------------------------------------------------------------------------------

void PlayerGravityState_Dead::Enter(PlayerGravity* agent)
{
	CCLOG(@"PLAYER GRAVITY: DEAD");
	agent->Die();
}

void PlayerGravityState_Dead::Execute(PlayerGravity* agent)
{
	ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(0, 10));
	agent->FSM()->ChangeState(PlayerGravityState_Done::Instance());
}

// -------------------------------------------------------------------------------------

void PlayerGravityState_Done::Enter(PlayerGravity* agent)
{
	CCLOG(@"PLAYER GRAVITY: DONE");
	agent->Done();
}

void PlayerGravityState_Done::Execute(PlayerGravity* agent)
{
	ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(0, agent->PhyBody()->GetLinearVelocity().y));
}

// -------------------------------------------------------------------------------------
