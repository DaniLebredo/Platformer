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

#import "PlayerNormal.h"
#import "PlayerNormalStates.h"
#import "Platform.h"
#import "Bullet.h"
#import "Flash.h"
#import "SmokeJump.h"
#import "SmokeRun.h"
#import "LevelController.h"
#import "Game.h"


PlayerNormal::PlayerNormal(LevelController* level, CGPoint pos) :
	GameObjectFSM<PlayerNormal>("Player", level),
	mWalkVelocity(8),
	mWalkForce(16),
	mWalkSlowdownForce(30),
	mBounceVelocity(11),
	mJumpVelocity(18),
	//mJumpVelocity(5), // for testing low jumps
	mJumpSlowdownForce(-40),
	mFallVelocity(-23),
	mDirectionLeft(false),
	mMoveLeftPressed(false), mMoveRightPressed(false), mJumpPressed(false),
	mMoveLeftReleased(true), mMoveRightReleased(true), mJumpReleased(true),
	mCanJump(false), mCanBeGlued(false), mNumFootContacts(0),
	mNumDeadlyContacts(0),
	mReadyForNextJump(true),
	mShouldFire(false),
	mTimeToCoolDown(0),
	mPlatform(NULL),
	mDead(false),
	mHealth(3),
	mNumKeys(0),
	mInvincible(false),
	mIdle(false), mIdleTime(0), mDeltaTime(0), mSmokeRunTime(0),
	mShouldSpawnSmokeJump(false)
{
	mUpdateNodeRotation = false;
	
	mOffset = PNGMakePoint(0, 10);
	
	// ---
	
	int walkFrames[] = { 0, 1, 2, 3 };
	int walkNumFrames = sizeof(walkFrames) / sizeof(int);
	addAction("Walk", walkFrames, walkNumFrames, "Player", 0.08, true);
	
	// ---
	
	int idleFrames[] = { 5, 6, 7 };
	int idleNumFrames = sizeof(idleFrames) / sizeof(int);
	addAction("Idle", idleFrames, idleNumFrames, "Player", 0.09, true);
	
	// ---
	
	CCAction* pulsateAction = [[CCRepeatForever alloc] initWithAction:
							   [CCSequence actions:
								[CCTintTo actionWithDuration:0.125 red:255 green:0 blue:0],
								[CCTintTo actionWithDuration:0.125 red:255 green:255 blue:255],
								nil]];
	addAction("Pulsate", pulsateAction);
	[pulsateAction release];
	
	// ---
	
	CCAction* rotateLeftAction = [[CCRotateTo alloc] initWithDuration:0.5 angle:-90];
	addAction("RotateLeft", rotateLeftAction);
	[rotateLeftAction release];
	
	// ---
	
	CCAction* rotateRightAction = [[CCRotateTo alloc] initWithDuration:0.5 angle:90];
	addAction("RotateRight", rotateRightAction);
	[rotateRightAction release];
	
	// ---
	
	CCAction* fadeOutAction = [[CCFadeOut alloc] initWithDuration:1];
	addAction("Die", fadeOutAction);
	[fadeOutAction release];
	
	// ---
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player4"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	// mNode.visible = NO;
	
	mPhyBody = instantiatePhysicsFor("PlayerNormal", pos);
	
	CCLOG(@"PLAYER MASS: %f", mPhyBody->GetMass());
	
	State<PlayerNormal>* startState = PlayerNormalState_OnTheFloor::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(PlayerNormalState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

PlayerNormal::~PlayerNormal()
{
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void PlayerNormal::OnButtonLeftPressed()
{
	MoveLeft();
}

void PlayerNormal::OnButtonLeftReleased()
{
	StopMovingLeft();
}

void PlayerNormal::OnButtonRightPressed()
{
	MoveRight();
}

void PlayerNormal::OnButtonRightReleased()
{
	StopMovingRight();
}

void PlayerNormal::OnButtonAPressed()
{
	Jump();
}

void PlayerNormal::OnButtonAReleased()
{
	StopJumping();
}

void PlayerNormal::OnButtonBPressed()
{
	Fire();
}

void PlayerNormal::OnButtonBReleased()
{
}

void PlayerNormal::MoveLeft()
{
	if (mDead) return;
	
	mMoveLeftPressed = true;
	mMoveLeftReleased = false;
	
	mNode.scaleX = -1;
	mDirectionLeft = true;
}

void PlayerNormal::StopMovingLeft()
{
	if (mDead) return;
	
	mMoveLeftReleased = true;
}

void PlayerNormal::MoveRight()
{
	if (mDead) return;
	
	mMoveRightPressed = true;
	mMoveRightReleased = false;
	
	mNode.scaleX = 1;
	mDirectionLeft = false;
}

void PlayerNormal::StopMovingRight()
{
	if (mDead) return;
	
	mMoveRightReleased = true;
}

void PlayerNormal::Jump()
{
	if (mDead) return;
	
	mJumpPressed = true;
	mJumpReleased = false;
	
	mIdle = false;
}

void PlayerNormal::StopJumping()
{
	if (mDead) return;
	
	mJumpReleased = true;
}

void PlayerNormal::Fire()
{
	if (mDead) return;
	
	if (mTimeToCoolDown == 0)
	{
		mShouldFire = true;
		
		mIdle = false;
	}
}

void PlayerNormal::SetHealth(int health)
{
	mHealth = Clamp(health, 0, 3);
	CCLOG(@"HEALTH: %d", mHealth);
	
	if (mHealth == 0)
	{
		Telegram telegram(ID(), ID(), Msg_ZeroHealth, NULL);
		HandleMessage(telegram);
	}
	
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_HealthChanged, NULL);
	mLevel->HandleMessage(telegram);
}

void PlayerNormal::SetInvincible(bool invincible)
{
	if (mInvincible != invincible)
	{
		mInvincible = invincible;
		
		if (mInvincible)
		{
			ResetInvincibilityTimer();
			StartAction("Pulsate");
		}
		else
		{
			StopAction("Pulsate");
			((CCSprite*)mNode).color = ccWHITE;
		}
	}
}

void PlayerNormal::GotHit()
{
	AddHealth(-1);
	
	if (mHealth > 0)
	{
		SetInvincible(true);
		SoundManager::Instance()->ScheduleEffect("PlayerHit.caf");
	}
	else
	{
		SoundManager::Instance()->ScheduleEffect("PlayerKilled.caf");
	}
}

void PlayerNormal::Float()
{
	b2Vec2 velocity = (1 / mDeltaTime) * b2Vec2(0, -0.1);
	ApplyCorrectiveImpulse(mPhyBody, velocity);
}

void PlayerNormal::Die()
{
	mDead = true;
	
	mNode.scaleY = -1;
	mNode.zOrder += 50;
	MakeBodyNotCollidable(mPhyBody);
	
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player10"];
	
	StartAction("Die");
	
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_LifeLost, NULL);
	mLevel->HandleMessage(telegram);
}

void PlayerNormal::Done()
{
	mDead = true;
	
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player10"];
	
	if (mDirectionLeft)
		StartAction("RotateRight");
	else StartAction("RotateLeft");
	
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_LifeLost, NULL);
	mLevel->HandleMessage(telegram);
}

