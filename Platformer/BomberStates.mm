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

#import "BomberStates.h"
#import "Bomber.h"

// -------------------------------------------------------------------------------------

void BomberState_Global::Execute(Bomber* agent)
{
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
		agent->SetDestroyed(true);
}

bool BomberState_Global::OnMessage(Bomber* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_HitByBarrelExplosion:
		{
			if (!agent->FSM()->IsInState(BomberState_Dead::Instance()))
			{
				agent->FSM()->ChangeState(BomberState_Dead::Instance());
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

void BomberState_FollowPlayer::Enter(Bomber* agent)
{
	CCLOG(@"BOMBER: WALK");
	agent->StartAction("Fly");
}

void BomberState_FollowPlayer::Execute(Bomber* agent)
{
	agent->FollowPlayer();
	
	if (agent->IsAbovePlayer())
	{
		agent->FSM()->ChangeState(BomberState_Fire::Instance());
	}
}

// -------------------------------------------------------------------------------------

void BomberState_Fire::Enter(Bomber* agent)
{
	CCLOG(@"BOMBER: FIRE");
	agent->StopFollowingPlayer();
	agent->ResetShotCounter();
}

void BomberState_Fire::Execute(Bomber* agent)
{
	if (agent->NumShotsFired() < 3)
	{
		if (agent->TimeSinceLastShot() >= 0.3)
		{
			agent->Fire();
		}
	}
	else
	{
		if (agent->TimeSinceLastShot() >= 1)
		{
			agent->FSM()->ChangeState(BomberState_FollowPlayer::Instance());
		}
	}
}

// -------------------------------------------------------------------------------------

void BomberState_Dead::Enter(Bomber* agent)
{
	agent->StopAction("Fly");
	agent->Die();
}

void BomberState_Dead::Execute(Bomber* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->TimeSinceDied() >= 1.5)
	{
		agent->SetDestroyed(true);
	}
}

// -------------------------------------------------------------------------------------
