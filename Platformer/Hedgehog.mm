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

#import "Hedgehog.h"
#import "HedgehogStates.h"
#import "Ghost.h"
#import "LevelController.h"
#import "Game.h"


Hedgehog::Hedgehog(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Hedgehog>("Hedgehog", level, opt),
	mMoveLeft(false),
	mShouldTurn(false),
	mDeltaTime(0),
	mNumFootContacts(0), mNumLeftFootContacts(0), mNumRightFootContacts(0),
	mNumDeadlyContacts(0)
{
	// ---
	
	mIsEnemy = true;
	mUpdateNodeRotation = false;
	mOffset = PNGMakePoint(0, -1);
	
	// ---
	
	int walkFrames[] = { 0, 1, 2, 3 };
	int walkNumFrames = sizeof(walkFrames) / sizeof(int);
	addAction("Walk", walkFrames, walkNumFrames, "Hedgehog", 0.2, true);
	
	// ---
	
	int thinkFrames[] = { 4, 5, 6 };
	int thinkNumFrames = sizeof(thinkFrames) / sizeof(int);
	addAction("Think", thinkFrames, thinkNumFrames, "Hedgehog", 0.3, true);
	
	// ---
	
	CCAction* rotateLeftAction = [[CCRotateTo alloc] initWithDuration:0.5 angle:-180];
	addAction("RotateLeft", rotateLeftAction);
	[rotateLeftAction release];
	
	// ---
	
	CCAction* rotateRightAction = [[CCRotateTo alloc] initWithDuration:0.5 angle:180];
	addAction("RotateRight", rotateRightAction);
	[rotateRightAction release];
	
	// ---
	
	CCAction* fadeOutAction = [[CCFadeOut alloc] initWithDuration:0.5];
	addAction("Die", fadeOutAction);
	[fadeOutAction release];
	
	// ---
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Hedgehog0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Hedgehog", pos);
	
	if (opt)
	{
		NSString* left = [opt objectForKey:@"left"];
		if (left && [left isEqualToString:@"true"])
			mMoveLeft = true;
	}
	
	SetMoveLeft(mMoveLeft);
	
	State<Hedgehog>* startState = CommonState_Init<Hedgehog>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(HedgehogState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Hedgehog::~Hedgehog()
{
	CCLOG(@"DEALLOC: Hedgehog");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Hedgehog::Walk()
{
	if (mShouldTurn)
	{
		mShouldTurn = false;
		SetMoveLeft(!mMoveLeft);
	}
	else if (mNumFootContacts > 0)
	{
		if (mMoveLeft && mNumLeftFootContacts == 0)
		{
			SetMoveLeft(false);
		}
		else if (!mMoveLeft && mNumRightFootContacts == 0)
		{
			SetMoveLeft(true);
		}
	}
	
	float sign = mMoveLeft ? -1 : 1;
	float velX = 1;
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(sign * velX, mPhyBody->GetLinearVelocity().y));
}

void Hedgehog::Think()
{
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(0, mPhyBody->GetLinearVelocity().y));
}

void Hedgehog::Die()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Hedgehog5"];
	
	StartAction("Die");
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("EnemyKilled.caf", deltaPos);
	
	Ghost* ghost = new Ghost(mLevel, ccpAdd(mNode.position, PNGMakePoint(0, 15)));
	mLevel->AddGameObject(ghost);
}

void Hedgehog::Drown()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Hedgehog5"];
	
	if (mMoveLeft)
		StartAction("RotateRight");
	else StartAction("RotateLeft");
	
	StartAction("Die");
	
	Ghost* ghost = new Ghost(mLevel, ccpAdd(mNode.position, PNGMakePoint(0, 15)));
	mLevel->AddGameObject(ghost);
}

void Hedgehog::Sink()
{
	b2Vec2 velocity = (1 / mDeltaTime) * b2Vec2(0, -0.1);
	ApplyCorrectiveImpulse(mPhyBody, velocity);
}

void Hedgehog::SetMoveLeft(bool moveLeft)
{
	mMoveLeft = moveLeft;
	mNode.scaleX = mMoveLeft ? -1 : 1;
}

void Hedgehog::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Hedgehog::ProcessContacts()
{
	mNumDeadlyContacts = 0;
	mNumFootContacts = 0;
	mNumLeftFootContacts = 0;
	mNumRightFootContacts = 0;
	
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherFixUserData->KillsEnemy &&
			colInfo.OtherObject->Class() != "Tile")
		{
			++mNumDeadlyContacts;
		}
		
		if (colInfo.OtherObjFixType == 2)
		{
			switch (colInfo.ThisObjFixType)
			{
				case 9: if (mMoveLeft) mShouldTurn = true; break;
				case 10: if (!mMoveLeft) mShouldTurn = true; break;
				case 11: ++mNumFootContacts; break;
				case 12: ++mNumLeftFootContacts; break;
				case 13: ++mNumRightFootContacts; break;
				default: break;
			}
		}
	}
}
