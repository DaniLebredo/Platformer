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

#import "Platform.h"
#import "PlatformStates.h"
#import "Game.h"


Platform::Platform(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Platform>("Platform", level, opt),
	mVelocity(2),
	mInactive(false),
	mDeltaTime(0),
	mIdleTime(0),
	mMaxIdleTime(0),
	mLastWayPointIndex(0)
{
	mOffset = PNGMakePoint(0, 5);
	
	mNode = [[CCSprite alloc] initWithFile:@"Platform.png"];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mWayPoints.push_back(b2Vec2(pos.x / mPtmRatio, pos.y / mPtmRatio));
	
	mPhyBody = instantiatePhysicsFor("Platform", pos);
	
	if (opt)
	{
		NSString* velocity = [opt objectForKey:@"velocity"];
		if (velocity) mVelocity = [velocity floatValue];
		
		NSString* inactive = [opt objectForKey:@"inactive"];
		if (inactive && [inactive isEqualToString:@"true"]) mInactive = true;
		
		NSString* maxIdleTime = [opt objectForKey:@"maxIdleTime"];
		if (maxIdleTime) mMaxIdleTime = [maxIdleTime floatValue];
		
		NSString* wayPoints = [opt objectForKey:@"wayPoints"];
		if (wayPoints)
		{
			std::vector<std::string> tokens = SplitString(std::string([wayPoints UTF8String]), "#");
			
			for (int i = 0; i < tokens.size(); ++i)
			{
				std::vector<std::string> coords = SplitString(tokens[i], ",");
				
				if (coords.size() != 2)
				{
					CCLOG(@"Platform: Waypoint error. There should be exactly 2 components in each coordinate.");
					continue;
				}
				
				float x = ::atof(coords[0].c_str());
				float y = ::atof(coords[1].c_str());
				mWayPoints.push_back(b2Vec2(x, y) + mWayPoints[mWayPoints.size() - 1]);
			}
		}
	}
	
	// --
	
	for (int i = 0; i < mWayPoints.size(); ++i)
	{
		b2Vec2 velocity = mWayPoints[(i + 1) % mWayPoints.size()] - mWayPoints[i];
		velocity.Normalize();
		mVelocities.push_back(velocity);
	}
	
	// --
	
	State<Platform>* startState = CommonState_Init<Platform>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(PlatformState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Platform::~Platform()
{
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Platform::Move()
{
	b2Vec2 sourcePos = mWayPoints[mLastWayPointIndex];
	b2Vec2 targetPos = mWayPoints[(mLastWayPointIndex + 1) % mWayPoints.size()];
	
	b2Vec2 targetVel = mVelocities[mLastWayPointIndex];
	targetVel *= mVelocity;
	
	// Value of 0.4 was found experimentally. It was tested for velocities between 2 and 10. We don't
	// need anything bigger or smaller than that anyway.
	if ((targetPos - mPhyBody->GetPosition()).LengthSquared() < 0.4 * 0.4 * mVelocity * mVelocity)
	{
		targetVel = 0.5 * mPhyBody->GetLinearVelocity();
	}
	
	b2Vec2 velocity = Lerp(mPhyBody->GetLinearVelocity(), targetVel, 0.05);
	
	// Prevent overshooting.
	b2Vec2 nextPos = mPhyBody->GetPosition() + mDeltaTime * velocity;
	if ((nextPos - sourcePos).LengthSquared() > (targetPos - sourcePos).LengthSquared())
	{
		velocity = (1 / mDeltaTime) * (targetPos - mPhyBody->GetPosition());
	}
	
	mPhyBody->SetLinearVelocity(velocity);
}

void Platform::StopMoving()
{
	mIdleTime = 0;
	mPhyBody->SetLinearVelocity(b2Vec2_zero);
}

void Platform::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Platform::PreSolve(CollisionInfo* colInfo)
{
	if (colInfo->OtherObject->Class() == "Player" ||
		colInfo->OtherObject->IsEnemy())
	{
		if (/*colInfo->OtherObject->PhyBody()->GetLinearVelocity().y > 0 ||*/
			colInfo->OtherObject->PhyBody()->GetPosition().y - mPhyBody->GetPosition().y < 0.5 + 0.5 - 0.05)
		{
			//CCLOG(@"DISABLING PRE-SOLVE");
			colInfo->Contact->SetEnabled(false);
		}
	}
}

void Platform::OnWentOnScreen()
{
	if (!mNode.visible)
		mNode.visible = YES;
}

void Platform::OnWentOffScreen()
{
	if (mNode.visible)
		mNode.visible = NO;
}
