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

#ifndef GAMEOBJECT_H
#define GAMEOBJECT_H

#import "StdInclude.h"
#import "Utility.h"
#import "Telegram.h"
#import "CollisionInfo.h"
#import "Action.h"

class LevelController;

class GameObject
{
public:
	GameObject(const std::string& cls, LevelController* level, NSDictionary* opt = NULL);
	virtual ~GameObject();
	
	const std::string& Class() const { return mClass; }
	const std::string& Tag() const { return mTag; }
	
	void SetID(int val);
	int ID() const { return mID; }
	static int GetNextValidID() { return mNextValidID; }
	static void ResetNextValidID() { mNextValidID = 0; }
	
	CCNode* Node() const { return mNode; }
	b2Body* PhyBody() const { return mPhyBody; }
	
	float Top() const { return mTop; }
	float Bottom() const { return mBottom; }
	float Left() const { return mLeft; }
	float Right() const { return mRight; }
	
	bool IsEnemy() const { return mIsEnemy; }
	
	void SetDestroyed(bool destroyed) { mDestroyed = destroyed; }
	bool Destroyed() const { return mDestroyed; }
	
	void AddContact(CollisionInfo& colInfo);
	void RemoveContact(CollisionInfo& colInfo);

	void StartAction(const std::string& actionName, CCNode* node = nil);
	void StopAction(const std::string& actionName, CCNode* node = nil);
	bool IsActionDone(const std::string& actionName);
	
	virtual void Pause();
	virtual void Resume();
	
	virtual void Update(ccTime dt);
	virtual void SaveCurrentState();
	virtual void UpdateDraw();
	virtual void UpdateDraw(float t);
	
	virtual bool HandleMessage(const Telegram& msg) { return false; }
	
	// Handle user controls
	virtual void OnButtonLeftPressed() {}
	virtual void OnButtonLeftReleased() {}
	virtual void OnButtonRightPressed() {}
	virtual void OnButtonRightReleased() {}
	virtual void OnButtonAPressed() {}
	virtual void OnButtonAReleased() {}
	virtual void OnButtonBPressed() {}
	virtual void OnButtonBReleased() {}
	
	// Handle going on/off screen
	virtual void OnWentOnScreen();
	virtual void OnWentOffScreen();
	
	// Water
	void SetNumWaterContacts(int num) { mNumWaterContacts = num; }
	int NumWaterContacts() const { return mNumWaterContacts; }
	
protected:
	b2Body* instantiatePhysicsFor(const std::string& key, CGPoint pos);
	void updateNodeFromPhyBody(CCNode* node, b2Body* body, const CGPoint& offset);
	void updateNodeFromPhyBody(CCNode* node, b2Body* body, const CGPoint& offset, const b2Vec2& prevPosition, float prevAngle, float t);
	
	void addAction(const std::string& actionName, Action* action);
	void addAction(const std::string& actionName, CCAction* act);
	void addAction(const std::string& actionName, int frames[], int numFrames, const std::string& frameName, float delay, bool repeatForever);
	
protected:
	CCNode* mNode;
	b2Body* mPhyBody;
	
	float mTop, mBottom, mLeft, mRight;	// AABB
	
	bool mIsEnemy;
	
	LevelController* mLevel;	// weak ptr
	b2World* mPhyWorld;		// weak ptr
	float mPtmRatio;
	
	bool mDestroyed;
	
	CGPoint mOffset;
	
	bool mUpdateNodePosition;
	bool mUpdateNodeRotation;
	
	std::vector<CollisionInfo> mContacts;
	
private:
	int mID;
	static int mNextValidID;
	
	std::string mClass;
	std::string mTag;
	
	// State
	b2Vec2 mPrevPosition;
	float mPrevAngle;
	
	// Actions
	std::map<std::string, Action*> mActions;
	
	int mNumWaterContacts;
};

#endif
