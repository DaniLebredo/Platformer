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

#import "PlayerNormalStates.h"
#import "PlayerNormal.h"

// -------------------------------------------------------------------------------------

void PlayerNormalState_Global::Execute(PlayerNormal* agent)
{
	agent->ProcessContacts();
	
	// Did agent fall off the screen?
	if (agent->Node().position.y < -100)
	{
		if (!agent->FSM()->IsInState(PlayerNormalState_Dead::Instance()))
			agent->FSM()->ChangeState(PlayerNormalState_Dead::Instance());
	}
	else
	{
		if (!agent->FSM()->IsInState(PlayerNormalState_Dead::Instance()) &&
			!agent->FSM()->IsInState(PlayerNormalState_Done::Instance()))
		{
			if (agent->Invincible())
			{
				agent->UpdateInvincibilityTimer();
				
				if (agent->InvincibilityTimerValue() >= 1)
					agent->SetInvincible(false);
			}
			else if (agent->NumDeadlyContacts() > 0)
			{
				agent->GotHit();
			}
			
			agent->Walk();
		}
	}
}

bool PlayerNormalState_Global::OnMessage(PlayerNormal* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_PreSolve:
		{
			agent->PreSolve(static_cast<CollisionInfo*>(telegram.ExtraInfo));
			return true;
		}
			
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		{
			if (!agent->FSM()->IsInState(PlayerNormalState_Dead::Instance()) &&
				!agent->FSM()->IsInState(PlayerNormalState_Done::Instance()))
			{
				if (!agent->Invincible()) agent->GotHit();
			}
			return true;
		}
		
		case Msg_ZeroHealth:
		{
			if (!agent->FSM()->IsInState(PlayerNormalState_Dead::Instance()) &&
				!agent->FSM()->IsInState(PlayerNormalState_Done::Instance()))
			{
				agent->FSM()->ChangeState(PlayerNormalState_Dead::Instance());
			}
			return true;
		}
			
		case Msg_BeginCollisionWithWater:
		{
			if (!agent->FSM()->IsInState(PlayerNormalState_Dead::Instance()) &&
				!agent->FSM()->IsInState(PlayerNormalState_Done::Instance()))
			{
				agent->FSM()->ChangeState(PlayerNormalState_Done::Instance());
			}
			return true;
		}
			
		case Msg_KeyPickedUp:
		{
			agent->SetNumKeys(agent->NumKeys() + 1);
			CCLOG(@"GOT KEY -> NUM: %d", agent->NumKeys());
			return true;
		}
			
		case Msg_KeyLost:
		{
			agent->SetNumKeys(std::max(0, agent->NumKeys() - 1));
			CCLOG(@"LOST KEY -> NUM: %d", agent->NumKeys());
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

void PlayerNormalState_OnTheFloor::Enter(PlayerNormal* agent)
{
	CCLOG(@"PLAYER: ON THE FLOOR");
	if (agent->FSM()->WasInState(PlayerNormalState_FallingDown::Instance()))
	{
		agent->SetShouldSpawnSmokeJump(true);
	}
}

void PlayerNormalState_OnTheFloor::Execute(PlayerNormal* agent)
{
	if (agent->ShouldSpawnSmokeJump())
	{
		agent->SetShouldSpawnSmokeJump(false);
		agent->SpawnSmokeJump();
	}
		
	agent->AnimateOnTheFloor();
	
	if (agent->JumpPressed() && agent->ReadyForNextJump())
	{
		agent->FSM()->ChangeState(PlayerNormalState_Jump::Instance());
	}
	else if (!agent->TouchingFloor())
	{
		//agent->FSM()->ChangeState(PlayerNormalState_FallingDown::Instance());
		agent->FSM()->ChangeState(PlayerNormalState_RisingUp::Instance());
	}
	else
	{
		agent->GlueToPlatform();
	}
}

void PlayerNormalState_OnTheFloor::Exit(PlayerNormal* agent)
{
	// Player can only be idle when on the floor.
	agent->SetIdle(false);
	
	agent->StopAction("Walk");
	agent->StopAction("Idle");
}

// -------------------------------------------------------------------------------------

void PlayerNormalState_Jump::Enter(PlayerNormal* agent)
{
	CCLOG(@"PLAYER: JUMP");
	agent->PerformJump();
}

void PlayerNormalState_Jump::Execute(PlayerNormal* agent)
{
	agent->FSM()->ChangeState(PlayerNormalState_RisingUp::Instance());
}

// -------------------------------------------------------------------------------------

void PlayerNormalState_Bounce::Enter(PlayerNormal* agent)
{
	CCLOG(@"PLAYER: BOUNCE");
	agent->PerformBounce();
}

void PlayerNormalState_Bounce::Execute(PlayerNormal* agent)
{
	if (agent->TouchingFloor())
		agent->FSM()->ChangeState(PlayerNormalState_OnTheFloor::Instance());
	else if (agent->PhyBody()->GetLinearVelocity().y <= 0)
		agent->FSM()->ChangeState(PlayerNormalState_FallingDown::Instance());
}

// -------------------------------------------------------------------------------------

void PlayerNormalState_RisingUp::Enter(PlayerNormal* agent)
{
	CCLOG(@"PLAYER: RISING UP");
}

void PlayerNormalState_RisingUp::Execute(PlayerNormal* agent)
{
	if (!agent->JumpPressed())
		agent->FSM()->ChangeState(PlayerNormalState_AttenuateJump::Instance());
	else if (agent->TouchingFloor())
		agent->FSM()->ChangeState(PlayerNormalState_OnTheFloor::Instance());
	else if (agent->PhyBody()->GetLinearVelocity().y <= 0)
		agent->FSM()->ChangeState(PlayerNormalState_FallingDown::Instance());
}

// -------------------------------------------------------------------------------------

void PlayerNormalState_AttenuateJump::Enter(PlayerNormal* agent)
{
	CCLOG(@"PLAYER: ATTENUATE JUMP");
}

void PlayerNormalState_AttenuateJump::Execute(PlayerNormal* agent)
{
	if (agent->TouchingFloor())
		agent->FSM()->ChangeState(PlayerNormalState_OnTheFloor::Instance());
	else if (agent->PhyBody()->GetLinearVelocity().y <= 0)
		agent->FSM()->ChangeState(PlayerNormalState_FallingDown::Instance());
	else agent->AttenuateJump();
}

// -------------------------------------------------------------------------------------

void PlayerNormalState_FallingDown::Enter(PlayerNormal* agent)
{
	CCLOG(@"PLAYER: FALLING DOWN");
	CCSprite* sprite = (CCSprite*)agent->Node();
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player9"];
}

void PlayerNormalState_FallingDown::Execute(PlayerNormal* agent)
{
	if (agent->TouchingFloor())
		agent->FSM()->ChangeState(PlayerNormalState_OnTheFloor::Instance());
}

// -------------------------------------------------------------------------------------

void PlayerNormalState_Dead::Enter(PlayerNormal* agent)
{
	CCLOG(@"PLAYER: DEAD");
	agent->Die();
	agent->SetInvincible(false);
	ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(0, 10));
}

void PlayerNormalState_Dead::Execute(PlayerNormal* agent)
{
	if (agent->IsActionDone("Die"))
	{
		agent->PhyBody()->SetActive(false);
	}
	else
	{
		ApplyCorrectiveImpulse(agent->PhyBody(), b2Vec2(0, agent->PhyBody()->GetLinearVelocity().y));
	}
}

// -------------------------------------------------------------------------------------

void PlayerNormalState_Done::Enter(PlayerNormal* agent)
{
	CCLOG(@"PLAYER: DONE");
	agent->Done();
	agent->SetInvincible(false);
}

void PlayerNormalState_Done::Execute(PlayerNormal* agent)
{
	agent->Float();
}

// -------------------------------------------------------------------------------------