void PlayerNormal::DoFire()
{
	Flash* flash = new Flash(mLevel, mNode.position, mDirectionLeft);
	mLevel->AddGameObject(flash);
	
	// ---
	
	CGPoint offset = PNGMakePoint(10, -10);
	if (mDirectionLeft) offset.x *= -1;
	
	CGPoint pos = ccpAdd(mNode.position, offset);
	
	// Instantiate a bullet.
	Bullet* bullet = new Bullet(mLevel, pos, mDirectionLeft);
	mLevel->AddGameObject(bullet);
	
	SoundManager::Instance()->ScheduleEffect("PlayerFire.caf");
}

void PlayerNormal::WalkLimiter(float limitVel, bool walkLeft, b2Vec2& vel)
{
	bool shouldLimit = true;
	
	float sign = walkLeft ? -1 : 1;
	
	if (sign * (vel.x - limitVel) < 0)
	{
		float newVelocityX = vel.x + sign * mDeltaTime * mWalkForce / mPhyBody->GetMass();
		
		// If walk force doesn't make player walk above the velocity limit, then apply it.
		if (sign * (newVelocityX - limitVel) < 0)
		{
			shouldLimit = false;
			vel.x = newVelocityX;
			mPhyBody->ApplyForce(b2Vec2(sign * mWalkForce, 0), mPhyBody->GetWorldCenter());
		}
	}
	
	// Otherwise, make player walk at exactly the velocity limit.
	if (shouldLimit)
	{
		vel.x = limitVel;
		ApplyCorrectiveImpulse(mPhyBody, b2Vec2(limitVel, vel.y));
	}
}

