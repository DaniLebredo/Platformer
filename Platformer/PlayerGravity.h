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

#ifndef PLAYERGRAVITY_H
#define PLAYERGRAVITY_H

#import "GameObjectFSM.h"

class PlayerGravity : public GameObjectFSM<PlayerGravity>
{
public:
	PlayerGravity(LevelController* level, CGPoint pos);
	virtual ~PlayerGravity();
	
	void BeginContact(CollisionInfo* collisionInfo);
	void EndContact(CollisionInfo* collisionInfo);
	
	void Jump();
	void StopJumping();
	void Fire();
	void Die();
	void Done();
	
	int NumFootContacts() const { return mNumFootContacts; }
	
	void Walk();
	void WalkLimiter(float limitVel, bool walkLeft);
	
	int Health() const { return mHealth; }
	void GotHit();
	
	void StartWalkAnimation();
	void StopWalkAnimation();
	void StartFallAnimation();
	
	virtual void Update(ccTime dt);
	
	// Handle user controls
	virtual void OnButtonAPressed();
	virtual void OnButtonBPressed();
	
private:
	float mWalkVelocity, mWalkForce, mFallVelocity;
	
	int mNumFootContacts;
	
	bool mGravityDown;
	
	bool mDead;
	
	int mHealth;
	
	CCAction* mWalkAction;
	
	ccTime mDeltaTime;
};

#endif
