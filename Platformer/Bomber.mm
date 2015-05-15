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

#import "Bomber.h"
#import "BomberStates.h"
#import "Bullet.h"
#import "Bomb.h"
#import "LevelController.h"
#import "Game.h"


Bomber::Bomber(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Bomber>("Bomber", level, opt),
	mTimeSinceLastShot(0),
	mNumShotsFired(0),
	mTimeSinceDied(0),
	mDeltaTime(0)
{
	// ---
	
	mIsEnemy = true;
	
	// ---
	
	int flyFrames[] = { 0, 1, 2, 3, 3, 2, 1, 0 };
	int flyNumFrames = sizeof(flyFrames) / sizeof(int);
	addAction("Fly", flyFrames, flyNumFrames, "Flyer", 0.04, true);
	
	// ---
	
	CCAction* fadeOutAction = [[CCFadeOut alloc] initWithDuration:0.5];
	addAction("Die", fadeOutAction);
	[fadeOutAction release];
	
	// ---
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Flyer0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = pos;
	((CCSprite*)mNode).color = ccRED;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 32;
	
	mPhyBody = instantiatePhysicsFor("Bomber", pos);
	
	State<Bomber>* startState = BomberState_FollowPlayer::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(BomberState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Bomber::~Bomber()
{
	CCLOG(@"DEALLOC: Bomber");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Bomber::FollowPlayer()
{
	GameObject* player = mLevel->PlayerObj();
	
	if (player != NULL)
	{
		b2Vec2 newPosition = Lerp(mPhyBody->GetPosition(), player->PhyBody()->GetPosition() + b2Vec2(0, 4.5), 0.025);
		b2Vec2 velocity = (1 / mDeltaTime) * (newPosition - mPhyBody->GetPosition());
		ApplyCorrectiveImpulse(mPhyBody, velocity);
		
		if (velocity.x > 0)
		{
			mNode.scaleX = -1;
		}
		else if (velocity.x < 0)
		{
			mNode.scaleX = 1;
		}
	}
}

void Bomber::StopFollowingPlayer()
{
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2_zero);
}

bool Bomber::IsAbovePlayer() const
{
	GameObject* player = mLevel->PlayerObj();
	
	if (player != NULL)
	{
		b2Vec2 vel = mPhyBody->GetLinearVelocity();
		b2Vec2 deltaPos = player->PhyBody()->GetPosition() + b2Vec2(0, 4.5) - mPhyBody->GetPosition();
		
		//CCLOG(@"vx: %f, vy: %f, dx: %f, dy: %f", vel.x, vel.y, deltaPos.x, deltaPos.y);
		
		float epsilon = 0.005;
		
		return fabs(vel.x) < epsilon && fabs(vel.y) < epsilon &&
				fabs(deltaPos.x) < epsilon && fabs(deltaPos.y) < epsilon;
	}
	else return false;
}

void Bomber::Fire()
{
	++mNumShotsFired;
	mTimeSinceLastShot = 0;
	
	CGPoint offset = PNGMakePoint(30, 0);
	CGPoint pos = ccpAdd(mNode.position, offset);
	 
	// Instantiate a cannon ball.
	Bomb* ball = new Bomb(mLevel, pos, b2Vec2_zero);
	mLevel->AddGameObject(ball);
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("PlayerFire.caf", deltaPos);
}

void Bomber::Die()
{
	mTimeSinceDied = 0;
	
	MakeBodyNotCollidable(mPhyBody);
	
	((CCSprite*)mNode).color = ccRED;
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("EnemyKilled.caf", deltaPos);
}

void Bomber::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
	
	mTimeSinceLastShot += dt;
	mTimeSinceDied += dt;
}
