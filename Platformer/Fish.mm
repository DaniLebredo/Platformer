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

#import "Fish.h"
#import "FishStates.h"
#import "Ghost.h"
#import "LevelController.h"
#import "Game.h"


Fish::Fish(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Fish>("Fish", level, opt),
	mTimeSinceLastJump(0),
	mDeltaTime(0),
	mDelay(0),
	mShouldGoToInitialPos(false),
	mNumDeadlyContacts(0)
{
	// ---
	
	mIsEnemy = true;
	mOffset = PNGMakePoint(0, 5);
	
	// ---
	
	int biteFrames[] = { 2, 1, 0, 1 };
	int biteNumFrames = sizeof(biteFrames) / sizeof(int);
	addAction("Bite", biteFrames, biteNumFrames, "Fish", 0.08, true);
	
	// ---
	
	int swimFrames[] = { 4, 5, 6, 7 };
	int swimNumFrames = sizeof(biteFrames) / sizeof(int);
	addAction("Swim", swimFrames, swimNumFrames, "Fish", 0.15, true);
	
	// ---
	
	CCAction* fadeOutAction = [[CCFadeOut alloc] initWithDuration:0.5];
	addAction("Die", fadeOutAction);
	[fadeOutAction release];
	
	// ---
	
	mInitialPos.Set(pos.x / mPtmRatio, pos.y / mPtmRatio);
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Fish0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = pos;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Fish", pos);
	
	if (opt)
	{
		NSString* delay = [opt objectForKey:@"delay"];
		if (delay)
		{
			mDelay = [delay floatValue];
			CCLOG(@"DELAY = %f", mDelay);
			mTimeSinceLastJump = 4 - mDelay;
		}
	}
	
	State<Fish>* startState = CommonState_Init<Fish>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(FishState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Fish::~Fish()
{
	CCLOG(@"DEALLOC: Fish");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Fish::TryToJump()
{
	mLevel->MsgDispatcher()->DispatchMsg(ID(), ID(), Msg_Activated, NULL);
}

void Fish::Jump()
{
	mShouldGoToInitialPos = false;
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(0, 15));
}

void Fish::Fall()
{
	if (NumWaterContacts() > 0)
		mShouldGoToInitialPos = true;
}

void Fish::GoToInitialPosition()
{
	b2Vec2 newPosition = Lerp(mPhyBody->GetPosition(), mInitialPos, 0.05);
	b2Vec2 velocity = (1 / mDeltaTime) * (newPosition - mPhyBody->GetPosition());
	ApplyCorrectiveImpulse(mPhyBody, velocity);
}

bool Fish::IsAtInitialPosition() const
{
	b2Vec2 vel = mPhyBody->GetLinearVelocity();
	b2Vec2 deltaPos = mInitialPos - mPhyBody->GetPosition();
	
	//CCLOG(@"vx: %f, vy: %f, dx: %f, dy: %f", vel.x, vel.y, deltaPos.x, deltaPos.y);
	
	float epsilon = 0.05;
	
	return fabs(vel.x) < epsilon && fabs(vel.y) < epsilon &&
			fabs(deltaPos.x) < epsilon && fabs(deltaPos.y) < epsilon;
}

void Fish::Die()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Fish3"];
	
	StartAction("Die");
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("EnemyKilled.caf", deltaPos);
	
	Ghost* ghost = new Ghost(mLevel, ccpAdd(mNode.position, PNGMakePoint(0, 15)));
	mLevel->AddGameObject(ghost);
}

void Fish::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Fish::ProcessContacts()
{
	mNumDeadlyContacts = 0;
	
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherFixUserData->KillsEnemy)
		{
			++mNumDeadlyContacts;
		}
	}
}
