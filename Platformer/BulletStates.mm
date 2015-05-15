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

#import "BulletStates.h"
#import "Bullet.h"

// -------------------------------------------------------------------------------------

template<> State<Bullet>* CommonState_Init<Bullet>::mNextState = BulletState_Flying::Instance();

// -------------------------------------------------------------------------------------

void BulletState_Global::Execute(Bullet* agent)
{
	agent->ProcessContacts();
}

bool BulletState_Global::OnMessage(Bullet* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			agent->SetDestroyed(true);
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

void BulletState_Flying::Enter(Bullet* agent)
{
	CCLOG(@"Bullet: FLYING");
	agent->StartAction("Fly");
}

void BulletState_Flying::Execute(Bullet* agent)
{
	agent->Fly();
}

void BulletState_Flying::Exit(Bullet* agent)
{
	agent->StopAction("Fly");
}

bool BulletState_Flying::OnMessage(Bullet* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_PreSolve:
		{
			agent->PreSolve(static_cast<CollisionInfo*>(telegram.ExtraInfo));
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

void BulletState_HitSomething::Enter(Bullet* agent)
{
	CCLOG(@"Bullet: HIT SOMETHING");
	agent->StopFlying();
}

void BulletState_HitSomething::Execute(Bullet* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Hit"))
	{
		agent->SetDestroyed(true);
	}
}

// -------------------------------------------------------------------------------------
