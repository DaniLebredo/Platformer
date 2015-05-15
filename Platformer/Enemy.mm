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
 
#import "Enemy.h"
#import "EnemyStates.h"
#import "VampireBullet.h"
#import "Ghost.h"
#import "LevelController.h"
#import "Game.h"

// ------------------------------------------------------------------------------------

EnemyRayCastCallback::EnemyRayCastCallback() :
	mPlayerFound(false)
{
}

float32 EnemyRayCastCallback::ReportFixture(b2Fixture* fixture, const b2Vec2& point, const b2Vec2& normal, float32 fraction)
{
	GameObject* gObj = (GameObject*)fixture->GetBody()->GetUserData();
	
	// Ignore these GameObjects as we can see through them.
	if (gObj->IsEnemy() || gObj->Class() == "Coin" || gObj->Class() == "Key")
	{
		return -1;
	}
	else
	{
		if (gObj->Class() == "Player")
		{
			//CCLOG(@"Found Player");
			mPlayerFound = true;
		}
		else
		{
			mPlayerFound = false;
		}
		
		return fraction;
	}
}

// ------------------------------------------------------------------------------------

Enemy::Enemy(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Enemy>("Enemy", level, opt),
	mMoveLeft(false),
	mShouldTurn(false),
	mDeltaTime(0),
	mTimeSinceLastScan(0),
	mTimeSinceLastShot(0),
	mScanPeriod(1),
	mNumShotsFired(0),
	mNumFootContacts(0), mNumLeftFootContacts(0), mNumRightFootContacts(0),
	mNumDeadlyContacts(0)
{
	mRayCastCallback = new EnemyRayCastCallback;
	
	// ---
	
	mIsEnemy = true;
	mUpdateNodeRotation = false;
	mOffset = PNGMakePoint(0, 10.5);
	
	// ---
	
	int walkFrames[] = { 0, 1, 2, 3 };
	int walkNumFrames = sizeof(walkFrames) / sizeof(int);
	addAction("Walk", walkFrames, walkNumFrames, "Wolf", 0.06, true);
	
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
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Wolf0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Enemy", pos);
	
	if (opt)
	{
		NSString* left = [opt objectForKey:@"left"];
		if (left && [left isEqualToString:@"true"])
			mMoveLeft = true;
		
		NSString* scanPeriod = [opt objectForKey:@"scanPeriod"];
		if (scanPeriod)
		{
			mScanPeriod = [scanPeriod floatValue];
			CCLOG(@"SCAN PERIOD = %f", mScanPeriod);
		}
	}
	
	SetMoveLeft(mMoveLeft);
	
	State<Enemy>* startState = CommonState_Init<Enemy>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(EnemyState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Enemy::~Enemy()
{
	CCLOG(@"DEALLOC: Enemy");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
	
	delete mRayCastCallback;
	mRayCastCallback = NULL;
}

void Enemy::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
	
	mTimeSinceLastScan += dt;
	mTimeSinceLastShot += dt;
}

void Enemy::Walk()
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
	float velX = 3;
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(sign * velX, mPhyBody->GetLinearVelocity().y));
}

void Enemy::StopWalking()
{
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(0, mPhyBody->GetLinearVelocity().y));
}

void Enemy::SetMoveLeft(bool moveLeft)
{
	mMoveLeft = moveLeft;
	mNode.scaleX = mMoveLeft ? -1 : 1;
}

void Enemy::Fire()
{
	++mNumShotsFired;
	mTimeSinceLastShot = 0;
	
	float sign = mMoveLeft ? -1 : 1;
	
	CGPoint offset = PNGMakePoint(sign * 30, -5);
	CGPoint pos = ccpAdd(mNode.position, offset);
	
	VampireBullet* bullet = new VampireBullet(mLevel, pos, mMoveLeft, false);
	mLevel->AddGameObject(bullet);
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("EnemyFire.caf", deltaPos);
}

void Enemy::Die()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Wolf5"];
	
	StartAction("Die");
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("EnemyKilled.caf", deltaPos);
	
	Ghost* ghost = new Ghost(mLevel, ccpAdd(mNode.position, PNGMakePoint(0, 15)));
	mLevel->AddGameObject(ghost);
}

void Enemy::Drown()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Wolf5"];
	
	if (mMoveLeft)
		StartAction("RotateRight");
	else StartAction("RotateLeft");
	
	StartAction("Die");
	
	Ghost* ghost = new Ghost(mLevel, ccpAdd(mNode.position, PNGMakePoint(0, 15)));
	mLevel->AddGameObject(ghost);
}

void Enemy::Sink()
{
	b2Vec2 velocity = (1 / mDeltaTime) * b2Vec2(0, -0.1);
	ApplyCorrectiveImpulse(mPhyBody, velocity);
}

bool Enemy::ScanForPlayer()
{
	mTimeSinceLastScan = 0;
	
	float sign = mMoveLeft ? -1 : 1;
	float length = 10;
	
	b2Vec2 p1 = mPhyBody->GetPosition() + b2Vec2(0, 1); // coords of eyes
	b2Vec2 p2 = p1 + b2Vec2(sign * length, 0);
	
	CCLOG(@"ENEMY: CHECKING FOR PLAYER...");
	mRayCastCallback->ResetState();
	
	mPhyWorld->RayCast(mRayCastCallback, p1, p2);
	
	return mRayCastCallback->PlayerFound();
}

void Enemy::ProcessContacts()
{
	mNumDeadlyContacts = 0;
	
	mNumFootContacts = 0;
	mNumLeftFootContacts = 0;
	mNumRightFootContacts = 0;
	
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
