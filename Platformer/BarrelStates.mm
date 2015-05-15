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

#import "BarrelStates.h"
#import "Barrel.h"

// -------------------------------------------------------------------------------------

template<> State<Barrel>* CommonState_Init<Barrel>::mNextState = BarrelState_Normal::Instance();

// -------------------------------------------------------------------------------------

void BarrelState_Global::Execute(Barrel* agent)
{
	b2Vec2 vel = agent->PhyBody()->GetLinearVelocity();
	
	float limitVelRight = 3;
	float limitVelLeft = -limitVelRight;
	
	// Check whether all the velocities are within their limits.
	if (vel.x > limitVelRight) ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(limitVelRight, vel.y));
	else if (vel.x < limitVelLeft) ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(limitVelLeft, vel.y));
}

// -------------------------------------------------------------------------------------

void BarrelState_Normal::Enter(Barrel* agent)
{
	CCLOG(@"Barrel: NORMAL");
}

void BarrelState_Normal::Execute(Barrel* agent)
{
}

bool BarrelState_Normal::OnMessage(Barrel* agent, const Telegram& telegram)
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
			
		case Msg_Activated:
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		{
			agent->FSM()->ChangeState(BarrelState_Explode::Instance());
			return true;
		}
			
		case Msg_HitByBarrelExplosion:
		{
			agent->FSM()->ChangeState(BarrelState_ExplodeWithDelay::Instance());
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

void BarrelState_ExplodeWithDelay::Enter(Barrel* agent)
{
	CCLOG(@"Barrel: EXPLODE WITH DELAY");
	agent->StartCounting();
}

void BarrelState_ExplodeWithDelay::Execute(Barrel* agent)
{
	agent->UpdateTimeSinceStartedCounting();
	
	if (agent->TimeSinceStartedCounting() > 0.15)
	{
		agent->FSM()->ChangeState(BarrelState_Explode::Instance());
	}
}

// -------------------------------------------------------------------------------------

void BarrelState_Explode::Enter(Barrel* agent)
{
	CCLOG(@"Barrel: EXPLODE");
	agent->Explode();
}

void BarrelState_Explode::Execute(Barrel* agent)
{
	agent->PhyBody()->SetActive(false);
	agent->SetDestroyed(true);
}

// -------------------------------------------------------------------------------------
