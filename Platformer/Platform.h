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

#ifndef PLATFORM_H
#define PLATFORM_H

#import "GameObjectFSM.h"


class Platform : public GameObjectFSM<Platform>
{
public:
	Platform(LevelController* level, CGPoint pos, NSDictionary* opt = NULL);
	virtual ~Platform();
	
	void PreSolve(CollisionInfo* colInfo);
	
	void Move();
	void StopMoving();
	
	bool Inactive() const { return mInactive; }
	
	void Idle() { mIdleTime += mDeltaTime; }
	ccTime IdleTime() const { return mIdleTime; }
	void SetMaxIdleTime(float maxIdleTime) { mMaxIdleTime = maxIdleTime; }
	ccTime MaxIdleTime() const { return mMaxIdleTime; }
	
	void SwitchToNextWayPoint() { mLastWayPointIndex = (mLastWayPointIndex + 1) % mWayPoints.size(); }
	const b2Vec2& NextWayPoint() const { return mWayPoints[(mLastWayPointIndex + 1) % mWayPoints.size()]; }
	
	virtual void Update(ccTime dt);
	
	virtual void OnWentOnScreen();
	virtual void OnWentOffScreen();
	
private:
	float mVelocity;
	bool mInactive;
	
	int mLastWayPointIndex;
	
	std::vector<b2Vec2> mWayPoints;
	std::vector<b2Vec2> mVelocities;
	
	ccTime mDeltaTime;
	ccTime mIdleTime;
	ccTime mMaxIdleTime;
};

#endif
