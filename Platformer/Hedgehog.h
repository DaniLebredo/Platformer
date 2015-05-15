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

#ifndef HEDGEHOG_H
#define HEDGEHOG_H

#import "GameObjectFSM.h"


class Hedgehog : public GameObjectFSM<Hedgehog>
{
public:
	Hedgehog(LevelController* level, CGPoint pos, NSDictionary* opt = NULL);
	virtual ~Hedgehog();
	
	void ProcessContacts();
	
	void Walk();
	void ResetWalkTime() { mWalkTime = 0; }
	void UpdateWalkTime() { mWalkTime += mDeltaTime; }
	ccTime WalkTime() const { return mWalkTime; }
	
	void Think();
	void ResetThinkTime() { mThinkTime = 0; }
	void UpdateThinkTime() { mThinkTime += mDeltaTime; }
	ccTime ThinkTime() const { return mThinkTime; }
	
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
	int mNumDeadlyContacts;
	
	ccTime mDeltaTime;
	ccTime mWalkTime;
	ccTime mThinkTime;
};

#endif
