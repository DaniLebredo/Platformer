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

#import "EnemyStates.h"
#import "Enemy.h"

// -------------------------------------------------------------------------------------

template<> State<Enemy>* CommonState_Init<Enemy>::mNextState = EnemyState_Walk::Instance();

// -------------------------------------------------------------------------------------

void EnemyState_Global::Execute(Enemy* agent)
{
	agent->ProcessContacts();
	
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
	{
		agent->SetDestroyed(true);
	}
	else
	{
		if (!agent->FSM()->IsInState(EnemyState_Dead::Instance()) &&
			!agent->FSM()->IsInState(EnemyState_Drowned::Instance()))
		{
			if (agent->NumDeadlyContacts() > 0)
			{
				agent->FSM()->ChangeState(EnemyState_Dead::Instance());
			}
		}
	}
}

bool EnemyState_Global::OnMessage(Enemy* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(EnemyState_Dead::Instance()) &&
				!agent->FSM()->IsInState(EnemyState_Drowned::Instance()) &&
				!agent->FSM()->IsInState(CommonState_OffScreen<Enemy>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<Enemy>::Instance());
			}
			return true;
		}
			
		case Msg_StompedByPlayer:
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		case Msg_BeginCollisionWithConcreteSlab:
		{
			if (!agent->FSM()->IsInState(EnemyState_Dead::Instance()) &&
				!agent->FSM()->IsInState(EnemyState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(EnemyState_Dead::Instance());
			}
			return true;
		}
			
		case Msg_BeginCollisionWithWater:
		{
			if (!agent->FSM()->IsInState(EnemyState_Dead::Instance()) &&
				!agent->FSM()->IsInState(EnemyState_Drowned::Instance()))
			{
				agent->FSM()->ChangeState(EnemyState_Drowned::Instance());
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

void EnemyState_Walk::Enter(Enemy* agent)
{
	CCLOG(@"ENEMY: WALK");
	agent->ResetTimeSinceLastScan();
	agent->StartAction("Walk");
}

void EnemyState_Walk::Execute(Enemy* agent)
{
	agent->Walk();
	
	if (agent->CanScanForPlayer() && agent->ScanForPlayer())
	{
		agent->FSM()->ChangeState(EnemyState_Fire::Instance());
	}
}

void EnemyState_Walk::Exit(Enemy* agent)
{
	agent->StopAction("Walk");
}

// -------------------------------------------------------------------------------------

void EnemyState_Fire::Enter(Enemy* agent)
{
	CCLOG(@"ENEMY: FIRE");
	agent->StopWalking();
	
	CCSprite* sprite = (CCSprite*)agent->Node();
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Wolf4"];
	
	agent->ResetShotCounter();
}

void EnemyState_Fire::Execute(Enemy* agent)
{
	if (agent->NumShotsFired() < 3)
	{
		if (agent->CanFireNextShot())
		{
			agent->Fire();
		}
	}
	else
	{
		if (agent->CanFireNextShot())
		{
			agent->FSM()->ChangeState(EnemyState_Walk::Instance());
		}
	}
}

// -------------------------------------------------------------------------------------

void EnemyState_Dead::Enter(Enemy* agent)
{
	CCLOG(@"ENEMY: DEAD");
	agent->Die();
}

void EnemyState_Dead::Execute(Enemy* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool EnemyState_Dead::OnMessage(Enemy* agent, const Telegram& telegram)
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

void EnemyState_Drowned::Enter(Enemy* agent)
{
	CCLOG(@"Enemy: DROWNED");
	agent->Drown();
}

void EnemyState_Drowned::Execute(Enemy* agent)
{
	agent->Sink();
	
	if (agent->IsActionDone("Die"))
	{
		agent->SetDestroyed(true);
	}
}

bool EnemyState_Drowned::OnMessage(Enemy* agent, const Telegram& telegram)
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
