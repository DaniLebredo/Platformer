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

#ifndef ENEMY_H
#define ENEMY_H

#import "GameObjectFSM.h"

// ------------------------------------------------------------------------------------

class EnemyRayCastCallback : public b2RayCastCallback
{
public:
	EnemyRayCastCallback();
	
	bool PlayerFound() const { return mPlayerFound; }
	
	// Should be called each time before b2World::RayCast is called.
	void ResetState() { mPlayerFound = false; }
	
	float32 ReportFixture(b2Fixture* fixture, const b2Vec2& point, const b2Vec2& normal, float32 fraction);
	
private:
	bool mPlayerFound;
};

// ------------------------------------------------------------------------------------

class Enemy : public GameObjectFSM<Enemy>
{
public:
	Enemy(LevelController* level, CGPoint pos, NSDictionary* opt = NULL);
	virtual ~Enemy();
	
	void ProcessContacts();
	
	void Walk();
	void StopWalking();
	
	void Fire();
	int NumShotsFired() const { return mNumShotsFired; }
	bool CanFireNextShot() const { return mTimeSinceLastShot > 0.3; }
	void ResetShotCounter() { mNumShotsFired = 0; }
	
	bool ScanForPlayer();
	bool CanScanForPlayer() const { return mTimeSinceLastScan > mScanPeriod; }
	void ResetTimeSinceLastScan() { mTimeSinceLastScan = 0; }
	
	void Die();
	void Drown();
	void Sink();
	
	void SetMoveLeft(bool moveLeft);
	bool MoveLeft() const { return mMoveLeft; }
	
	int NumDeadlyContacts() const { return mNumDeadlyContacts; }
	
	virtual void Update(ccTime dt);
	
private:
	bool mMoveLeft;
	bool mShouldTurn;
	
	int mNumFootContacts, mNumLeftFootContacts, mNumRightFootContacts;
	
	ccTime mDeltaTime;
	ccTime mTimeSinceLastScan;
	ccTime mTimeSinceLastShot;
	
	ccTime mScanPeriod;
	
	int mNumShotsFired;
	
	int mNumDeadlyContacts;
	
	EnemyRayCastCallback* mRayCastCallback;
};

#endif
