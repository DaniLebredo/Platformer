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

#import "Stomper.h"
#import "StomperStates.h"
#import "Game.h"


Stomper::Stomper(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM("Stomper", level, opt),
	mDeltaTime(0),
	mWaitTime(0)
{
	mNode = [[CCSprite alloc] initWithFile:@"stomper.png" rect:PNGMakeRect(0, 0, 26, 26)];
	mNode.position = pos;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 64;
	
	mNodeMovable = [[CCSprite alloc] initWithFile:@"stomper.png" rect:PNGMakeRect(0, 26, 13, 78)];
	mNodeMovable.position = ccpAdd(pos, PNGMakePoint(0, 26));
	
	mOffsetMovable = PNGMakePoint(0, 0);
	
	mPhyBody = instantiatePhysicsFor("PendulumStatic", pos);
	mPhyBodyMovable = instantiatePhysicsFor("StomperDynamic", mNodeMovable.position);
	
	b2PrismaticJointDef jointDef;
	jointDef.Initialize(mPhyBody, mPhyBodyMovable, mPhyBody->GetWorldCenter(), b2Vec2(0, -1));
	// jointDef.lowerAngle = -0.5f * b2_pi; // -90 degrees
	// jointDef.upperAngle = 0.25f * b2_pi; // 45 degrees
	// jointDef.enableLimit = true;
	
	jointDef.lowerTranslation = 0;
	jointDef.upperTranslation = 3;
	jointDef.enableLimit = true;
	jointDef.maxMotorForce = 10;
	//jointDef.motorSpeed = -2.5;
	jointDef.enableMotor = true;
	mJoint = static_cast<b2PrismaticJoint*>(mPhyWorld->CreateJoint(&jointDef));
	
	// CCLOG(@"BODY MASS: %f", mPhyBody->GetMass());
	
	State<Stomper>* startState = CommonState_Init<Stomper>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(StomperState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Stomper::~Stomper()
{
	// CCLOG(@"DEALLOC: Stomper");
	
	[mNode stopAllActions];
	[mNodeMovable stopAllActions];
	
	if (mNodeMovable != nil)
	{
		[mNodeMovable removeFromParentAndCleanup:NO];
		[mNodeMovable release];
	}
	
	if (mJoint != NULL)
	{
		mPhyWorld->DestroyJoint(mJoint);
		mJoint = NULL;
	}
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
	
	if (mPhyBodyMovable != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBodyMovable);
		mPhyBodyMovable = NULL;
	}
}

void Stomper::SaveCurrentState()
{
	GameObjectFSM::SaveCurrentState();
	
	if (mPhyBodyMovable != NULL)
	{
		mPrevPositionMovable = mPhyBodyMovable->GetPosition();
		mPrevAngleMovable = mPhyBodyMovable->GetAngle();
	}
}

void Stomper::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Stomper::UpdateDraw()
{
	GameObjectFSM::UpdateDraw();
	updateNodeFromPhyBody(mNodeMovable, mPhyBodyMovable, mOffsetMovable);
}

void Stomper::UpdateDraw(float t)
{
	GameObjectFSM::UpdateDraw(t);
	updateNodeFromPhyBody(mNodeMovable, mPhyBodyMovable, mOffsetMovable, mPrevPositionMovable, mPrevAngleMovable, t);
}

void Stomper::OnWentOnScreen()
{
	if (!mNode.visible)
		mNode.visible = YES;
	
	if (!mNodeMovable.visible)
		mNodeMovable.visible = YES;
}

void Stomper::OnWentOffScreen()
{
	if (mNode.visible)
		mNode.visible = NO;
	
	if (mNodeMovable.visible)
		mNodeMovable.visible = NO;
}
