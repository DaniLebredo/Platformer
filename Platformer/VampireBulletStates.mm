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

#import "VampireBulletStates.h"
#import "VampireBullet.h"

// -------------------------------------------------------------------------------------

template<> State<VampireBullet>* CommonState_Init<VampireBullet>::mNextState = VampireBulletState_Flying::Instance();

// -------------------------------------------------------------------------------------

void VampireBulletState_Global::Execute(VampireBullet* agent)
{
	agent->ProcessContacts();
}

bool VampireBulletState_Global::OnMessage(VampireBullet* agent, const Telegram& telegram)
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

void VampireBulletState_Flying::Enter(VampireBullet* agent)
{
	CCLOG(@"VampireBullet: FLYING");
	agent->StartAction("Fly");
}

void VampireBulletState_Flying::Execute(VampireBullet* agent)
{
	agent->Fly();
}

void VampireBulletState_Flying::Exit(VampireBullet* agent)
{
	agent->StopAction("Fly");
}

bool VampireBulletState_Flying::OnMessage(VampireBullet* agent, const Telegram& telegram)
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

void VampireBulletState_HitSomething::Enter(VampireBullet* agent)
{
	CCLOG(@"VampireBullet: HIT SOMETHING");
	agent->StopFlying();
}

void VampireBulletState_HitSomething::Execute(VampireBullet* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Hit"))
	{
		agent->SetDestroyed(true);
	}
}

// -------------------------------------------------------------------------------------
