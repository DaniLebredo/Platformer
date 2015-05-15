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

#import "Boulder.h"
#import "BoulderStates.h"
#import "BoulderSmoke.h"
#import "LevelController.h"
#import "Game.h"


Boulder::Boulder(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Boulder>("Boulder", level, opt),
	mDeltaTime(0),
	mMoveLeft(false)
{
	mUpdateNodeRotation = false;
	
	// --
	
	mOffset = PNGMakePoint(0, 12);
	
	// Update AABB
	mTop = PNGMakeFloat(1.5 * 26);
	mBottom = PNGMakeFloat(0.5 * 26);
	mLeft = PNGMakeFloat(1 * 26);
	mRight = PNGMakeFloat(1 * 26);
	
	// --
	
	if (opt)
	{
		NSString* left = [opt objectForKey:@"left"];
		if (left && [left isEqualToString:@"true"])
			mMoveLeft = true;
	}
	
	// --
	
	float sign = mMoveLeft ? -1 : 1;
	
	CCAction* rollAction = [[CCRepeatForever alloc] initWithAction:
							[CCRotateBy actionWithDuration:0.1 angle:20 * sign]];
	addAction("Roll", rollAction);
	[rollAction release];
	
	// --
	
	mNode = [[CCSprite alloc] initWithFile:@"Boulder.png"];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Boulder", pos);
	
	State<Boulder>* startState = CommonState_Init<Boulder>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(BoulderState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Boulder::~Boulder()
{
	CCLOG(@"DEALLOC: Boulder");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Boulder::Roll()
{
	float sign = mMoveLeft ? -1 : 1;
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(3 * sign, mPhyBody->GetLinearVelocity().y));
}

void Boulder::SetMoveLeft(bool moveLeft)
{
	mMoveLeft = moveLeft;
}

void Boulder::Stop()
{
	// Instantiate smoke.
	CGPoint offset = PNGMakePoint(25, 0);
	
	if (mMoveLeft) offset.x *= -1;
	
	CGPoint pos = ccpAdd(mNode.position, offset);
	
	BoulderSmoke* smoke = new BoulderSmoke(mLevel, pos);
	mLevel->AddGameObject(smoke);
	
	// --
	
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(0, mPhyBody->GetLinearVelocity().y));
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("ObstacleHit.caf", deltaPos);
}

void Boulder::Rest()
{
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(0, mPhyBody->GetLinearVelocity().y));
}

void Boulder::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Boulder::PreSolve(CollisionInfo* colInfo)
{
	if (colInfo->OtherObject->Class() == "Player" ||
		colInfo->OtherObject->IsEnemy())
	{
		colInfo->Contact->SetEnabled(false);
	}
}

void Boulder::ProcessContacts()
{
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherObjFixType == 2)
		{
			if ((mMoveLeft && colInfo.ThisObjFixType == 9) || (!mMoveLeft && colInfo.ThisObjFixType == 10))
			{
				mLevel->MsgDispatcher()->DispatchMsg(ID(), ID(), Msg_BoulderStopped, NULL);
				break;
			}
		}
	}
}
