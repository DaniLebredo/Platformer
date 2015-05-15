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

#ifndef STOMPER_H
#define STOMPER_H

#import "GameObjectFSM.h"

class Stomper : public GameObjectFSM<Stomper>
{
public:
	Stomper(LevelController* level, CGPoint pos, NSDictionary* opt = NULL);
	virtual ~Stomper();
	
	CCNode* NodeMovable() const { return mNodeMovable; }
	b2Body* PhyBodyMovable() const { return mPhyBodyMovable; }
	b2PrismaticJoint* Joint() const { return mJoint; }
	
	void ResetWaitTimer() { mWaitTime = 0; }
	void UpdateWaitTimer() { mWaitTime += mDeltaTime; }
	ccTime WaitTimerValue() { return mWaitTime; }
	
	virtual void Update(ccTime dt);
	virtual void SaveCurrentState();
	virtual void UpdateDraw();
	virtual void UpdateDraw(float t);
	
	virtual void OnWentOnScreen();
	virtual void OnWentOffScreen();
	
protected:
	CCNode* mNodeMovable;
	b2Body* mPhyBodyMovable;
	b2PrismaticJoint* mJoint;
	
	CGPoint mOffsetMovable;
	
private:
	// State
	b2Vec2 mPrevPositionMovable;
	float mPrevAngleMovable;
	
	ccTime mDeltaTime;
	ccTime mWaitTime;
};

#endif
