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

#import "Bullet.h"
#import "BulletStates.h"
#import "LevelController.h"
#import "Game.h"


Bullet::Bullet(LevelController* level, CGPoint pos, bool moveLeft, bool friendly) :
	GameObjectFSM<Bullet>("Bullet", level),
	mMoveLeft(moveLeft),
	mFriendly(friendly)
{
	// ---
	
	int flyFrames[] = { 0, 1, 2, 3 };
	int flyNumFrames = sizeof(flyFrames) / sizeof(int);
	addAction("Fly", flyFrames, flyNumFrames, "Bullet", 0.05, true);
	
	// ---
	
	int hitFrames[] = { 4, 5, 6, 7 };
	int hitNumFrames = sizeof(hitFrames) / sizeof(int);
	addAction("Hit", hitFrames, hitNumFrames, "Bullet", 0.08, false);
	
	// ---
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Bullet0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = pos;
	if (mMoveLeft) mNode.scaleX = -1;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Bullet", pos);
	
	if (!mFriendly)
	{
		b2Fixture* fixture = mPhyBody->GetFixtureList();
		
		while (fixture)
		{
			b2Filter filter = fixture->GetFilterData();
			filter.categoryBits = Game::Instance()->Data().Categories("CATEGORY_HOSTILE_FIRE");
			filter.maskBits = Game::Instance()->Data().Masks("MASK_HOSTILE_FIRE");
			filter.groupIndex = Game::Instance()->Data().Groups("GROUP_HOSTILE_FIRE");
			fixture->SetFilterData(filter);
			
			fixture = fixture->GetNext();
		}
	}
	
	// CCLOG(@"BODY MASS: %f", mPhyBody->GetMass());
	
	State<Bullet>* startState = CommonState_Init<Bullet>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(BulletState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Bullet::~Bullet()
{
	// CCLOG(@"DEALLOC: Bullet");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Bullet::Fly()
{
	float velX = 15;
	//float velX = 9;
	if (mMoveLeft) velX *= -1;
	
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(velX, mPhyBody->GetLinearVelocity().y));
}

void Bullet::StopFlying()
{
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2_zero);
	
	StartAction("Hit");
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("ObstacleHit.caf", deltaPos);
}

void Bullet::Update(ccTime dt)
{
	GameObjectFSM::Update(dt);
}

void Bullet::ProcessContacts()
{
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		// Hit just the first contact.
		mLevel->MsgDispatcher()->DispatchMsg(ID(), colInfo.OtherObject->ID(), Msg_HitByBullet, NULL);
		FSM()->ChangeState(BulletState_HitSomething::Instance());
		break;
	}
}

void Bullet::PreSolve(CollisionInfo* colInfo)
{
	colInfo->Contact->SetEnabled(false);
}
