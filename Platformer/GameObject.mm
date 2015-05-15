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

#import "GameObject.h"
#import "LevelController.h"
#import "Game.h"


int GameObject::mNextValidID = 0;

GameObject::GameObject(const std::string& cls, LevelController* level, NSDictionary* opt) :
	mClass(cls),
	mNode(nil),
	mPhyBody(NULL),
	mDestroyed(false),
	mUpdateNodePosition(true),
	mUpdateNodeRotation(true),
	mLevel(level),
	mPhyWorld(level->PhyWorld()),
	mPtmRatio(level->PtmRatio()),
	mNumWaterContacts(0),
	mTop(0), mBottom(0), mLeft(0), mRight(0),
	mIsEnemy(false)
{
	SetID(GameObject::GetNextValidID());
	mOffset = PNGMakePoint(0, 0);
	
	if (opt)
	{
		NSString* tag = [opt objectForKey:@"tag"];
		if (tag) mTag = std::string(tag.UTF8String);
	}
}

GameObject::~GameObject()
{
	//CCLOG(@"Deallocing: %@", NSStringFromClass([self class]));
	
	if (mNode != nil)
	{
		[mNode stopAllActions];
	}
	
	for (std::map<std::string, Action*>::iterator it = mActions.begin(); it != mActions.end(); ++it)
	{
		CCLOG(@"DELETED ACTION: %s", it->first.c_str());
		delete it->second;
	}
	mActions.clear();
	
	if (mNode != nil)
	{
		[mNode removeFromParentAndCleanup:NO];
		[mNode release];
	}
}

void GameObject::SetID(int val)
{
	assert((val >= mNextValidID) && "<GameObject::SetID>: invalid ID");
	
	mID = val;
	mNextValidID = mID + 1;
}

b2Body* GameObject::instantiatePhysicsFor(const std::string& key, CGPoint pos)
{
	PhyBodyTemplate& tmpl = Game::Instance()->Data().PhyTemplateRepo().Item(key);
	
	return tmpl.Instantiate(mPhyWorld, b2Vec2(pos.x / mPtmRatio, pos.y / mPtmRatio), static_cast<void*>(this));
}

void GameObject::SaveCurrentState()
{
	if (mPhyBody != NULL)
	{
		mPrevPosition = mPhyBody->GetPosition();
		mPrevAngle = mPhyBody->GetAngle();
	}
}

void GameObject::Update(ccTime dt)
{
	SaveCurrentState();
}

void GameObject::UpdateDraw()
{
	updateNodeFromPhyBody(mNode, mPhyBody, mOffset);
}

void GameObject::UpdateDraw(float t)
{
	updateNodeFromPhyBody(mNode, mPhyBody, mOffset, mPrevPosition, mPrevAngle, t);
}

void GameObject::updateNodeFromPhyBody(CCNode* node, b2Body* body, const CGPoint& offset)
{
	if (node != nil && body != NULL)
	{
		if (mUpdateNodePosition)
			node.position = ccpAdd(ccp(body->GetPosition().x * mPtmRatio, body->GetPosition().y * mPtmRatio), offset);
		if (mUpdateNodeRotation)
			node.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
	}
}

void GameObject::updateNodeFromPhyBody(CCNode* node, b2Body* body, const CGPoint& offset, const b2Vec2& prevPosition, float prevAngle, float t)
{
	if (node != nil && body != NULL)
	{
		b2Vec2 position = Lerp(prevPosition, body->GetPosition(), t);
		float angle = Lerp(prevAngle, body->GetAngle(), t);
		
		if (mUpdateNodePosition)
			node.position = ccpAdd(ccp(position.x * mPtmRatio, position.y * mPtmRatio), offset);
		if (mUpdateNodeRotation)
			node.rotation = -1 * CC_RADIANS_TO_DEGREES(angle);
	}
}

void GameObject::AddContact(CollisionInfo& colInfo)
{
	mContacts.push_back(colInfo);
	HandleMessage(Telegram(ID_IRRELEVANT, ID(), Msg_BeginContact, static_cast<void*>(&colInfo)));
}

void GameObject::RemoveContact(CollisionInfo& colInfo)
{
	std::vector<CollisionInfo>::iterator it = std::find(mContacts.begin(), mContacts.end(), colInfo);
	
	if (it != mContacts.end())
	{
		CollisionInfo colInfoCopy = *it;
		mContacts.erase(it);
		HandleMessage(Telegram(ID_IRRELEVANT, ID(), Msg_EndContact, static_cast<void*>(&colInfoCopy)));
	}
}

void GameObject::addAction(const std::string& actionName, Action* action)
{
	mActions.insert(std::make_pair(actionName, action));
}

void GameObject::addAction(const std::string& actionName, CCAction* act)
{
	Action* action = new Action(act);
	addAction(actionName, action);
}

void GameObject::addAction(const std::string& actionName, int frames[], int numFrames, const std::string& frameName, float delay, bool repeatForever)
{
	Action* action = new Action(frames, numFrames, frameName, delay, repeatForever);
	addAction(actionName, action);
}

void GameObject::StartAction(const std::string& actionName, CCNode* node)
{
	std::map<std::string, Action*>::iterator it = mActions.find(actionName);
	
	if (it != mActions.end())
	{
		Action* action = it->second;
		
		if (!action->IsRunning)
		{
			if (node == nil) node = mNode;
			
			[node runAction:action->ActionObj];
			action->IsRunning = true;
		}
	}
	else
	{
		throw "<GameObject::StartAction> Action with given name doesn't exist.";
	}
}

void GameObject::StopAction(const std::string& actionName, CCNode* node)
{
	std::map<std::string, Action*>::iterator it = mActions.find(actionName);
	
	if (it != mActions.end())
	{
		Action* action = it->second;
		
		if (action->IsRunning)
		{
			if (node == nil) node = mNode;
			
			[node stopAction:action->ActionObj];
			action->IsRunning = false;
		}
	}
	else
	{
		throw "<GameObject::StopAction> Action with given name doesn't exist.";
	}
}

bool GameObject::IsActionDone(const std::string& actionName)
{
	std::map<std::string, Action*>::iterator it = mActions.find(actionName);
	
	if (it != mActions.end())
	{
		Action* action = it->second;
		return action->ActionObj.isDone == YES;
	}
	else
	{
		throw "<GameObject::IsActionDone> Action with given name doesn't exist.";
	}
}

void GameObject::Pause()
{
	if (mNode != nil)
	{
		[mNode pauseSchedulerAndActions];
	}
}

void GameObject::Resume()
{
	if (mNode != nil)
	{
		[mNode resumeSchedulerAndActions];
	}
}

void GameObject::OnWentOnScreen()
{
	if (mPhyBody != NULL)
	{
		mPhyBody->SetActive(true);
		//mPhyBody->SetAwake(true);
	}
	
	if (mNode != nil && !mNode.visible)
	{
		mNode.visible = YES;
	}
}

void GameObject::OnWentOffScreen()
{
	if (mPhyBody != NULL)
	{
		mPhyBody->SetActive(false);
		//mPhyBody->SetAwake(false);
	}
	
	if (mNode != nil && mNode.visible)
	{
		mNode.visible = NO;
	}
}
