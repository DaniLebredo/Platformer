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

#ifndef WATER_H
#define WATER_H

#import "GameObjectFSM.h"


class Water : public GameObjectFSM<Water>
{
public:
	Water(LevelController* level, CGPoint pos, NSDictionary* opt = NULL);
	virtual ~Water();
	
	void BeginContact(CollisionInfo* collisionInfo);
	void EndContact(CollisionInfo* collisionInfo);
	void PreSolve(CollisionInfo* collisionInfo);
	
	void MakeSplash(float x, float amount);
	void MakeRandomSplash(float amount, bool randomDirection = false);
	
	void ResetTimeSinceLastSplash() { mTimeSinceLastSplash = 0; }
	ccTime TimeSinceLastSplash() const { return mTimeSinceLastSplash; }
	void UpdateTimeSinceLastSplash() { mTimeSinceLastSplash += mDeltaTime; }
	
	virtual void Update(ccTime dt);
	virtual void UpdateDraw();
	virtual void UpdateDraw(float t);
	
	virtual void OnWentOnScreen();
	virtual void OnWentOffScreen();
	
private:
	ccTime mDeltaTime;
	ccTime mTimeSinceLastSplash;
	
	float mWidth;
	float mHeight;
};

#endif
