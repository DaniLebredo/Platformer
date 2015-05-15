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

#import "Pendulum.h"
#import "PendulumStates.h"
#import "Game.h"
#import "LevelController.h"


Pendulum::Pendulum(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Pendulum>("Pendulum", level, opt),
	mRotateClockwise(false)
{
	mNode = [[CCSprite alloc] initWithFile:@"Mace.png" rect:PNGMakeRect(0, 0, 26, 26)];
	mNode.position = pos;
	
	mNodeMovable = [[CCSprite alloc] initWithFile:@"Mace.png" rect:PNGMakeRect(26, 0, 78, 26)];
	mNodeMovable.position = pos;
	mNodeMovable.anchorPoint = ccp(0, 0.5);
	
	mOffsetMovable = PNGMakePoint(0, 0);
	
	// Update AABB
	mTop = PNGMakeFloat(3 * 26);
	mLeft = PNGMakeFloat(3 * 26);
	mBottom = PNGMakeFloat(3 * 26);
	mRight = PNGMakeFloat(3 * 26);
	
	if (Game::Instance()->DebugOn())
	{
		((CCSprite*)mNode).opacity = 128;
		((CCSprite*)mNodeMovable).opacity = 128;
	}
	
	if (opt)
	{
		NSString* clockwise = [opt objectForKey:@"clockwise"];
		if (clockwise && [clockwise isEqualToString:@"true"])
			mRotateClockwise = true;
	}
	
	mPhyBody = instantiatePhysicsFor("PendulumStatic", pos);
	mPhyBodyMovable = instantiatePhysicsFor("PendulumDynamic", mNodeMovable.position);
	
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(mPhyBody, mPhyBodyMovable, mPhyBody->GetWorldCenter());
	// jointDef.lowerAngle = -0.5f * b2_pi; // -90 degrees
	// jointDef.upperAngle = 0.25f * b2_pi; // 45 degrees
	// jointDef.enableLimit = true;
	jointDef.maxMotorTorque = 25;
	jointDef.motorSpeed = mRotateClockwise ? -3 : 3;
	jointDef.enableMotor = true;
	mJoint = static_cast<b2RevoluteJoint*>(mPhyWorld->CreateJoint(&jointDef));
	
	// CCLOG(@"BODY MASS: %f", mPhyBody->GetMass());
	
	State<Pendulum>* startState = CommonState_Init<Pendulum>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(PendulumState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Pendulum::~Pendulum()
{
	// CCLOG(@"DEALLOC: Pendulum");
	
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

void Pendulum::SaveCurrentState()
{
	GameObjectFSM::SaveCurrentState();
	
	if (mPhyBodyMovable != NULL)
	{
		mPrevPositionMovable = mPhyBodyMovable->GetPosition();
		mPrevAngleMovable = mPhyBodyMovable->GetAngle();
	}
}

void Pendulum::Update(ccTime dt)
{
	GameObjectFSM::Update(dt);
}

void Pendulum::UpdateDraw()
{
	GameObjectFSM::UpdateDraw();
	updateNodeFromPhyBody(mNodeMovable, mPhyBodyMovable, mOffsetMovable);
}

void Pendulum::UpdateDraw(float t)
{
	GameObjectFSM::UpdateDraw(t);
	updateNodeFromPhyBody(mNodeMovable, mPhyBodyMovable, mOffsetMovable, mPrevPositionMovable, mPrevAngleMovable, t);
}

void Pendulum::OnWentOnScreen()
{
	if (!mNode.visible)
		mNode.visible = YES;
	
	if (!mNodeMovable.visible)
		mNodeMovable.visible = YES;
}

void Pendulum::OnWentOffScreen()
{
	if (mNode.visible)
		mNode.visible = NO;
	
	if (mNodeMovable.visible)
		mNodeMovable.visible = NO;
}