void PlayerNormal::DeccelerateWalk(b2Vec2& vel)
{
	b2Vec2 platformVel = b2Vec2_zero;
	if (mPlatform) platformVel = mPlatform->PhyBody()->GetLinearVelocity();
	
	if (vel.x != platformVel.x)
	{
		if (mPlatform)
		{
			vel.x = platformVel.x;
			ApplyCorrectiveImpulse(mPhyBody, b2Vec2(platformVel.x, vel.y));
		}
		else
		{
			float sign = vel.x > platformVel.x ? -1 : 1;
			float newVelocityX = vel.x + sign * mDeltaTime * mWalkSlowdownForce / mPhyBody->GetMass();
			
			// If slowdown force won't change player's direction, then apply it.
			if (sign * (vel.x - platformVel.x) < 0 && sign * (newVelocityX - platformVel.x) <= 0)
			{
				vel.x = newVelocityX;
				mPhyBody->ApplyForce(b2Vec2(sign * mWalkSlowdownForce, 0), mPhyBody->GetWorldCenter());
			}
			// Otherwise, stop the player immediately on X-axis.
			else
			{
				vel.x = platformVel.x;
				ApplyCorrectiveImpulse(mPhyBody, b2Vec2(platformVel.x, vel.y));
			}
		}
	}
}

void PlayerNormal::Walk()
{
	b2Vec2 vel = mPhyBody->GetLinearVelocity();
	
	b2Vec2 platformVel = b2Vec2_zero;
	if (mPlatform) platformVel = mPlatform->PhyBody()->GetLinearVelocity();
	
	float limitVelLeft = platformVel.x - mWalkVelocity;
	float limitVelRight = platformVel.x + mWalkVelocity;
	
	if (mMoveLeftPressed) WalkLimiter(limitVelLeft, true, vel);
	else if (mMoveRightPressed) WalkLimiter(limitVelRight, false, vel);
	else if (!mMoveLeftPressed && !mMoveRightPressed) DeccelerateWalk(vel);
	
	// Check whether all the velocities are within their limits.
	if (vel.x > limitVelRight) ApplyCorrectiveImpulse(mPhyBody, b2Vec2(limitVelRight, vel.y));
	else if (vel.x < limitVelLeft) ApplyCorrectiveImpulse(mPhyBody, b2Vec2(limitVelLeft, vel.y));
	
	if (vel.y < mFallVelocity) ApplyCorrectiveImpulse(mPhyBody, b2Vec2(vel.x, mFallVelocity));
	
	// -----
	
	mTimeToCoolDown -= mDeltaTime;
	if (mTimeToCoolDown < 0) mTimeToCoolDown = 0;
	
	if (mShouldFire)
	{
		mShouldFire = false;
		mTimeToCoolDown = 0.08; // This means Lance can fire at most 12.5 bullets per second.
		
		DoFire();
	}
}

void PlayerNormal::GlueToPlatform()
{
	return;
	if (mCanBeGlued && mPlatform->PhyBody()->GetLinearVelocity().y <= 0)
		ApplyCorrectiveImpulse(mPhyBody, b2Vec2(mPhyBody->GetLinearVelocity().x, mPlatform->PhyBody()->GetLinearVelocity().y));
}

void PlayerNormal::PerformBounce()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player8"];
	
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(mPhyBody->GetLinearVelocity().x, mBounceVelocity));
}

void PlayerNormal::PerformJump()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player8"];
	
	mReadyForNextJump = false;
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(mPhyBody->GetLinearVelocity().x, mJumpVelocity));
	SoundManager::Instance()->ScheduleEffect("PlayerJump.caf");
}

void PlayerNormal::AttenuateJump()
{
	b2Vec2 vel = mPhyBody->GetLinearVelocity();
	float newVelocityY = vel.y + mDeltaTime * mJumpSlowdownForce / mPhyBody->GetMass();
	
	// If slowdown force won't change player's direction, then apply it.
	if (newVelocityY > 0)
		mPhyBody->ApplyForce(b2Vec2(0, mJumpSlowdownForce), mPhyBody->GetWorldCenter());
	// Otherwise, just stop the player immediately on Y-axis.
	else ApplyCorrectiveImpulse(mPhyBody, b2Vec2(vel.x, 0));
}

void PlayerNormal::SpawnSmokeJump()
{
	CGPoint offset = PNGMakePoint(0, -20);
	CGPoint pos = ccpAdd(mNode.position, offset);
	
	// Instantiate smoke.
	SmokeJump* smokeJump = new SmokeJump(mLevel, pos);
	mLevel->AddGameObject(smokeJump);
}

