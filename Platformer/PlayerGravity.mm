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

#import "PlayerGravity.h"
#import "PlayerGravityStates.h"
#import "Bullet.h"
#import "LevelController.h"
#import "Game.h"


PlayerGravity::PlayerGravity(LevelController* level, CGPoint pos) :
	GameObjectFSM("PlayerGravity", level),
	mNumFootContacts(0),
	mDead(false),
	mHealth(1),
	mGravityDown(true),
	mDeltaTime(0)
{
	mWalkVelocity = 8;
	mWalkForce = 16;
	mFallVelocity = 8;
	
	// ---
	
	NSInteger numIndices = 4;
	NSInteger frameIndices[] = { 1, 2, 3, 4 };
	
	NSMutableArray* walkAnimSeq = [[NSMutableArray alloc] initWithCapacity:numIndices];
	for (int i = 0; i < numIndices; ++i)
	{
		NSString* name = [[NSString alloc] initWithFormat:@"Player%d", frameIndices[i]];
		CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
		
		[walkAnimSeq addObject:frame];
		
		[name release];
	}
	
	CCAnimation* walkAnim = [[CCAnimation alloc] initWithSpriteFrames:walkAnimSeq delay:0.09];
	mWalkAction = [[CCRepeatForever alloc] initWithAction:[CCAnimate actionWithAnimation:walkAnim]];
	[walkAnim release];
	
	// ---
	
	//mNode = [[CCSprite alloc] initWithFile:@"madmartigan.png"];
	//mNode = [[CCSprite alloc] initWithFile:@"kirk.png"];
	//mNode = [[CCSprite alloc] initWithFile:@"indy.png"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:[walkAnimSeq objectAtIndex:1]];
	mNode.position = pos;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	//[mNode runAction:mSantaAction];
	
	[walkAnimSeq release];
	
	// mainPartDef.density = 1 * 0.45 * 0.45 / (0.8 * 0.8);
	mPhyBody = instantiatePhysicsFor("PlayerGravity", pos);
	
	State<PlayerGravity>* startState = PlayerGravityState_OnTheFloor::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(PlayerGravityState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

PlayerGravity::~PlayerGravity()
{
	[mNode stopAllActions];
	[mWalkAction release];
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void PlayerGravity::OnButtonAPressed()
{
	Jump();
}

void PlayerGravity::OnButtonBPressed()
{
	Fire();
}

void PlayerGravity::Jump()
{
	if (mDead) return;
	
	mGravityDown = !mGravityDown;
	
	mNode.scaleY = mGravityDown ? 1 : -1;
	
	StopWalkAnimation();
	StartFallAnimation();
	
	//SoundManager::Instance()->ScheduleEffect("gravity.caf");
}

void PlayerGravity::Fire()
{
	if (mDead) return;
	
	CGPoint pos = mNode.position;
	float offset = 0;
	pos.x += offset;
	
	// Instantiate a bullet.
	Bullet* bullet = new Bullet(mLevel, pos, false);
	mLevel->AddGameObject(bullet);
	
	SoundManager::Instance()->ScheduleEffect("PlayerFire.caf");
}

void PlayerGravity::GotHit()
{
	--mHealth;
	
	if (mHealth == 0)
	{
		Telegram telegram(ID(), ID(), Msg_ZeroHealth, NULL);
		HandleMessage(telegram);
	}
	
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_HealthChanged, NULL);
	mLevel->HandleMessage(telegram);
	
	SoundManager::Instance()->ScheduleEffect("PlayerKilled.caf");
}

void PlayerGravity::Die()
{
	mDead = true;
	mNode.scaleY = -1;
	MakeBodyNotCollidable(mPhyBody);
}

void PlayerGravity::Done()
{
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_LifeLost, NULL);
	mLevel->HandleMessage(telegram);
}

void PlayerGravity::WalkLimiter(float limitVel, bool walkLeft)
{
	b2Vec2 vel = mPhyBody->GetLinearVelocity();
	
	float sign = walkLeft ? -1 : 1;
	
	if (sign * (vel.x - limitVel) < 0)
	{
		float newVelocityX = vel.x + sign * mDeltaTime * mWalkForce / mPhyBody->GetMass();
		
		// If walk force doesn't make player walk above the velocity limit, then apply it.
		if (sign * (newVelocityX - limitVel) < 0)
			mPhyBody->ApplyForce(b2Vec2(sign * mWalkForce, 0), mPhyBody->GetWorldCenter());
		// Otherwise, make player walk at exactly the velocity limit.
		else ApplyCorrectiveImpulse(mPhyBody, b2Vec2(limitVel, vel.y));
	}
}

void PlayerGravity::Walk()
{
	b2Vec2 vel = mPhyBody->GetLinearVelocity();
	
	float limitVelRight = mWalkVelocity;
	
	WalkLimiter(limitVelRight, false);
	
	if (!mGravityDown)
	{
		mPhyBody->ApplyForce(-2 * mPhyBody->GetMass() * mPhyWorld->GetGravity(), mPhyBody->GetWorldCenter());
	}
	
	// Check whether all the velocities are within their limits.
	if (vel.x > limitVelRight) ApplyCorrectiveImpulse(mPhyBody, b2Vec2(limitVelRight, vel.y));
	
	if (mGravityDown)
	{
		if (vel.y < -mFallVelocity) ApplyCorrectiveImpulse(mPhyBody, b2Vec2(vel.x, -mFallVelocity));
	}
	else
	{
		if (vel.y > mFallVelocity) ApplyCorrectiveImpulse(mPhyBody, b2Vec2(vel.x, mFallVelocity));
	}
}

void PlayerGravity::StartWalkAnimation()
{
	[mNode runAction:mWalkAction];
}

void PlayerGravity::StopWalkAnimation()
{
	[mNode stopAction:mWalkAction];
}

void PlayerGravity::StartFallAnimation()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player5"];
}

void PlayerGravity::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void PlayerGravity::BeginContact(CollisionInfo* collisionInfo)
{
	GameObject* gObj = collisionInfo->OtherObject;
	b2Contact* contact = collisionInfo->Contact;
	
	int fixA = reinterpret_cast<int>(contact->GetFixtureA()->GetUserData());
	int fixB = reinterpret_cast<int>(contact->GetFixtureB()->GetUserData());
	
	std::string gObjClass = gObj->Class();
	
	if (fixA == 1 || fixB == 1)
	{
		if (fixA == 2 || fixB == 2)
		{
			++mNumFootContacts;
		}
		else if (fixA == 22 || fixB == 22)
		{
			++mNumFootContacts;
		}
	}
	
	mLevel->MsgDispatcher()->DispatchMsg(ID(), gObj->ID(), Msg_CollidedWithPlayer, NULL);
	
	//CCLOG(@"CONTACT BEGIN, numContacts: %d", mNumFootContacts);
}

void PlayerGravity::EndContact(CollisionInfo* collisionInfo)
{
	GameObject* gObj = collisionInfo->OtherObject;
	b2Contact* contact = collisionInfo->Contact;
	
	int fixA = reinterpret_cast<int>(contact->GetFixtureA()->GetUserData());
	int fixB = reinterpret_cast<int>(contact->GetFixtureB()->GetUserData());
	
	if (fixA == 1 || fixB == 1)
	{
		if (fixA == 2 || fixB == 2)
		{
			--mNumFootContacts;
		}
		else if (fixA == 22 || fixB == 22)
		{
			--mNumFootContacts;
		}
	}
	
	//CCLOG(@"CONTACT END, numContacts: %d", mNumFootContacts);
}
