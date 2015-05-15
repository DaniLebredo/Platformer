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

#import "Jumper.h"
#import "JumperStates.h"
#import "Ghost.h"
#import "LevelController.h"
#import "Game.h"


Jumper::Jumper(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Jumper>("Jumper", level, opt),
	mMoveLeft(false),
	mNumFootContacts(0),
	mNumPlayerContacts(0),
	mNumDeadlyContacts(0),
	mTimeSinceJumped(0),
	mDeltaTime(0)
{
	mIsEnemy = true;
	mUpdateNodeRotation = false;
	mOffset = PNGMakePoint(0, 9);
	
	// ---
	
	int attackFrames[] = { 3, 4, 5, 5, 4, 3 };
	int attackNumFrames = sizeof(attackFrames) / sizeof(int);
	addAction("Attack", attackFrames, attackNumFrames, "Rabbit", 0.0625, false);
	
	// ---
	
	int idleFrames[] = { 6, 7, 8 };
	int idleNumFrames = sizeof(idleFrames) / sizeof(int);
	addAction("Idle", idleFrames, idleNumFrames, "Rabbit", 0.1, true);
	
	// ---
	
	CCAction* rotateLeftAction = [[CCRotateTo alloc] initWithDuration:0.5 angle:-90];
	addAction("RotateLeft", rotateLeftAction);
	[rotateLeftAction release];
	
	// ---
	
	CCAction* rotateRightAction = [[CCRotateTo alloc] initWithDuration:0.5 angle:90];
	addAction("RotateRight", rotateRightAction);
	[rotateRightAction release];
	
	// ---
	
	CCAction* fadeOutAction = [[CCFadeOut alloc] initWithDuration:0.5];
	addAction("Die", fadeOutAction);
	[fadeOutAction release];
	
	// ---
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Rabbit0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Jumper", pos);
	
	if (opt)
	{
		NSString* left = [opt objectForKey:@"left"];
		if (left && [left isEqualToString:@"true"])
			mMoveLeft = true;
	}
	
	SetMoveLeft(mMoveLeft);
	
	State<Jumper>* startState = CommonState_Init<Jumper>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(JumperState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Jumper::~Jumper()
{
	CCLOG(@"DEALLOC: Jumper");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Jumper::SetMoveLeft(bool moveLeft)
{
	mMoveLeft = moveLeft;
	mNode.scaleX = mMoveLeft ? -1 : 1;
}

void Jumper::LookAtPlayer()
{
	GameObject* player = mLevel->PlayerObj();
	
	if (player != NULL)
	{
		b2Vec2 deltaPos = player->PhyBody()->GetPosition() - mPhyBody->GetPosition();
		
		SetMoveLeft(deltaPos.x < 0);
	}
}

void Jumper::LimitFallingVelocity()
{
	float maxFallVel = -20;
	b2Vec2 vel = mPhyBody->GetLinearVelocity();
	
	if (vel.y < maxFallVel)
	{
		vel.y = maxFallVel;
		mPhyBody->SetLinearVelocity(vel);
	}
}

void Jumper::Jump()
{
	float sign = mMoveLeft ? -1 : 1;
	
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(sign * 7.5, 15));
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("EnemyJump.caf", deltaPos);
}

void Jumper::Die()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Rabbit2"];
	
	StartAction("Die");
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("EnemyKilled.caf", deltaPos);
	
	Ghost* ghost = new Ghost(mLevel, ccpAdd(mNode.position, PNGMakePoint(0, 15)));
	mLevel->AddGameObject(ghost);
}

void Jumper::Drown()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Rabbit2"];
	
	if (mMoveLeft)
		StartAction("RotateRight");
	else StartAction("RotateLeft");
	
	StartAction("Die");
	
	Ghost* ghost = new Ghost(mLevel, ccpAdd(mNode.position, PNGMakePoint(0, 15)));
	mLevel->AddGameObject(ghost);
}

void Jumper::Sink()
{
	b2Vec2 velocity = (1 / mDeltaTime) * b2Vec2(0, -0.1);
	ApplyCorrectiveImpulse(mPhyBody, velocity);
}

void Jumper::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Jumper::ProcessContacts()
{
	mNumDeadlyContacts = 0;
	mNumFootContacts = 0;
	mNumPlayerContacts = 0;
	
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherFixUserData->KillsEnemy)
		{
			++mNumDeadlyContacts;
		}
		
		if (colInfo.OtherObjFixType == 2)
		{
			switch (colInfo.ThisObjFixType)
			{
				//case 9: if (mMoveLeft) SetMoveLeft(false); break;
				//case 10: if (!mMoveLeft) SetMoveLeft(true); break;
				case 11: ++mNumFootContacts; break;
				default: break;
			}
		}
		else if (colInfo.OtherObject->Class() == "Player")
		{
			++mNumPlayerContacts;
		}
	}
}