void PlayerNormal::AnimateOnTheFloor()
{
	CCSprite* sprite = (CCSprite*)mNode;
	
	if (mMoveLeftPressed || mMoveRightPressed)
	{
		StopAction("Idle");
		StartAction("Walk");
		
		mIdle = false;
		
		mSmokeRunTime += mDeltaTime;
		if (mSmokeRunTime >= 0.5)
		{
			mSmokeRunTime = 0;
			
			CGPoint offset = PNGMakePoint(18, -20);
			if (!mDirectionLeft) offset.x *= -1;
			
			CGPoint pos = ccpAdd(mNode.position, offset);
			
			// Instantiate smoke.
			SmokeRun* smokeRun = new SmokeRun(mLevel, pos, mDirectionLeft);
			mLevel->AddGameObject(smokeRun);
		}
	}
	else
	{
		mSmokeRunTime = 0;
		
		if (!mIdle)
		{
			CCLOG(@"mIdle == false");
			StopAction("Walk");
			StopAction("Idle");
			sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Player4"];
			
			mIdle = true;
			mIdleTime = 0;
		}
		else if (mIdleTime > 3)
		{
			StopAction("Walk");
			StartAction("Idle");
		}
	}
}

void PlayerNormal::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
	
	if (mIdle) mIdleTime += dt;
	
	// Fix button flags if necessary.
	if (mMoveLeftPressed && mMoveLeftReleased) mMoveLeftPressed = false;
	if (mMoveRightPressed && mMoveRightReleased) mMoveRightPressed = false;
	if (mJumpPressed && mJumpReleased)
	{
		mJumpPressed = false;
		mReadyForNextJump = true;
	}
}

void PlayerNormal::PreSolve(CollisionInfo* colInfo)
{
	if (colInfo->OtherObject->IsEnemy())
	{
		//CCLOG(@"PLAYER: DISABLE CONTACT PRE-SOLVE");
		colInfo->Contact->SetEnabled(false);
	}
}

void PlayerNormal::ProcessContacts()
{
	mStompedEnemyIDs.clear();
	mNewlyStompedEnemyIDs.clear();
	
	mNumFootContacts = 0;
	mCanBeGlued = false;
	mPlatform = NULL;
	
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.ThisObjFixType == 1)
		{
			if (colInfo.OtherObjFixType == 2)
			{
				++mNumFootContacts;
				
				if (colInfo.OtherObject->Class() == "Platform")
				{
					mCanBeGlued = true;
					mPlatform = (Platform*)colInfo.OtherObject;
				}
			}
		}
		else if (colInfo.ThisObjFixType == 200 && colInfo.OtherObjFixType == 8)
		{
			if (!colInfo.Processed)
			{
				colInfo.Processed = true;
				colInfo.PlayerVelocity = mPhyBody->GetLinearVelocity();
				
				if (colInfo.PlayerVelocity.y < 0)
				{
					mNewlyStompedEnemyIDs.insert(colInfo.OtherObject->ID());
				}
			}
			
			if (colInfo.PlayerVelocity.y < 0)
				mStompedEnemyIDs.insert(colInfo.OtherObject->ID());
		}
	}
	
	mCanJump = (mNumFootContacts > 0);
	
	// Handle enemies that have just been stomped.
	if (mNewlyStompedEnemyIDs.size() > 0)
	{
		// Jump off of enemy's back (or head).
		if (JumpPressed() && ReadyForNextJump() && !FSM()->IsInState(PlayerNormalState_Jump::Instance()))
		{
			FSM()->ChangeState(PlayerNormalState_Jump::Instance());
		}
		else
		{
			FSM()->ChangeState(PlayerNormalState_Bounce::Instance());
		}
		
		for (std::set<int>::iterator it = mNewlyStompedEnemyIDs.begin(); it != mNewlyStompedEnemyIDs.end(); ++it)
		{
			int enemyID = *it;
			mLevel->MsgDispatcher()->DispatchMsg(ID(), enemyID, Msg_StompedByPlayer, NULL);
		}
	}
	
	// Count deadly contacts.
	mNumDeadlyContacts = 0;
	
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherFixUserData->KillsPlayer)
		{
			std::set<int>::iterator it = mStompedEnemyIDs.find(colInfo.OtherObject->ID());
			
			if (it == mStompedEnemyIDs.end())
			{
				++mNumDeadlyContacts;
			}
		}
	}
}
