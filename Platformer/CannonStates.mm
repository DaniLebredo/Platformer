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

#import "CannonStates.h"
#import "Cannon.h"

// -------------------------------------------------------------------------------------

template<> State<Cannon>* CommonState_Init<Cannon>::mNextState = CannonState_Wait::Instance();

// -------------------------------------------------------------------------------------

void CannonState_Global::Execute(Cannon* agent)
{
	agent->UpdateTimeSinceLastShot();
	
	if (agent->TimeSinceLastShot() >= agent->Period())
	{
		agent->ResetTimeSinceLastShot();
		agent->Reload();
	}
}

bool CannonState_Global::OnMessage(Cannon* agent, const Telegram& telegram)
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

void CannonState_Wait::Enter(Cannon* agent)
{
	CCLOG(@"Cannon: WAIT");
	CCSprite* sprite = (CCSprite*)agent->Node();
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Cannon0"];
}

void CannonState_Wait::Execute(Cannon* agent)
{
}

bool CannonState_Wait::OnMessage(Cannon* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		// Cannon can go offscreen only when it's in this state. Otherwise, firing
		// cannon balls could get out of sync.
		case Msg_WentOffScreen:
		{
			agent->FSM()->ChangeState(CommonState_OffScreen<Cannon>::Instance());
			return true;
		}
			
		case Msg_Activated:
		{
			agent->FSM()->ChangeState(CannonState_Reload::Instance());
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

void CannonState_Reload::Enter(Cannon* agent)
{
	CCLOG(@"Cannon: RELOAD");
	agent->StartAction("Default");
}

void CannonState_Reload::Execute(Cannon* agent)
{
	if (agent->IsActionDone("Default"))
	{
		agent->FSM()->ChangeState(CannonState_Fire::Instance());
	}
}

void CannonState_Reload::Exit(Cannon* agent)
{
	agent->StopAction("Default");
}

// -------------------------------------------------------------------------------------

void CannonState_Fire::Enter(Cannon* agent)
{
	CCLOG(@"Cannon: FIRE");
	agent->Fire();
}

void CannonState_Fire::Execute(Cannon* agent)
{
	agent->FSM()->ChangeState(CannonState_Wait::Instance());
}

// -------------------------------------------------------------------------------------
