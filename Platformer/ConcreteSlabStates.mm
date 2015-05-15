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

#import "ConcreteSlabStates.h"
#import "ConcreteSlab.h"

// -------------------------------------------------------------------------------------

template<> State<ConcreteSlab>* CommonState_Init<ConcreteSlab>::mNextState = ConcreteSlabState_Normal::Instance();

// -------------------------------------------------------------------------------------

void ConcreteSlabState_Global::Execute(ConcreteSlab* agent)
{
	b2Vec2 vel = agent->PhyBody()->GetLinearVelocity();
	
	float limitVelRight = 3;
	float limitVelLeft = -limitVelRight;
	
	// Check whether all the velocities are within their limits.
	if (vel.x > limitVelRight) ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(limitVelRight, vel.y));
	else if (vel.x < limitVelLeft) ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(limitVelLeft, vel.y));
}

bool ConcreteSlabState_Global::OnMessage(ConcreteSlab* agent, const Telegram& telegram)
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
			
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void ConcreteSlabState_Normal::Enter(ConcreteSlab* agent)
{
	CCLOG(@"ConcreteSlab: NORMAL");
}

void ConcreteSlabState_Normal::Execute(ConcreteSlab* agent)
{
}

bool ConcreteSlabState_Normal::OnMessage(ConcreteSlab* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_Activated:
		case Msg_BeginCollisionWithPlayer:
		{
			agent->FSM()->ChangeState(ConcreteSlabState_FallingDown::Instance());
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

void ConcreteSlabState_FallingDown::Enter(ConcreteSlab* agent)
{
	CCLOG(@"ConcreteSlab: FALLING DOWN");
	agent->PhyBody()->SetGravityScale(1);
	ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(0, 0));
	//agent->PhyBody()->SetAwake(true);
}

void ConcreteSlabState_FallingDown::Execute(ConcreteSlab* agent)
{
}

// -------------------------------------------------------------------------------------
