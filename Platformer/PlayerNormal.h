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

#ifndef PLAYERNORMAL_H
#define PLAYERNORMAL_H

#import "GameObjectFSM.h"

class Platform;


class PlayerNormal : public GameObjectFSM<PlayerNormal>
{
public:
	PlayerNormal(LevelController* level, CGPoint pos);
	virtual ~PlayerNormal();
	
	void PreSolve(CollisionInfo* colInfo);
	void ProcessContacts();
	
	void MoveLeft();
	void StopMovingLeft();
	void MoveRight();
	void StopMovingRight();
	void Jump();
	void StopJumping();
	void Fire();
	void Die();
	
	void Done();
	void WalkLimiter(float limitVel, bool walkLeft, b2Vec2& vel);
	void DeccelerateWalk(b2Vec2& vel);
	void Walk();
	void DoFire();
	void GlueToPlatform();
	void PerformBounce();
	void PerformJump();
	void AttenuateJump();
	bool JumpPressed() const { return mJumpPressed; }
	void SetReadyForNextJump(bool ready) { mReadyForNextJump = ready; }
	bool ReadyForNextJump() const { return mReadyForNextJump; }
	bool TouchingFloor() const { return mNumFootContacts > 0; }
	
	void SetNumDeadlyContacts(int num) { mNumDeadlyContacts = num; }
	int NumDeadlyContacts() const { return mNumDeadlyContacts; }
	
	void SetHealth(int health);
	void AddHealth(int deltaHealth) { SetHealth(mHealth + deltaHealth); }
	int Health() const { return mHealth; }
	
	void SetNumKeys(int numKeys) { mNumKeys = numKeys; }
	int NumKeys() const { return mNumKeys; }
	
	void SetIdle(bool idle) { mIdle = idle; }
	bool Idle() const { return mIdle; }
	
	void SetInvincible(bool invincible);
	bool Invincible() const { return mInvincible; }
	
	void GotHit();
	
	void ResetInvincibilityTimer() { mInvincibilityTime = 0; }
	void UpdateInvincibilityTimer() { mInvincibilityTime += mDeltaTime; }
	ccTime InvincibilityTimerValue() const { return mInvincibilityTime; }
	
	void AnimateOnTheFloor();
	void Float();
	
	void SetShouldSpawnSmokeJump(bool shouldSpawn) { mShouldSpawnSmokeJump = shouldSpawn; }
	bool ShouldSpawnSmokeJump() { return mShouldSpawnSmokeJump; }
	void SpawnSmokeJump();
	
	virtual void Update(ccTime dt);
	
	// Handle user controls
	virtual void OnButtonLeftPressed();
	virtual void OnButtonLeftReleased();
	virtual void OnButtonRightPressed();
	virtual void OnButtonRightReleased();
	virtual void OnButtonAPressed();
	virtual void OnButtonAReleased();
	virtual void OnButtonBPressed();
	virtual void OnButtonBReleased();
	
private:
	const float mWalkVelocity, mWalkForce, mWalkSlowdownForce;
	const float mJumpVelocity, mJumpSlowdownForce, mFallVelocity, mBounceVelocity;
	
	ccTime mDeltaTime;
	
	// Button pressed/released flags.
	bool mMoveLeftPressed, mMoveLeftReleased;
	bool mMoveRightPressed, mMoveRightReleased;
	bool mJumpPressed, mJumpReleased;
	bool mReadyForNextJump;
	bool mShouldFire;
	
	// Flags related to jumping.
	bool mCanJump;
	bool mCanBeGlued;
	int mNumFootContacts;
	
	int mNumDeadlyContacts;
	
	bool mDirectionLeft;
	
	bool mDead;
	
	int mHealth;
	bool mInvincible;
	
	int mNumKeys;
	
	float mTimeToCoolDown;
	
	std::set<int> mStompedEnemyIDs;
	std::set<int> mNewlyStompedEnemyIDs;
	
	Platform* mPlatform;
	
	bool mIdle;
	ccTime mIdleTime;
	ccTime mInvincibilityTime;
	ccTime mSmokeRunTime;
	
	bool mShouldSpawnSmokeJump;
};

#endif
